import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/favorites/infrastructure/repositories/in_memory_favorite_repository.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/presentation/notifications_screen.dart';

void main() {
  testWidgets('shows only Hoje as available day when there is no history', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(
            InMemoryNotificationHistoryRepository(),
          ),
          notificationHistoryNowProvider.overrideWith(
            (ref) => DateTime(2026, 2, 24, 10),
          ),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Ontem'), findsNothing);
    expect(find.text('23/02'), findsNothing);
  });

  testWidgets('shows today scheduled quote history empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(
            InMemoryNotificationHistoryRepository(),
          ),
          notificationHistoryNowProvider.overrideWith((ref) => DateTime(2026, 2, 24, 10)),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Citações de hoje'), findsOneWidget);
    expect(
      find.textContaining('As citações programadas para hoje aparecerão aqui'),
      findsOneWidget,
    );
    expect(find.text('Próximas notificações'), findsNothing);
    expect(find.text('Última notificação'), findsNothing);
  });

  testWidgets('shows only quotes scheduled up to the current moment', (tester) async {
    final repo = InMemoryNotificationHistoryRepository();
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Deus é amor.',
      theme: 'Amor',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 9, 45),
    ));
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Permanecei em mim.',
      theme: 'Confiança',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 8, 30),
    ));
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Ainda virá.',
      theme: 'Esperança',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 10, 30),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(repo),
          notificationHistoryNowProvider.overrideWith((ref) => DateTime(2026, 2, 24, 10)),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today_notifications_rail')), findsOneWidget);
    expect(find.text('Deus é amor.'), findsOneWidget);
    expect(find.text('Permanecei em mim.'), findsOneWidget);
    expect(find.text('Ainda virá.'), findsNothing);
    expect(find.text('Última notificação'), findsNothing);
  });

  testWidgets('collapses nearby duplicate quotes inside the configured interval', (
    tester,
  ) async {
    final repo = InMemoryNotificationHistoryRepository();
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Glória ao Pai, ao Filho e ao Espírito Santo.',
      theme: 'Doxologia',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 21, 18),
    ));
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Glória ao Pai, ao Filho e ao Espírito Santo.',
      theme: 'Doxologia',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 21, 16),
    ));
    await repo.add(NotificationHistoryEntry(
      quoteText: 'A minha alma tem sede do Deus vivente.',
      theme: 'Salmo',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 21, 33),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(repo),
          notificationHistoryNowProvider.overrideWith(
            (ref) => DateTime(2026, 2, 24, 21, 35),
          ),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Glória ao Pai, ao Filho e ao Espírito Santo.'),
      findsOneWidget,
    );
    expect(find.text('A minha alma tem sede do Deus vivente.'), findsOneWidget);
  });

  testWidgets('collapses duplicate quotes exactly one interval apart', (
    tester,
  ) async {
    final repo = InMemoryNotificationHistoryRepository();
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Glória ao Pai, ao Filho e ao Espírito Santo.',
      theme: 'Doxologia',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 21, 18),
    ));
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Glória ao Pai, ao Filho e ao Espírito Santo.',
      theme: 'Doxologia',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 21, 3),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(repo),
          notificationHistoryNowProvider.overrideWith(
            (ref) => DateTime(2026, 2, 24, 21, 35),
          ),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Glória ao Pai, ao Filho e ao Espírito Santo.'),
      findsOneWidget,
    );
  });

  testWidgets('collapses legacy burst rows with different quotes 1 minute apart', (
    tester,
  ) async {
    final repo = InMemoryNotificationHistoryRepository();
    await repo.add(NotificationHistoryEntry(
      quoteText: 'A minha alma tem sede do Deus vivente.',
      theme: 'Salmo',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 21, 35),
    ));
    await repo.add(NotificationHistoryEntry(
      quoteText:
          'Faça-se, cumpra-se, seja louvada e eternamente glorificada a justíssima e amabilíssima Vontade de Deus sobre todas as coisas. Assim seja.',
      theme: 'Vontade de Deus',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 21, 36),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(repo),
          notificationHistoryNowProvider.overrideWith(
            (ref) => DateTime(2026, 2, 24, 21, 40),
          ),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A minha alma tem sede do Deus vivente.'), findsNothing);
    expect(
      find.textContaining('Faça-se, cumpra-se, seja louvada e eternamente'),
      findsOneWidget,
    );
  });

  testWidgets('renders quote text as selectable for copying', (tester) async {
    final repo = InMemoryNotificationHistoryRepository();
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Permanecei em mim.',
      theme: 'Confiança',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 8, 30),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(repo),
          notificationHistoryNowProvider.overrideWith((ref) => DateTime(2026, 2, 24, 10)),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('today_notifications_rail')),
        matching: find.byType(SelectableText),
      ),
      findsWidgets,
    );
  });

  testWidgets('shows only past days that have history entries', (tester) async {
    final repo = InMemoryNotificationHistoryRepository();
    await repo.add(
      NotificationHistoryEntry(
        quoteText: 'No dia anterior.',
        theme: 'Esperança',
        season: 'ordinary',
        deliveredAt: DateTime(2026, 2, 23, 9, 30),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(repo),
          notificationHistoryNowProvider.overrideWith(
            (ref) => DateTime(2026, 2, 24, 10),
          ),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Ontem'), findsOneWidget);
    expect(find.text('22/02'), findsNothing);

    await tester.tap(find.text('Ontem'));
    await tester.pumpAndSettle();

    expect(find.text('No dia anterior.'), findsOneWidget);
    expect(
      find.textContaining('As citações programadas para hoje aparecerão aqui'),
      findsNothing,
    );
  });

  testWidgets(
    'notification history rail does not show theme or feast subtitle',
    (tester) async {
      final repo = InMemoryNotificationHistoryRepository();
      await repo.add(
        NotificationHistoryEntry(
          quoteText: 'Citação sem eco do subtítulo.',
          theme: 'TemaSecretoXYZ',
          season: 'ordinary',
          feastName: 'FestaSecretaABC',
          deliveredAt: DateTime(2026, 2, 24, 8, 30),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationHistoryRepositoryProvider.overrideWithValue(repo),
            notificationHistoryNowProvider.overrideWith(
              (ref) => DateTime(2026, 2, 24, 10),
            ),
            favoriteRepositoryProvider.overrideWithValue(
              InMemoryFavoriteRepository(),
            ),
          ],
          child: const CupertinoApp(home: NotificationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TemaSecretoXYZ'), findsNothing);
      expect(find.text('FestaSecretaABC'), findsNothing);
    },
  );

  testWidgets('notification history rail uses bookmark icon not heart', (
    tester,
  ) async {
    final repo = InMemoryNotificationHistoryRepository();
    await repo.add(
      NotificationHistoryEntry(
        quoteText: 'Uma citação.',
        theme: 'tema',
        season: 'ordinary',
        deliveredAt: DateTime(2026, 2, 24, 8, 30),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(repo),
          notificationHistoryNowProvider.overrideWith(
            (ref) => DateTime(2026, 2, 24, 10),
          ),
          favoriteRepositoryProvider.overrideWithValue(
            InMemoryFavoriteRepository(),
          ),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final rail = find.byKey(const Key('today_notifications_rail'));
    expect(
      find.descendant(of: rail, matching: find.byIcon(CupertinoIcons.heart)),
      findsNothing,
    );
    expect(
      find.descendant(of: rail, matching: find.byIcon(CupertinoIcons.bookmark)),
      findsOneWidget,
    );
  });

  testWidgets('notification history bookmark toggles favorite', (tester) async {
    final favRepo = InMemoryFavoriteRepository();
    final repo = InMemoryNotificationHistoryRepository();
    await repo.add(
      NotificationHistoryEntry(
        quoteText: 'Toggle me.',
        theme: 'tema',
        season: 'ordinary',
        deliveredAt: DateTime(2026, 2, 24, 8, 30),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(repo),
          notificationHistoryNowProvider.overrideWith(
            (ref) => DateTime(2026, 2, 24, 10),
          ),
          favoriteRepositoryProvider.overrideWithValue(favRepo),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final rail = find.byKey(const Key('today_notifications_rail'));
    expect(
      find.descendant(of: rail, matching: find.byIcon(CupertinoIcons.bookmark)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: rail, matching: find.byIcon(CupertinoIcons.bookmark_fill)),
      findsNothing,
    );

    await tester.tap(
      find.descendant(of: rail, matching: find.byType(CupertinoButton)).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: rail, matching: find.byIcon(CupertinoIcons.bookmark_fill)),
      findsOneWidget,
    );
    expect((await favRepo.listAll()).length, 1);

    await tester.tap(
      find.descendant(of: rail, matching: find.byType(CupertinoButton)).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: rail, matching: find.byIcon(CupertinoIcons.bookmark)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: rail, matching: find.byIcon(CupertinoIcons.bookmark_fill)),
      findsNothing,
    );
    expect((await favRepo.listAll()).length, 0);
  });
}
