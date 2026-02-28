import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/auth/infrastructure/repositories/in_memory_auth_repository.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:iacula_app/features/premium/infrastructure/purchase_service.dart';
import 'package:iacula_app/features/premium/presentation/paywall_screen.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final class _FakePremiumRepository implements PremiumRepository {
  PremiumStatus _status = PremiumStatus.free;
  final _controller = StreamController<PremiumStatus>.broadcast();

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
  final _controller = StreamController<PurchaseDetails>.broadcast();
  int purchaseCallCount = 0;

  @override
  Stream<PurchaseDetails> get purchaseStream => _controller.stream;

  @override
  Future<bool> purchasePremium(String productId) async {
    purchaseCallCount++;
    return true;
  }

  @override
  Future<bool> restorePurchases() async => true;

  @override
  Future<void> completePurchase(PurchaseDetails details) async {}
}

Widget _buildPaywall({
  InMemoryAuthRepository? authRepo,
  _FakePremiumRepository? premiumRepo,
  _FakePurchaseService? purchaseService,
  AuthUser? initialUser,
}) {
  final auth = authRepo ?? InMemoryAuthRepository();
  final premium = premiumRepo ?? _FakePremiumRepository();
  final purchase = purchaseService ?? _FakePurchaseService();

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      premiumRepositoryProvider.overrideWithValue(premium),
      purchaseServiceProvider.overrideWithValue(purchase),
      if (initialUser != null)
        authStateProvider.overrideWith((ref) => Stream.value(initialUser)),
    ],
    child: const MaterialApp(home: PaywallScreen()),
  );
}

void main() {
  testWidgets(
    'unauthenticated paywall shows login CTA and no purchase dispatch',
    (tester) async {
      final purchase = _FakePurchaseService();

      await tester.pumpWidget(
        _buildPaywall(
          authRepo: InMemoryAuthRepository(),
          purchaseService: purchase,
        ),
      );
      await tester.pumpAndSettle();

      // Shows login CTA, not purchase CTA
      expect(find.text('Entrar para continuar'), findsOneWidget);
      expect(find.text('Desbloquear por R\$ 39,90'), findsNothing);

      // Tap login CTA — should not dispatch purchase
      await tester.tap(find.text('Entrar para continuar'));
      await tester.pumpAndSettle();

      // No snackbar with old error message
      expect(find.text('Entre em uma conta antes de comprar.'), findsNothing);
    },
  );

  testWidgets('authenticated paywall enables normal purchase flow', (
    tester,
  ) async {
    const user = AuthUser(id: 'u1', email: 'u1@x.dev');
    final auth = InMemoryAuthRepository(seed: user);
    final purchase = _FakePurchaseService();

    await tester.pumpWidget(
      _buildPaywall(
        authRepo: auth,
        purchaseService: purchase,
        initialUser: user,
      ),
    );
    await tester.pumpAndSettle();

    // Shows purchase CTA
    expect(find.text('Desbloquear por R\$ 39,90'), findsOneWidget);
    expect(find.text('Entrar para continuar'), findsNothing);

    // Tap purchase CTA
    await tester.tap(find.text('Desbloquear por R\$ 39,90'));
    await tester.pumpAndSettle();

    // Purchase service was called
    expect(purchase.purchaseCallCount, 1);
  });

  testWidgets('pending purchase auto-resumes after login', (tester) async {
    final auth = InMemoryAuthRepository(); // unauthenticated
    final purchase = _FakePurchaseService();

    await tester.pumpWidget(
      _buildPaywall(authRepo: auth, purchaseService: purchase),
    );
    await tester.pumpAndSettle();

    // Tap login CTA to set pending intent and trigger sign-in
    await tester.tap(find.text('Entrar para continuar'));
    await tester.pumpAndSettle();

    // signInWithGoogle sets user and emits on authStateChanges,
    // which triggers the pending purchase auto-resume
    // Give time for the listener to fire
    await tester.pumpAndSettle();

    // Purchase should have been auto-dispatched
    expect(purchase.purchaseCallCount, 1);
  });
}
