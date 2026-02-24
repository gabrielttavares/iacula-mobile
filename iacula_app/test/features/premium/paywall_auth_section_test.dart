import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/auth/domain/entities/auth_user.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:iacula_app/features/premium/presentation/paywall_screen.dart';

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
    _controller.add(status);
  }

  @override
  Future<bool> restorePurchases() async => _status.isPremium;

  @override
  Stream<PremiumStatus> watchStatus() async* {
    yield _status;
    yield* _controller.stream;
  }
}

void main() {
  group('PaywallScreen Auth Section', () {
    testWidgets('shows login CTA when logged out', (tester) async {
      final premiumRepository = _FakePremiumRepository(PremiumStatus.free);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumRepositoryProvider.overrideWithValue(premiumRepository),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: PaywallScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Entrar para comprar'), findsOneWidget);
      expect(find.text('Comprar por R\$ 29,90'), findsNothing);
      expect(find.text('Restaurar compras'), findsNothing);
    });

    testWidgets('shows purchase CTA when logged in', (tester) async {
      final premiumRepository = _FakePremiumRepository(PremiumStatus.free);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumRepositoryProvider.overrideWithValue(premiumRepository),
            authStateProvider.overrideWith(
              (ref) => Stream.value(const AuthUser(id: '1', email: 'user@example.com')),
            ),
          ],
          child: const MaterialApp(home: PaywallScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Comprar por R\$ 29,90'), findsOneWidget);
      expect(find.text('Restaurar compras'), findsOneWidget);
      expect(find.text('Entrar para comprar'), findsNothing);
    });
  });
}
