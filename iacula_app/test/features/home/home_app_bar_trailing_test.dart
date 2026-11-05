import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/shell_screen.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/presentation/notifications_screen.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

final class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Settings> load() async => Settings.defaults;

  @override
  Future<void> save(Settings settings) async {}
}

final class _FakeLastDeliveredCardRepository
    implements LastDeliveredCardRepository {
  @override
  Future<LastDeliveredCard?> load() async => LastDeliveredCard(
        quoteText: 'Permanecei em mim.',
        theme: 'Conversao',
        season: 'lent',
        deliveredAt: DateTime(2026, 2, 21, 11, 0),
      );

  @override
  Future<void> save(LastDeliveredCard card) async {}
}

// Pinned to the fake last-delivered card's day so the hero resolves from it
// instead of falling back to bundled quote assets (which never complete under
// the widget-test fake clock and would leave the hero shimmering forever).
final _fixedNow = DateTime(2026, 2, 21, 11, 30);

void main() {
  testWidgets('home nav bar trailing has notifications bell and search', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeNowProvider.overrideWithValue(_fixedNow),
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
          lastDeliveredCardRepositoryProvider.overrideWithValue(
            _FakeLastDeliveredCardRepository(),
          ),
        ],
        child: const CupertinoApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('home_notifications_button')), findsOneWidget);
    expect(find.byKey(const Key('home_search_button')), findsOneWidget);
  });

  testWidgets('home notifications bell opens NotificationsScreen from shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeNowProvider.overrideWithValue(_fixedNow),
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
          lastDeliveredCardRepositoryProvider.overrideWithValue(
            _FakeLastDeliveredCardRepository(),
          ),
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
    await tester.pump(const Duration(milliseconds: 350));

    // Notificações is no longer a bottom tab (replaced by Bíblia); it is
    // reached through the bell in the home header.
    expect(
      find.descendant(
        of: find.byType(CupertinoTabBar),
        matching: find.text('Notificações'),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('home_notifications_button')));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
  });
}
