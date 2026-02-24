import 'dart:async';

import 'package:iacula_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:iacula_app/features/premium/infrastructure/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

sealed class PremiumState {
  const PremiumState();
}

final class PremiumInitial extends PremiumState {
  const PremiumInitial();
}

final class PremiumLoading extends PremiumState {
  const PremiumLoading();
}

final class PremiumFree extends PremiumState {
  const PremiumFree();
}

final class PremiumUnlocked extends PremiumState {
  const PremiumUnlocked(this.status);

  final PremiumStatus status;
}

final class PremiumError extends PremiumState {
  const PremiumError(this.message);

  final String message;
}

final class PremiumAuthRequired extends PremiumState {
  const PremiumAuthRequired();
}

sealed class PremiumEvent {
  const PremiumEvent();
}

final class CheckPremium extends PremiumEvent {
  const CheckPremium();
}

final class PurchasePremium extends PremiumEvent {
  const PurchasePremium({required this.productId});

  final String productId;
}

final class RestorePurchases extends PremiumEvent {
  const RestorePurchases();
}

final class Logout extends PremiumEvent {
  const Logout();
}

final class PremiumBloc {
  PremiumBloc({
    required PremiumRepository repository,
    required PurchaseService purchaseService,
    required AuthRepository authRepository,
    DateTime Function()? now,
  }) : _repository = repository,
       _purchaseService = purchaseService,
       _authRepository = authRepository,
       _now = now ?? DateTime.now {
    _purchaseSubscription = _purchaseService.purchaseStream.listen(
      _handlePurchaseStatus,
    );
    _authSubscription = _authRepository.authStateChanges().listen((_) {
      unawaited(_checkPremium());
    });
  }

  final PremiumRepository _repository;
  final PurchaseService _purchaseService;
  final AuthRepository _authRepository;
  final DateTime Function() _now;

  final StreamController<PremiumState> _states =
      StreamController<PremiumState>.broadcast();
  late final StreamSubscription<PurchaseStatus> _purchaseSubscription;
  late final StreamSubscription _authSubscription;

  PremiumState _state = const PremiumInitial();

  PremiumState get state => _state;
  Stream<PremiumState> get states => _states.stream;

  Future<void> add(PremiumEvent event) async {
    switch (event) {
      case CheckPremium():
        await _checkPremium();
      case PurchasePremium():
        await _purchase(event.productId);
      case RestorePurchases():
        await _restore();
      case Logout():
        await _logout();
    }
  }

  Future<void> _checkPremium() async {
    _emit(const PremiumLoading());
    final status = await _reconcileStatusWithCurrentUser();
    if (status.isPremium) {
      _emit(PremiumUnlocked(status));
      return;
    }

    _emit(const PremiumFree());
  }

  Future<void> _purchase(String productId) async {
    final user = await _authRepository.currentUser();
    if (user == null) {
      _emit(const PremiumAuthRequired());
      return;
    }
    _emit(const PremiumLoading());
    final started = await _purchaseService.purchasePremium(productId);
    if (!started) {
      _emit(const PremiumError('Could not start purchase flow.'));
    }
  }

  Future<void> _restore() async {
    final user = await _authRepository.currentUser();
    if (user == null) {
      _emit(const PremiumAuthRequired());
      return;
    }
    _emit(const PremiumLoading());
    final started = await _purchaseService.restorePurchases();
    if (!started) {
      _emit(const PremiumError('Could not start restore flow.'));
      return;
    }

    final status = await _reconcileStatusWithCurrentUser();
    if (status.isPremium) {
      _emit(PremiumUnlocked(status));
      return;
    }

    _emit(const PremiumFree());
  }

  Future<void> _logout() async {
    await _repository.unlockPremium(PremiumStatus.free);
    _emit(const PremiumFree());
  }

  Future<void> _handlePurchaseStatus(PurchaseStatus status) async {
    switch (status) {
      case PurchaseStatus.pending:
        _emit(const PremiumLoading());
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final user = await _authRepository.currentUser();
        final unlocked = PremiumStatus(
          isPremium: true,
          purchaseDate: _now().toUtc(),
          userId: user?.id,
        );
        await _repository.unlockPremium(unlocked);
        _emit(PremiumUnlocked(unlocked));
      case PurchaseStatus.error:
        _emit(const PremiumError('Purchase failed.'));
      case PurchaseStatus.canceled:
        _emit(const PremiumFree());
    }
  }

  Future<void> dispose() async {
    await _purchaseSubscription.cancel();
    await _authSubscription.cancel();
    await _states.close();
  }

  void _emit(PremiumState value) {
    _state = value;
    _states.add(value);
  }

  Future<PremiumStatus> _reconcileStatusWithCurrentUser() async {
    final status = await _repository.getStatus();
    if (!status.isPremium) {
      return status;
    }

    final user = await _authRepository.currentUser();
    if (user == null || status.userId == user.id) {
      return status;
    }

    final linked = status.copyWith(userId: user.id);
    await _repository.unlockPremium(linked);
    return linked;
  }
}
