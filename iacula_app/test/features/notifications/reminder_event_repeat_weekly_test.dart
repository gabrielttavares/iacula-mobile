import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';

void main() {
  test('repeatWeekly defaults to false and round-trips through map', () {
    final event = ReminderEvent(
      type: ReminderEventType.quoteInterval,
      title: 'Iacula',
      body: 'Glória ao Pai.',
      scheduledAt: DateTime(2026, 1, 1),
      withVibration: true,
      isAlarm: false,
    );
    expect(event.repeatWeekly, isFalse);

    final weekly = event.copyWith(repeatWeekly: true);
    expect(weekly.repeatWeekly, isTrue);

    final restored = ReminderEvent.fromMap(weekly.toMap());
    expect(restored.repeatWeekly, isTrue);
  });
}
