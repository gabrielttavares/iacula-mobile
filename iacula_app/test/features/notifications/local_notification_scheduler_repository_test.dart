import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart';

void main() {
  group('LocalNotificationSchedulerRepository iOS details', () {
    test('alarm events use timeSensitive interruption and custom sound', () {
      final event = ReminderEvent(
        type: ReminderEventType.angelusNoon,
        title: 'Angelus',
        body: 'Hora de rezar o Angelus.',
        scheduledAt: DateTime(2026, 4, 10, 12),
        withVibration: true,
        isAlarm: true,
      );

      final details =
          LocalNotificationSchedulerRepository.buildDarwinNotificationDetails(
            event,
          );

      expect(details.interruptionLevel, InterruptionLevel.timeSensitive);
      expect(details.sound, 'liturgy-reminder-soft.wav');
      expect(details.presentAlert, isTrue);
      expect(details.presentSound, isTrue);
    });

    test('non-alarm events use default interruption and no custom sound', () {
      final event = ReminderEvent(
        type: ReminderEventType.quoteInterval,
        title: 'Iacula',
        body: 'Quote text',
        scheduledAt: DateTime(2026, 4, 10, 8),
        withVibration: true,
        isAlarm: false,
      );

      final details =
          LocalNotificationSchedulerRepository.buildDarwinNotificationDetails(
            event,
          );

      expect(details.interruptionLevel, isNull);
      expect(details.sound, isNull);
      expect(details.presentAlert, isTrue);
      expect(details.presentSound, isTrue);
    });
  });

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
      expect(details.actions, isNull);
      expect(details.ongoing, isFalse);
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
      expect(details.actions, isNull);
      expect(details.fullScreenIntent, isTrue);
      expect(details.ongoing, isFalse);
    });
  });
}
