import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../../domain/repositories/sync_orchestrator.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/repositories/sync_state_repository.dart';
import '../../domain/services/sync_conflict_resolver.dart';
import '../repositories/in_memory_sync_state_repository.dart';

final class SyncModuleAdapter {
  const SyncModuleAdapter({
    required this.module,
    required this.localRepository,
    required this.remoteRepository,
  });

  final SpiritualModule module;
  final SpiritualEntryRepository localRepository;
  final SyncRepository remoteRepository;
}

final class DefaultSyncOrchestrator implements SyncOrchestrator {
  DefaultSyncOrchestrator({
    required AuthRepository authRepository,
    required List<SyncModuleAdapter> modules,
    SyncStateRepository? syncStateRepository,
    DateTime Function()? now,
    SyncConflictResolver? conflictResolver,
  }) : _authRepository = authRepository,
       _modules = modules,
       _syncStateRepository =
           syncStateRepository ?? InMemorySyncStateRepository(),
       _now = now ?? DateTime.now,
       _conflictResolver = conflictResolver ?? const SyncConflictResolver();

  final AuthRepository _authRepository;
  final List<SyncModuleAdapter> _modules;
  final SyncStateRepository _syncStateRepository;
  final DateTime Function() _now;
  final SyncConflictResolver _conflictResolver;

  @override
  Future<void> syncAll() async {
    final user = await _authRepository.currentUser();
    if (user == null) return;

    await _mergeAnonymousDataOnFirstLogin(user.id);

    for (final module in _modules) {
      await _syncAdapter(user.id, module);
    }
  }

  @override
  Future<void> syncModule(String module) async {
    final user = await _authRepository.currentUser();
    if (user == null) return;

    await _mergeAnonymousDataOnFirstLogin(user.id);

    final adapter = _modules
        .where((item) => item.module.name == module)
        .firstOrNull;
    if (adapter == null) return;
    await _syncAdapter(user.id, adapter);
  }

  Future<void> _mergeAnonymousDataOnFirstLogin(String userId) async {
    final alreadyMerged = await _syncStateRepository.isFirstLoginMerged(userId);
    if (alreadyMerged) return;

    for (final adapter in _modules) {
      final local = await adapter.localRepository.listLocal(
        includeDeleted: true,
      );
      for (final entry in local) {
        if (entry.userId != null && entry.userId != userId) continue;
        if (entry.userId == userId) continue;

        await adapter.localRepository.saveLocal(
          entry.copyWith(userId: userId, isDirty: true),
        );
      }
    }

    await _syncStateRepository.markFirstLoginMerged(userId);
  }

  Future<void> _syncAdapter(String userId, SyncModuleAdapter adapter) async {
    final now = _now().toUtc();

    try {
      final since = await _syncStateRepository.getLastPullAt(adapter.module);

      final localBeforePull = await adapter.localRepository.listLocal(
        includeDeleted: true,
      );
      final localById = <String, SpiritualEntry>{
        for (final entry in localBeforePull) entry.id: entry,
      };

      final remoteChanges = await adapter.remoteRepository.pullChanges(
        since: since,
        userId: userId,
      );

      for (final remoteEntry in remoteChanges) {
        final localEntry = localById[remoteEntry.id];
        if (localEntry == null ||
            _conflictResolver.preferRemote(
              remoteUpdatedAt: remoteEntry.updatedAt,
              localUpdatedAt: localEntry.updatedAt,
            )) {
          await adapter.localRepository.saveLocal(
            remoteEntry.copyWith(
              userId: userId,
              isDirty: false,
              lastSyncedAt: now,
            ),
          );
        }
      }

      await _syncStateRepository.setLastPullAt(adapter.module, now);

      final dirtyEntries = await adapter.localRepository.listDirty();
      final pushed = await adapter.remoteRepository.pushChanges(
        localChanges: dirtyEntries,
        userId: userId,
      );

      for (final item in pushed) {
        await adapter.localRepository.saveLocal(
          item.copyWith(userId: userId, isDirty: false, lastSyncedAt: now),
        );
      }

      await _syncStateRepository.setLastPushAt(adapter.module, now);
      await _syncStateRepository.setLastError(adapter.module, null);
    } catch (error) {
      await _syncStateRepository.setLastError(adapter.module, error.toString());
      rethrow;
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
