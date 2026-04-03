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

  test('preserves quote banner copy and home route through payload roundtrip', () {
    final event = ReminderEvent(
      type: ReminderEventType.quoteInterval,
      title: 'Iacula',
      body: 'Sede santos, porque eu sou santo.',
      scheduledAt: DateTime(2026, 2, 21, 10, 15),
      withVibration: true,
      isAlarm: false,
      routeTarget: NotificationRouteTarget.home,
    );

    final payload = NotificationActionEvent(actionId: null, event: event).toPayload();
    final restored = NotificationActionEvent.fromPayload(payload);

    expect(restored, isNotNull);
    expect(restored!.event.type, ReminderEventType.quoteInterval);
    expect(restored.event.title, event.title);
    expect(restored.event.body, event.body);
    expect(restored.event.routeTarget, NotificationRouteTarget.home);
  });

  test('preserves prayer slug through payload roundtrip', () {
    final event = ReminderEvent(
      type: ReminderEventType.angelusNoon,
      title: 'Angelus',
      body: 'Hora de rezar o Angelus.',
      scheduledAt: DateTime(2026, 2, 21, 12, 0),
      withVibration: true,
      isAlarm: true,
      repeatDaily: true,
      routeTarget: NotificationRouteTarget.prayer,
      prayerSlug: 'angelus',
    );

    final payload = NotificationActionEvent(actionId: null, event: event).toPayload();
    final restored = NotificationActionEvent.fromPayload(payload);

    expect(restored, isNotNull);
    expect(restored!.event.type, ReminderEventType.angelusNoon);
    expect(restored.event.routeTarget, NotificationRouteTarget.prayer);
    expect(restored.event.prayerSlug, 'angelus');
  });
}
