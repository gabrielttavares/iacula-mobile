import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../../domain/repositories/sync_orchestrator.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/services/sync_conflict_resolver.dart';

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
    DateTime Function()? now,
    SyncConflictResolver? conflictResolver,
  })  : _authRepository = authRepository,
        _modules = modules,
        _now = now ?? DateTime.now,
        _conflictResolver = conflictResolver ?? const SyncConflictResolver();

  final AuthRepository _authRepository;
  final List<SyncModuleAdapter> _modules;
  final DateTime Function() _now;
  final SyncConflictResolver _conflictResolver;

  @override
  Future<void> syncAll() async {
    for (final module in _modules) {
      await _syncAdapter(module);
    }
  }

  @override
  Future<void> syncModule(String module) async {
    final adapter = _modules.where((item) => item.module.name == module).firstOrNull;
    if (adapter == null) return;
    await _syncAdapter(adapter);
  }

  Future<void> _syncAdapter(SyncModuleAdapter adapter) async {
    final user = await _authRepository.currentUser();
    if (user == null) return;

    final now = _now();
    final localBeforePull = await adapter.localRepository.listLocal(includeDeleted: true);
    final localById = <String, SpiritualEntry>{
      for (final entry in localBeforePull) entry.id: entry,
    };

    final remoteChanges = await adapter.remoteRepository.pullChanges(
      since: null,
      userId: user.id,
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
            userId: user.id,
            isDirty: false,
            lastSyncedAt: now,
          ),
        );
      }
    }

    final dirtyEntries = await adapter.localRepository.listDirty();
    final pushed = await adapter.remoteRepository.pushChanges(
      localChanges: dirtyEntries,
      userId: user.id,
    );

    for (final item in pushed) {
      await adapter.localRepository.saveLocal(
        item.copyWith(
          userId: user.id,
          isDirty: false,
          lastSyncedAt: now,
        ),
      );
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
