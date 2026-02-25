import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';

void main() {
  test('NotificationHistoryEntry holds quote and metadata', () {
    final entry = NotificationHistoryEntry(
      quoteText: 'Be not afraid.',
      theme: 'Coragem',
      season: 'ordinary',
      deliveredAt: DateTime(2026, 2, 24, 8, 30),
      imagePath: 'assets/seed/images/ordinary/1/img.jpg',
    );
    expect(entry.quoteText, 'Be not afraid.');
    expect(entry.deliveredAt.hour, 8);
  });

  test('fromLastDeliveredCard converts correctly', () {
    final entry = NotificationHistoryEntry(
      quoteText: 'Text',
      theme: 'theme',
      season: 'advent',
      deliveredAt: DateTime(2026, 1, 1),
    );
    expect(entry.season, 'advent');
  });
}
