import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import 'package:iacula_app/features/sync/domain/repositories/sync_repository.dart';
import 'package:iacula_app/features/sync/infrastructure/services/default_sync_orchestrator.dart';

void main() {
  test('syncAll runs pull before push and applies newer remote values', () async {
    final clockNow = DateTime.utc(2026, 2, 22, 16, 0);

    final localRepo = _FakeLocalRepo(
      SpiritualModule.planOfLife,
      seed: [
        SpiritualEntry(
          id: 'a',
          module: SpiritualModule.planOfLife,
          body: 'local old',
          createdAt: DateTime.utc(2026, 2, 22, 10),
          updatedAt: DateTime.utc(2026, 2, 22, 10),
          isDirty: true,
        ),
      ],
    );
    final remoteRepo = _FakeRemoteRepo(
      module: SpiritualModule.planOfLife,
      pulled: [
        SpiritualEntry(
          id: 'a',
          module: SpiritualModule.planOfLife,
          body: 'remote newer',
          createdAt: DateTime.utc(2026, 2, 22, 10),
          updatedAt: DateTime.utc(2026, 2, 22, 12),
          isDirty: false,
        ),
      ],
    );

    final orchestrator = DefaultSyncOrchestrator(
      authRepository: _FakeAuthRepository(user: const AuthUser(id: 'user-1', email: 'u@x.dev')),
      modules: [
        SyncModuleAdapter(
          module: SpiritualModule.planOfLife,
          localRepository: localRepo,
          remoteRepository: remoteRepo,
        ),
      ],
      now: () => clockNow,
    );

    await orchestrator.syncAll();

    expect(remoteRepo.callOrder, ['pull', 'push']);
    expect(remoteRepo.pushedBodies, isEmpty);

    final local = await localRepo.listLocal(includeDeleted: true);
    expect(local.single.body, 'remote newer');
    expect(local.single.isDirty, isFalse);
  });

  test('syncAll pushes dirty local tombstone when no newer remote version exists', () async {
    final localRepo = _FakeLocalRepo(
      SpiritualModule.prayerIntention,
      seed: [
        SpiritualEntry(
          id: 'p1',
          module: SpiritualModule.prayerIntention,
          body: 'Pray for family',
          createdAt: DateTime.utc(2026, 2, 22, 10),
          updatedAt: DateTime.utc(2026, 2, 22, 14),
          deletedAt: DateTime.utc(2026, 2, 22, 14),
          isDirty: true,
        ),
      ],
    );
    final remoteRepo = _FakeRemoteRepo(
      module: SpiritualModule.prayerIntention,
      pulled: const <SpiritualEntry>[],
    );

    final orchestrator = DefaultSyncOrchestrator(
      authRepository: _FakeAuthRepository(user: const AuthUser(id: 'user-1', email: 'u@x.dev')),
      modules: [
        SyncModuleAdapter(
          module: SpiritualModule.prayerIntention,
          localRepository: localRepo,
          remoteRepository: remoteRepo,
        ),
      ],
      now: () => DateTime.utc(2026, 2, 22, 16),
    );

    await orchestrator.syncAll();

    expect(remoteRepo.pushedBodies, ['Pray for family']);
    expect(remoteRepo.pushedDeletedAt.single, isNotNull);
  });
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

final class _FakeLocalRepo implements SpiritualEntryRepository {
  _FakeLocalRepo(this.module, {required List<SpiritualEntry> seed}) : _entries = List<SpiritualEntry>.from(seed);

  final List<SpiritualEntry> _entries;

  @override
  final SpiritualModule module;

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
    _entries[i] = _entries[i].copyWith(deletedAt: deletedAt, updatedAt: deletedAt, isDirty: true);
  }

  @override
  Future<void> saveLocal(SpiritualEntry entry) async {
    final i = _entries.indexWhere((existing) => existing.id == entry.id);
    if (i == -1) {
      _entries.add(entry);
      return;
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

  final List<String> callOrder = <String>[];
  final List<String> pushedBodies = <String>[];
  final List<DateTime?> pushedDeletedAt = <DateTime?>[];

  @override
  Future<List<SpiritualEntry>> pullChanges({required DateTime? since, required String userId}) async {
    callOrder.add('pull');
    return pulled;
  }

  @override
  Future<List<SpiritualEntry>> pushChanges({required List<SpiritualEntry> localChanges, required String userId}) async {
    callOrder.add('push');
    pushedBodies.addAll(localChanges.map((entry) => entry.body));
    pushedDeletedAt.addAll(localChanges.map((entry) => entry.deletedAt));
    return localChanges;
  }
}
