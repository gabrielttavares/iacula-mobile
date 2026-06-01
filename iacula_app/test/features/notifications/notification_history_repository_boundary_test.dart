import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';

NotificationHistoryEntry entryAt(DateTime deliveredAt, {String text = 'q'}) =>
    NotificationHistoryEntry(
      quoteText: text,
      theme: 'tema',
      season: 'ordinary',
      deliveredAt: deliveredAt,
    );

void main() {
  // Regression: the rebuild path reuses a slot's cached quote only if
  // listFromUntilEndOfDay returns the row at that fire time. When a rebuild
  // ran at exactly a slot instant, a strict `> instant` boundary excluded the
  // row, so the slot was treated as new — redrawn from the shuffle bag and
  // written as a duplicate history row carrying a different quote than the OS
  // notification had already been scheduled with. The boundary must be
  // inclusive (`>= instant`) so the row at exactly `instant` is reused.
  group('InMemoryNotificationHistoryRepository.listFromUntilEndOfDay', () {
    test('includes an entry whose delivered_at equals the query instant',
        () async {
      final repository = InMemoryNotificationHistoryRepository();
      final slotInstant = DateTime(2026, 5, 31, 8, 0);
      await repository.add(entryAt(slotInstant, text: 'original'));

      final results = await repository.listFromUntilEndOfDay(slotInstant);

      expect(results, hasLength(1));
      expect(results.single.quoteText, 'original');
    });

    test('includes future entries within the same calendar day', () async {
      final repository = InMemoryNotificationHistoryRepository();
      final queryInstant = DateTime(2026, 5, 31, 8, 0);
      await repository.add(entryAt(queryInstant, text: 'at-boundary'));
      await repository
          .add(entryAt(DateTime(2026, 5, 31, 9, 0), text: 'later-today'));

      final results = await repository.listFromUntilEndOfDay(queryInstant);

      expect(results.map((entry) => entry.quoteText), [
        'at-boundary',
        'later-today',
      ]);
    });

    test('excludes entries earlier the same day than the query instant',
        () async {
      final repository = InMemoryNotificationHistoryRepository();
      await repository
          .add(entryAt(DateTime(2026, 5, 31, 7, 0), text: 'already-fired'));
      final queryInstant = DateTime(2026, 5, 31, 8, 0);
      await repository.add(entryAt(queryInstant, text: 'at-boundary'));

      final results = await repository.listFromUntilEndOfDay(queryInstant);

      expect(results.map((entry) => entry.quoteText), ['at-boundary']);
    });

    test('excludes entries from the next calendar day', () async {
      final repository = InMemoryNotificationHistoryRepository();
      final queryInstant = DateTime(2026, 5, 31, 8, 0);
      await repository.add(entryAt(queryInstant, text: 'today'));
      await repository
          .add(entryAt(DateTime(2026, 6, 1, 0, 0), text: 'tomorrow'));

      final results = await repository.listFromUntilEndOfDay(queryInstant);

      expect(results.map((entry) => entry.quoteText), ['today']);
    });
  });
}
