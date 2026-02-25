import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/presentation/notifications_screen.dart';

void main() {
  testWidgets('shows empty state when no notifications exist', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lastDeliveredCardRepositoryProvider.overrideWithValue(
            InMemoryLastDeliveredCardRepository(),
          ),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Nenhuma notificação'), findsOneWidget);
  });

  testWidgets('shows last delivered card when available', (tester) async {
    final repo = InMemoryLastDeliveredCardRepository();
    await repo.save(LastDeliveredCard(
      quoteText: 'Deus é amor.',
      theme: 'Amor',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 10, 0),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lastDeliveredCardRepositoryProvider.overrideWithValue(repo),
        ],
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Deus é amor.'), findsOneWidget);
    expect(find.textContaining('Amor'), findsOneWidget);
  });
}
