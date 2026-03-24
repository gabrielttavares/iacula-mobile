import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/shell_screen.dart';
import 'package:iacula_app/features/premium/infrastructure/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
  testWidgets('default runtime can open Notificações tab without premium modal', (
    tester,
  ) async {
    final purchaseService = _FakePurchaseService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [purchaseServiceProvider.overrideWithValue(purchaseService)],
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
    await tester.tap(find.text('Notificações'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Continue com o Premium'), findsNothing);

    final tabBar = tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar));
    expect(tabBar.currentIndex, 1);

    await purchaseService.dispose();
  });
}
