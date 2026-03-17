import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart';

void main() {
  group('LocalNotificationSchedulerRepository Android details', () {
    test('uses small icon only (no large icon) for quote reminders', () {
      final event = ReminderEvent(
        type: ReminderEventType.quoteInterval,
        title: '',
        body: 'Quote body',
        scheduledAt: DateTime(2026, 2, 22, 8),
        withVibration: true,
        isAlarm: false,
      );

      final details =
          LocalNotificationSchedulerRepository.buildAndroidNotificationDetails(
            event,
          );

      expect(details.icon, 'ic_notification');
      expect(details.largeIcon, isNull);
      expect(details.channelId, 'quotes_reminder');
      expect(details.actions, hasLength(1));
      expect(details.actions!.first.title, 'Abrir');
    });

    test('keeps alarm actions and liturgy channel mapping unchanged', () {
      final event = ReminderEvent(
        type: ReminderEventType.oraMedia,
        title: 'Hora Média',
        body: 'Hora de rezar',
        scheduledAt: DateTime(2026, 2, 22, 9),
        withVibration: true,
        isAlarm: true,
      );

      final details =
          LocalNotificationSchedulerRepository.buildAndroidNotificationDetails(
            event,
          );

      expect(details.channelId, 'liturgy_hours_alarm');
      expect(details.actions, hasLength(2));
      expect(details.actions!.map((action) => action.id), [
        NotificationActionEvent.openAction,
        NotificationActionEvent.snooze10Action,
      ]);
    });
  });
}
