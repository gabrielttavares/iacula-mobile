import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/shell_screen.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:iacula_app/features/premium/infrastructure/purchase_service.dart';
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
  final StreamController<PurchaseDetails> _controller =
      StreamController<PurchaseDetails>.broadcast();

  @override
  Stream<PurchaseDetails> get purchaseStream => _controller.stream;

  @override
  Future<bool> purchasePremium(String productId) async => false;

  @override
  Future<bool> restorePurchases() async => false;

  @override
  Future<void> completePurchase(PurchaseDetails details) async {}

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  testWidgets('tab bar shows "Meditação"', (
    tester,
  ) async {
    final purchaseService = _FakePurchaseService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumRepositoryProvider.overrideWithValue(_FakePremiumRepository()),
          purchaseServiceProvider.overrideWithValue(purchaseService),
        ],
        child: const CupertinoApp(
          localizationsDelegates: [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [Locale('pt', 'BR'), Locale('en')],
          home: ShellScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Meditação'), findsOneWidget);

    await purchaseService.dispose();
  });
}
