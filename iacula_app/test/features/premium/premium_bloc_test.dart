import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:iacula_app/features/premium/application/premium_bloc.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:iacula_app/features/premium/infrastructure/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final class _FakePremiumRepository implements PremiumRepository {
  _FakePremiumRepository(this._status);

  PremiumStatus _status;
  final StreamController<PremiumStatus> _controller =
      StreamController<PremiumStatus>.broadcast();

  @override
  Future<PremiumStatus> getStatus() async => _status;

  @override
  Future<void> unlockPremium(PremiumStatus status) async {
    _status = status;
    _controller.add(_status);
  }

  @override
  Future<bool> restorePurchases() async => _status.isPremium;

  @override
  Stream<PremiumStatus> watchStatus() async* {
    yield _status;
    yield* _controller.stream;
  }
}

final class _FakePurchaseService implements PurchaseService {
  _FakePurchaseService({required this.purchaseResult});

  final bool purchaseResult;
  final StreamController<PurchaseStatus> _controller =
      StreamController<PurchaseStatus>.broadcast();

  @override
  Stream<PurchaseStatus> get purchaseStream => _controller.stream;

  int purchaseCallCount = 0;
  int restoreCallCount = 0;

  @override
  Future<bool> purchasePremium(String productId) async {
    purchaseCallCount++;
    return purchaseResult;
  }

  @override
  Future<bool> restorePurchases() async {
    restoreCallCount++;
    return true;
  }

