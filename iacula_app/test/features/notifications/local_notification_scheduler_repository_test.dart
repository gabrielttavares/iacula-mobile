import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('notificationTitleForPlugin', () {
    final quoteEvent = ReminderEvent(
      type: ReminderEventType.quoteInterval,
      title: 'Iacula',
      body: 'Quote text',
      scheduledAt: DateTime(2026, 4, 10, 8),
      withVibration: true,
      isAlarm: false,
    );

    test('quote interval on Android uses empty title for plugin', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      expect(
        LocalNotificationSchedulerRepository.notificationTitleForPlugin(
          quoteEvent,
        ),
        '',
      );
    });

    test('quote interval on iOS keeps event title', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      expect(
        LocalNotificationSchedulerRepository.notificationTitleForPlugin(
          quoteEvent,
        ),
        'Iacula',
      );
    });

    test('non-quote types on Android keep event title', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final event = ReminderEvent(
        type: ReminderEventType.angelusNoon,
        title: 'Angelus',
        body: 'Hora de rezar o Angelus.',
        scheduledAt: DateTime(2026, 4, 10, 12),
        withVibration: true,
        isAlarm: true,
      );

      expect(
        LocalNotificationSchedulerRepository.notificationTitleForPlugin(event),
        'Angelus',
      );
    });
  });

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

    test(
      'quote reminders use time sensitive interruption and reminder category',
      () {
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

        expect(details.interruptionLevel, InterruptionLevel.timeSensitive);
        expect(
          details.categoryIdentifier,
          LocalNotificationSchedulerRepository.reminderCategoryIdentifier,
        );
        expect(details.sound, isNull);
        expect(details.presentAlert, isTrue);
        expect(details.presentSound, isTrue);
      },
    );
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
      expect(details.actions, hasLength(2));
      expect(details.actions![0].id, 'pray_now');
      expect(details.actions![0].title, 'Rezar agora');
      expect(details.actions![0].showsUserInterface, isTrue);
      // Second action is the engagement 'Rezei' (replaced the dead snooze).
      expect(details.actions![1].id, 'rezei');
      expect(details.actions![1].title, 'Rezei 🙏');
      expect(details.actions![1].showsUserInterface, isTrue);
      expect(details.fullScreenIntent, isFalse);
      expect(details.category, isNull);
      expect(details.ongoing, isFalse);
    });

    test('angelus alarm uses fullScreenIntent and alarm category', () {
      final event = ReminderEvent(
        type: ReminderEventType.angelusNoon,
        title: 'Angelus',
        body: 'Hora de rezar o Angelus.',
        scheduledAt: DateTime(2026, 4, 10, 12),
        withVibration: true,
        isAlarm: true,
      );

      final details =
          LocalNotificationSchedulerRepository.buildAndroidNotificationDetails(
            event,
          );

      expect(details.fullScreenIntent, isTrue);
      expect(details.category, AndroidNotificationCategory.alarm);
      expect(details.actions, hasLength(2));
    });

    test('customPhrase does not use fullScreenIntent but keeps actions', () {
      final event = ReminderEvent(
        type: ReminderEventType.customPhrase,
        title: 'Frase Pessoal',
        body: 'My phrase',
        scheduledAt: DateTime(2026, 4, 10, 8),
        withVibration: true,
        isAlarm: false,
      );

      final details =
          LocalNotificationSchedulerRepository.buildAndroidNotificationDetails(
            event,
          );

      expect(details.fullScreenIntent, isFalse);
      expect(details.category, isNull);
      expect(details.actions, hasLength(2));
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
