import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';

void main() {
  test('quote payload restores home route target', () {
    final event = ReminderEvent(
      type: ReminderEventType.quoteInterval,
      title: 'Iacula',
      body: 'Sede santos',
      scheduledAt: DateTime(2026, 2, 21, 10, 15),
      withVibration: true,
      isAlarm: false,
      routeTarget: NotificationRouteTarget.home,
    );

    final payload = NotificationActionEvent(actionId: null, event: event).toPayload();
    final restored = NotificationActionEvent.fromPayload(payload);

    expect(restored, isNotNull);
    expect(restored!.event.routeTarget, NotificationRouteTarget.home);
  });

  test('legacy payload without routeTarget infers prayer route for noon event', () {
    final payload = NotificationActionEvent(
      actionId: null,
      event: ReminderEvent(
        type: ReminderEventType.quoteInterval,
        title: '',
        body: '',
        scheduledAt: DateTime.now(),
        withVibration: false,
        isAlarm: false,
      ),
    ).toPayload();

    final legacyPayload = payload
        .replaceFirst('"type":"quoteInterval"', '"type":"angelusNoon"')
        .replaceFirst('"title":""', '"title":"Angelus"')
        .replaceFirst('"body":""', '"body":"Rezar ao meio-dia"')
        .replaceFirst('"withVibration":false', '"withVibration":true')
        .replaceFirst('"isAlarm":false', '"isAlarm":true')
        .replaceFirst('"repeatDaily":false', '"repeatDaily":true')
        .replaceFirst(RegExp(r',"routeTarget":"[a-z]+"'), '');

    final restored = NotificationActionEvent.fromPayload(legacyPayload);

    expect(restored, isNotNull);
    expect(restored!.event.type, ReminderEventType.angelusNoon);
    expect(restored.event.routeTarget, NotificationRouteTarget.prayer);
  });
}