  void emit(PurchaseStatus status) {
    _controller.add(status);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.user});

  AuthUser? user;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  Future<AuthUser?> currentUser() async => user;

  @override
  Future<void> signInWithApple() async {
    user = const AuthUser(id: 'apple', email: 'apple@x.dev');
    _controller.add(user);
  }

  @override
  Future<void> signInWithGoogle() async {
    user = const AuthUser(id: 'google', email: 'google@x.dev');
    _controller.add(user);
  }

  @override
  Future<void> signInWithMicrosoft() async {
    user = const AuthUser(id: 'ms', email: 'ms@x.dev');
    _controller.add(user);
  }

  @override
  Future<void> signOut() async {
    user = null;
    _controller.add(null);
  }

  void emit(AuthUser? value) {
    user = value;
    _controller.add(value);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  test(
    'CheckPremium emits loading then free when repository is free',
    () async {
      final repository = _FakePremiumRepository(PremiumStatus.free);
      final purchase = _FakePurchaseService(purchaseResult: true);
      final bloc = PremiumBloc(
        repository: repository,
        purchaseService: purchase,
        authRepository: _FakeAuthRepository(),
      );

      final states = <PremiumState>[];
      final sub = bloc.states.listen(states.add);
      final nextFree = Completer<PremiumFree>();
      final freeSub = bloc.states.listen((state) {
        if (state is PremiumFree && !nextFree.isCompleted) {
          nextFree.complete(state);
        }
      });

      await bloc.add(const CheckPremium());
      await nextFree.future.timeout(const Duration(seconds: 2));

      expect(states, contains(isA<PremiumLoading>()));
      expect(states.any((state) => state is PremiumFree), isTrue);

      await freeSub.cancel();
      await sub.cancel();
      await purchase.dispose();
      await bloc.dispose();
    },
  );

  test('PurchasePremium emits error when purchase does not start', () async {
    final repository = _FakePremiumRepository(PremiumStatus.free);
    final purchase = _FakePurchaseService(purchaseResult: false);
    final bloc = PremiumBloc(
      repository: repository,
      purchaseService: purchase,
      authRepository: _FakeAuthRepository(
        user: const AuthUser(id: 'u1', email: 'u1@x.dev'),
      ),
    );

    final states = <PremiumState>[];
    final sub = bloc.states.listen(states.add);
    final nextError = Completer<PremiumError>();
    final errorSub = bloc.states.listen((state) {
      if (state is PremiumError && !nextError.isCompleted) {
        nextError.complete(state);
      }
    });

    await bloc.add(const PurchasePremium(productId: 'premium_lifetime'));
    final error = await nextError.future.timeout(const Duration(seconds: 2));

    expect(error, isA<PremiumError>());
    expect(states, contains(isA<PremiumLoading>()));

    await errorSub.cancel();
    await sub.cancel();
    await purchase.dispose();
    await bloc.dispose();
  });

  test('purchase stream purchased status unlocks premium', () async {
    final repository = _FakePremiumRepository(PremiumStatus.free);
    final purchase = _FakePurchaseService(purchaseResult: true);
    final bloc = PremiumBloc(
      repository: repository,
      purchaseService: purchase,
      authRepository: _FakeAuthRepository(),
    );

    final nextUnlocked = Completer<PremiumState>();
    final sub = bloc.states.listen((state) {
      if (state is PremiumUnlocked && !nextUnlocked.isCompleted) {
        nextUnlocked.complete(state);
      }
    });

    purchase.emit(PurchaseStatus.purchased);

    final unlocked = await nextUnlocked.future.timeout(
      const Duration(seconds: 2),
    );
    expect(unlocked, isA<PremiumUnlocked>());
    expect((await repository.getStatus()).isPremium, isTrue);

    await sub.cancel();
    await purchase.dispose();
    await bloc.dispose();
  });

  test('purchase stream links premium entitlement to logged user', () async {
    final repository = _FakePremiumRepository(PremiumStatus.free);
    final purchase = _FakePurchaseService(purchaseResult: true);
    final auth = _FakeAuthRepository(
      user: const AuthUser(id: 'user-42', email: 'u42@x.dev'),
    );
    final bloc = PremiumBloc(
      repository: repository,
      purchaseService: purchase,
      authRepository: auth,
    );

    final nextUnlocked = Completer<PremiumUnlocked>();
    final sub = bloc.states.listen((state) {
      if (state is PremiumUnlocked && !nextUnlocked.isCompleted) {
        nextUnlocked.complete(state);
      }
    });

    purchase.emit(PurchaseStatus.purchased);

    final unlocked = await nextUnlocked.future.timeout(
      const Duration(seconds: 2),
    );
    expect(unlocked.status.userId, 'user-42');
    expect((await repository.getStatus()).userId, 'user-42');

    await sub.cancel();
    await auth.dispose();
    await purchase.dispose();
    await bloc.dispose();
  });

  test('auth change triggers premium status reconciliation check', () async {
    final repository = _FakePremiumRepository(
      const PremiumStatus(isPremium: true, userId: 'user-9'),
    );
    final purchase = _FakePurchaseService(purchaseResult: true);
    final auth = _FakeAuthRepository();
    final bloc = PremiumBloc(
      repository: repository,
      purchaseService: purchase,
      authRepository: auth,
    );

    final nextUnlocked = Completer<PremiumUnlocked>();
    final sub = bloc.states.listen((state) {
      if (state is PremiumUnlocked && !nextUnlocked.isCompleted) {
        nextUnlocked.complete(state);
      }
    });

    auth.emit(const AuthUser(id: 'user-9', email: 'u9@x.dev'));

    final unlocked = await nextUnlocked.future.timeout(
      const Duration(seconds: 2),
    );
    expect(unlocked.status.isPremium, isTrue);

    await sub.cancel();
    await auth.dispose();
    await purchase.dispose();
    await bloc.dispose();
  });

  test(
    'PurchasePremium unauthenticated emits PremiumAuthRequired and skips purchase service',
    () async {
      final repository = _FakePremiumRepository(PremiumStatus.free);
      final purchase = _FakePurchaseService(purchaseResult: true);
      final auth = _FakeAuthRepository(); // user == null
      final bloc = PremiumBloc(
        repository: repository,
        purchaseService: purchase,
        authRepository: auth,
      );

      final next = Completer<PremiumState>();
      final sub = bloc.states.listen((state) {
        if (!next.isCompleted) next.complete(state);
      });

      await bloc.add(const PurchasePremium(productId: 'premium_lifetime'));
      final state = await next.future.timeout(const Duration(seconds: 2));

      expect(state, isA<PremiumAuthRequired>());
      expect(purchase.purchaseCallCount, 0);

      await sub.cancel();
      await auth.dispose();
      await purchase.dispose();
      await bloc.dispose();
    },
  );

  test(
    'PurchasePremium authenticated calls purchase service normally',
    () async {
      final repository = _FakePremiumRepository(PremiumStatus.free);
      final purchase = _FakePurchaseService(purchaseResult: true);
      final auth = _FakeAuthRepository(
        user: const AuthUser(id: 'u1', email: 'u1@x.dev'),
      );
      final bloc = PremiumBloc(
        repository: repository,
        purchaseService: purchase,
        authRepository: auth,
      );

      final next = Completer<PremiumState>();
      final sub = bloc.states.listen((state) {
        if (!next.isCompleted) next.complete(state);
      });

      await bloc.add(const PurchasePremium(productId: 'premium_lifetime'));
      await next.future.timeout(const Duration(seconds: 2));

      expect(purchase.purchaseCallCount, 1);

      await sub.cancel();
      await auth.dispose();
      await purchase.dispose();
      await bloc.dispose();
    },
  );

  test(
    'RestorePurchases unauthenticated emits PremiumAuthRequired and skips restore service',
    () async {
      final repository = _FakePremiumRepository(PremiumStatus.free);
      final purchase = _FakePurchaseService(purchaseResult: true);
      final auth = _FakeAuthRepository(); // user == null
      final bloc = PremiumBloc(
        repository: repository,
        purchaseService: purchase,
        authRepository: auth,
      );

      final next = Completer<PremiumState>();
      final sub = bloc.states.listen((state) {
        if (!next.isCompleted) next.complete(state);
      });

      await bloc.add(const RestorePurchases());
      final state = await next.future.timeout(const Duration(seconds: 2));

      expect(state, isA<PremiumAuthRequired>());
      expect(purchase.restoreCallCount, 0);

      await sub.cancel();
      await auth.dispose();
      await purchase.dispose();
      await bloc.dispose();
    },
  );
}
