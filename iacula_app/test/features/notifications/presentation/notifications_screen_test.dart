import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/presentation/notifications_screen.dart';

void main() {
  testWidgets('shows today quote history empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(
            InMemoryNotificationHistoryRepository(),
          ),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Notificações de hoje'), findsOneWidget);
    expect(find.textContaining('Nenhuma citação recebida hoje'), findsOneWidget);
    expect(find.text('Próximas notificações'), findsNothing);
    expect(find.text('Última notificação'), findsNothing);
  });

  testWidgets('shows today quote history rail entries', (tester) async {
    final repo = InMemoryNotificationHistoryRepository();
    final now = DateTime.now();
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Deus é amor.',
      theme: 'Amor',
      season: 'ordinary',
      deliveredAt: DateTime(now.year, now.month, now.day, 10),
    ));
    await repo.add(NotificationHistoryEntry(
      quoteText: 'Permanecei em mim.',
      theme: 'Confiança',
      season: 'ordinary',
      deliveredAt: DateTime(now.year, now.month, now.day, 8, 30),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationHistoryRepositoryProvider.overrideWithValue(repo),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today_notifications_rail')), findsOneWidget);
    expect(find.text('Deus é amor.'), findsOneWidget);
    expect(find.text('Permanecei em mim.'), findsOneWidget);
    expect(find.text('Última notificação'), findsNothing);
  });
}
