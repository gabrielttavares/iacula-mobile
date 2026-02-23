import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:iacula_app/features/premium/infrastructure/supabase_premium_repository.dart';

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

final class _FakeLocalPremiumRepository implements PremiumRepository {
  _FakeLocalPremiumRepository(this.status);

  PremiumStatus status;
  final StreamController<PremiumStatus> _controller =
      StreamController<PremiumStatus>.broadcast();

  @override
  Future<PremiumStatus> getStatus() async => status;

  @override
  Future<void> unlockPremium(PremiumStatus value) async {
    status = value;
    _controller.add(value);
  }

  @override
  Future<bool> restorePurchases() async => status.isPremium;

  @override
  Stream<PremiumStatus> watchStatus() async* {
    yield status;
    yield* _controller.stream;
  }
}

final class _FakePremiumRemoteGateway implements PremiumRemoteGateway {
  PremiumStatus? remote;
  String? upsertUserId;
  PremiumStatus? upsertStatus;
  Object? fetchError;
  Object? upsertError;

  @override
  Future<PremiumStatus?> fetchForUser(String userId) async {
    if (fetchError != null) {
      throw fetchError!;
    }
    return remote;
  }

  @override
  Future<void> upsertForUser(String userId, PremiumStatus status) async {
    if (upsertError != null) {
      throw upsertError!;
    }
    upsertUserId = userId;
    upsertStatus = status;
    remote = status;
  }
}

void main() {
  test('getStatus pulls premium from remote when local is free', () async {
    final local = _FakeLocalPremiumRepository(PremiumStatus.free);
    final auth = _FakeAuthRepository(
      user: const AuthUser(id: 'user-1', email: 'u1@x.dev'),
    );
    final remote = _FakePremiumRemoteGateway()
      ..remote = const PremiumStatus(isPremium: true, userId: 'user-1');

    final repository = SyncedPremiumRepository(
      localRepository: local,
      authRepository: auth,
      remoteGateway: remote,
    );

    final status = await repository.getStatus();

    expect(status.isPremium, isTrue);
    expect((await local.getStatus()).isPremium, isTrue);
    expect((await local.getStatus()).userId, 'user-1');
  });

  test(
    'getStatus pushes local premium to remote when remote is empty',
    () async {
      final local = _FakeLocalPremiumRepository(
        const PremiumStatus(isPremium: true, userId: 'local-user'),
      );
      final auth = _FakeAuthRepository(
        user: const AuthUser(id: 'user-2', email: 'u2@x.dev'),
      );
      final remote = _FakePremiumRemoteGateway();

      final repository = SyncedPremiumRepository(
        localRepository: local,
        authRepository: auth,
        remoteGateway: remote,
      );

      final status = await repository.getStatus();

      expect(status.isPremium, isTrue);
      expect(status.userId, 'user-2');
      expect(remote.upsertUserId, 'user-2');
      expect(remote.upsertStatus?.isPremium, isTrue);
    },
  );

  test('unlockPremium writes local and remote with logged user link', () async {
    final local = _FakeLocalPremiumRepository(PremiumStatus.free);
    final auth = _FakeAuthRepository(
      user: const AuthUser(id: 'user-3', email: 'u3@x.dev'),
    );
    final remote = _FakePremiumRemoteGateway();

    final repository = SyncedPremiumRepository(
      localRepository: local,
      authRepository: auth,
      remoteGateway: remote,
    );

    await repository.unlockPremium(
      PremiumStatus(isPremium: true, purchaseDate: DateTime.utc(2026, 2, 23)),
    );

    expect((await local.getStatus()).userId, 'user-3');
    expect(remote.upsertUserId, 'user-3');
    expect(remote.upsertStatus?.userId, 'user-3');
  });

  test(
    'getStatus falls back to local status when remote fetch fails',
    () async {
      final local = _FakeLocalPremiumRepository(
        const PremiumStatus(isPremium: true, userId: 'local-user'),
      );
      final auth = _FakeAuthRepository(
        user: const AuthUser(id: 'user-4', email: 'u4@x.dev'),
      );
      final remote = _FakePremiumRemoteGateway()
        ..fetchError = Exception('offline');

      final repository = SyncedPremiumRepository(
        localRepository: local,
        authRepository: auth,
        remoteGateway: remote,
      );

      final status = await repository.getStatus();

      expect(status.isPremium, isTrue);
      expect(status.userId, 'local-user');
    },
  );

  test('unlockPremium keeps local state when remote upsert fails', () async {
    final local = _FakeLocalPremiumRepository(PremiumStatus.free);
    final auth = _FakeAuthRepository(
      user: const AuthUser(id: 'user-5', email: 'u5@x.dev'),
    );
    final remote = _FakePremiumRemoteGateway()
      ..upsertError = Exception('offline');

    final repository = SyncedPremiumRepository(
      localRepository: local,
      authRepository: auth,
      remoteGateway: remote,
    );

    await repository.unlockPremium(
      PremiumStatus(isPremium: true, purchaseDate: DateTime.utc(2026, 2, 23)),
    );

    expect((await local.getStatus()).isPremium, isTrue);
    expect((await local.getStatus()).userId, 'user-5');
  });
}
