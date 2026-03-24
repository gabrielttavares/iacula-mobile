import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
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
}
