import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/auth/infrastructure/repositories/in_memory_auth_repository.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:iacula_app/features/premium/infrastructure/purchase_service.dart';
import 'package:iacula_app/features/premium/presentation/paywall_screen.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final class _FakePremiumRepository implements PremiumRepository {
  @override
  Future<PremiumStatus> getStatus() async => PremiumStatus.free;

  @override
  Future<void> unlockPremium(PremiumStatus status) async {}

  @override
  Future<bool> restorePurchases() async => false;

  @override
  Stream<PremiumStatus> watchStatus() async* {
    yield PremiumStatus.free;
  }
}

final class _FakePurchaseService implements PurchaseService {
  final _controller = StreamController<PurchaseStatus>.broadcast();

  @override
  Stream<PurchaseStatus> get purchaseStream => _controller.stream;

  @override
  Future<bool> purchasePremium(String productId) async => false;

  @override
  Future<bool> restorePurchases() async => false;
}

void main() {
  testWidgets('paywall does not advertise unimplemented features', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(InMemoryAuthRepository()),
          premiumRepositoryProvider.overrideWithValue(_FakePremiumRepository()),
          purchaseServiceProvider.overrideWithValue(_FakePurchaseService()),
        ],
        child: const MaterialApp(home: PaywallScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Should NOT mention features that don't exist
    expect(find.textContaining('Rosário'), findsNothing);
    expect(find.textContaining('Novena'), findsNothing);
    expect(find.textContaining('Configurações premium'), findsNothing);

    // Should mention features that DO exist
    expect(find.textContaining('Meditações'), findsOneWidget);
    expect(find.textContaining('Plano de vida'), findsOneWidget);
  });
}
