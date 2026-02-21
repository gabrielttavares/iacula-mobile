import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';

void main() {
  test('serializes and restores notification payload', () {
    final event = ReminderEvent(
      type: ReminderEventType.laudes,
      title: 'Laudes',
      body: 'Oficio do dia',
      scheduledAt: DateTime(2026, 2, 21, 6, 0),
      withVibration: true,
      isAlarm: true,
      repeatDaily: true,
    );

    final payload = NotificationActionEvent(actionId: null, event: event).toPayload();
    final restored = NotificationActionEvent.fromPayload(payload, fallbackActionId: NotificationActionEvent.snooze10Action);

    expect(restored, isNotNull);
    expect(restored!.actionId, NotificationActionEvent.snooze10Action);
    expect(restored.event.type, ReminderEventType.laudes);
    expect(restored.event.repeatDaily, isTrue);
  });
}
