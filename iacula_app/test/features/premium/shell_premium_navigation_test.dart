import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/shell_screen.dart';
import 'package:iacula_app/features/notifications/presentation/notifications_screen.dart';
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
  testWidgets('free user tapping Notificações tab opens directly', (
    tester,
  ) async {
    final premiumRepository = _FakePremiumRepository(PremiumStatus.free);
    final purchaseService = _FakePurchaseService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumRepositoryProvider.overrideWithValue(premiumRepository),
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
    await tester.pump(const Duration(milliseconds: 100)); // wait for provider
    await tester.tap(find.text('Notificações'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.text('Continue com o Premium'), findsNothing);

    await purchaseService.dispose();
  });

  testWidgets(
    'free user tapping Mais tab navigates directly without premium gate',
    (tester) async {
      final premiumRepository = _FakePremiumRepository(PremiumStatus.free);
      final purchaseService = _FakePurchaseService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumRepositoryProvider.overrideWithValue(premiumRepository),
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
      await tester.pump(const Duration(milliseconds: 100)); // wait for provider

      // Tap on the Mais tab
      await tester.tap(find.text('Mais'));
      await tester.pump();

      // Verify premium modal is NOT shown
      expect(find.text('Continue com o Premium'), findsNothing);
      expect(find.text('Conhecer o Premium'), findsNothing);

      // Verify tab bar state updated to more index (3)
      final tabBar = tester.widget<CupertinoTabBar>(
        find.byType(CupertinoTabBar),
      );
      expect(tabBar.currentIndex, 3);

      await purchaseService.dispose();
    },
  );
}
