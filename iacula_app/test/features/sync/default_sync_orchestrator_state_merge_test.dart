import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import 'package:iacula_app/features/sync/domain/repositories/sync_repository.dart';
import 'package:iacula_app/features/sync/domain/repositories/sync_state_repository.dart';
import 'package:iacula_app/features/sync/infrastructure/services/default_sync_orchestrator.dart';

void main() {
  test(
    'uses last pull from sync state and updates pull/push checkpoints',
    () async {
      final stateRepo = _FakeSyncStateRepository(
        lastPullByModule: {
          SpiritualModule.planOfLife: DateTime.utc(2026, 2, 22, 8),
        },
      );
      final localRepo = _FakeLocalRepo(
        SpiritualModule.planOfLife,
        seed: const [],
      );
      final remoteRepo = _FakeRemoteRepo(
        module: SpiritualModule.planOfLife,
        pulled: const [],
      );

      final orchestrator = DefaultSyncOrchestrator(
        authRepository: _FakeAuthRepository(
          user: const AuthUser(id: 'user-1', email: 'u@x.dev'),
        ),
        modules: [
          SyncModuleAdapter(
            module: SpiritualModule.planOfLife,
            localRepository: localRepo,
            remoteRepository: remoteRepo,
          ),
        ],
        syncStateRepository: stateRepo,
        now: () => DateTime.utc(2026, 2, 22, 9),
      );

      await orchestrator.syncAll();

      expect(remoteRepo.lastSince, DateTime.utc(2026, 2, 22, 8));
      expect(
        stateRepo.lastPullByModule[SpiritualModule.planOfLife],
        DateTime.utc(2026, 2, 22, 9),
      );
      expect(
        stateRepo.lastPushByModule[SpiritualModule.planOfLife],
        DateTime.utc(2026, 2, 22, 9),
      );
    },
  );

  test(
    'first login merge marks anonymous local data to user once (idempotent)',
    () async {
      final stateRepo = _FakeSyncStateRepository();
      final localRepo = _FakeLocalRepo(
        SpiritualModule.examination,
        seed: [
          SpiritualEntry(
            id: 'e1',
            module: SpiritualModule.examination,
            body: 'Anonymous note',
            createdAt: DateTime.utc(2026, 2, 22, 7),
            updatedAt: DateTime.utc(2026, 2, 22, 7),
            isDirty: false,
          ),
        ],
      );
      final remoteRepo = _FakeRemoteRepo(
        module: SpiritualModule.examination,
        pulled: const [],
      );

      final orchestrator = DefaultSyncOrchestrator(
        authRepository: _FakeAuthRepository(
          user: const AuthUser(id: 'user-1', email: 'u@x.dev'),
        ),
        modules: [
          SyncModuleAdapter(
            module: SpiritualModule.examination,
            localRepository: localRepo,
            remoteRepository: remoteRepo,
          ),
        ],
        syncStateRepository: stateRepo,
        now: () => DateTime.utc(2026, 2, 22, 9),
      );

      await orchestrator.syncAll();
      await orchestrator.syncAll();

      final local = await localRepo.listLocal(includeDeleted: true);
      expect(local.single.userId, 'user-1');
      expect(localRepo.mergeUpdates, 1);
      expect(stateRepo.mergedUsers.contains('user-1'), isTrue);
    },
  );
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.user});

  AuthUser? user;

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  Future<AuthUser?> currentUser() async => user;

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithMicrosoft() async {}

  @override
  Future<void> signOut() async {}
}

final class _FakeSyncStateRepository implements SyncStateRepository {
  _FakeSyncStateRepository({
    Map<SpiritualModule, DateTime>? lastPullByModule,
    Map<SpiritualModule, DateTime>? lastPushByModule,
  }) : lastPullByModule = lastPullByModule ?? <SpiritualModule, DateTime>{},
       lastPushByModule = lastPushByModule ?? <SpiritualModule, DateTime>{};

  final Map<SpiritualModule, DateTime> lastPullByModule;
  final Map<SpiritualModule, DateTime> lastPushByModule;
  final Set<String> mergedUsers = <String>{};

  @override
  Future<DateTime?> getLastPullAt(SpiritualModule module) async =>
      lastPullByModule[module];

  @override
  Future<DateTime?> getLastPushAt(SpiritualModule module) async =>
      lastPushByModule[module];

  @override
  Future<bool> isFirstLoginMerged(String userId) async =>
      mergedUsers.contains(userId);

  @override
  Future<void> markFirstLoginMerged(String userId) async {
    mergedUsers.add(userId);
  }

  @override
  Future<void> setLastError(SpiritualModule module, String? error) async {}

  @override
  Future<void> setLastPullAt(SpiritualModule module, DateTime value) async {
    lastPullByModule[module] = value;
  }

  @override
  Future<void> setLastPushAt(SpiritualModule module, DateTime value) async {
    lastPushByModule[module] = value;
  }
}

final class _FakeLocalRepo implements SpiritualEntryRepository {
  _FakeLocalRepo(this.module, {required List<SpiritualEntry> seed})
    : _entries = List<SpiritualEntry>.from(seed);

  final List<SpiritualEntry> _entries;

  @override
  final SpiritualModule module;

  int mergeUpdates = 0;

  @override
  Future<List<SpiritualEntry>> listDirty() async {
    return _entries.where((entry) => entry.isDirty).toList(growable: false);
  }

  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async {
    return _entries
        .where((entry) => includeDeleted || entry.deletedAt == null)
        .toList(growable: false);
  }

  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {
    final i = _entries.indexWhere((entry) => entry.id == id);
    if (i == -1) return;
    _entries[i] = _entries[i].copyWith(isDirty: false, lastSyncedAt: syncedAt);
  }

  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {
    final i = _entries.indexWhere((entry) => entry.id == id);
    if (i == -1) return;
    _entries[i] = _entries[i].copyWith(
      deletedAt: deletedAt,
      updatedAt: deletedAt,
      isDirty: true,
    );
  }

  @override
  Future<void> saveLocal(SpiritualEntry entry) async {
    final i = _entries.indexWhere((existing) => existing.id == entry.id);
    if (i == -1) {
      _entries.add(entry);
      return;
    }

    if (_entries[i].userId != entry.userId && entry.userId != null) {
      mergeUpdates += 1;
    }

    _entries[i] = entry;
  }

  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {
    for (final entry in entries) {
      await saveLocal(entry);
    }
  }
}

final class _FakeRemoteRepo implements SyncRepository {
  _FakeRemoteRepo({required this.module, required this.pulled});

  final List<SpiritualEntry> pulled;

  @override
  final SpiritualModule module;

  DateTime? lastSince;

  @override
  Future<List<SpiritualEntry>> pullChanges({
    required DateTime? since,
    required String userId,
  }) async {
    lastSince = since;
    return pulled;
  }

  @override
  Future<List<SpiritualEntry>> pushChanges({
    required List<SpiritualEntry> localChanges,
    required String userId,
  }) async {
    return localChanges;
  }
}
