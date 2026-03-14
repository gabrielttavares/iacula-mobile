import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/notification_action_event.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  LocalNotificationSchedulerRepository.handleNotificationResponse(response);
}

final class LocalNotificationSchedulerRepository
    implements NotificationSchedulerRepository {
  LocalNotificationSchedulerRepository({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _smallIcon = 'ic_notification';

  final FlutterLocalNotificationsPlugin _plugin;
  final _controller = StreamController<NotificationActionEvent>.broadcast();

  static LocalNotificationSchedulerRepository? _singleton;

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;

  Future<void> initialize() async {
    _singleton = this;
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings(_smallIcon);
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();

    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static void handleNotificationResponse(NotificationResponse response) {
    final repo = _singleton;
    if (repo == null) return;

    final event = NotificationActionEvent.fromPayload(
      response.payload,
      fallbackActionId: response.actionId,
    );
    if (event != null) {
      repo._controller.add(event);
    }
  }

  static AndroidNotificationDetails buildAndroidNotificationDetails(
    ReminderEvent event,
  ) {
    final actions = event.isAlarm
        ? <AndroidNotificationAction>[
            const AndroidNotificationAction(
              NotificationActionEvent.openAction,
              'Abrir',
            ),
            const AndroidNotificationAction(
              NotificationActionEvent.snooze10Action,
              'Adiar 10 min',
            ),
          ]
        : <AndroidNotificationAction>[
            const AndroidNotificationAction(
              NotificationActionEvent.openAction,
              'Abrir',
            ),
          ];

    return AndroidNotificationDetails(
      _channelIdForType(event.type),
      _channelNameForType(event.type),
      channelDescription: _channelDescriptionForType(event.type),
      icon: _smallIcon,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: event.isAlarm,
      enableVibration: event.withVibration,
      category: event.isAlarm ? AndroidNotificationCategory.alarm : null,
      playSound: true,
      visibility: NotificationVisibility.public,
      actions: actions,
    );
  }

  @override
  Future<void> schedule(ReminderEvent event) async {
    final id = event.scheduledId ?? _idForType(event.type);
    final androidDetails = buildAndroidNotificationDetails(event);

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final scheduled = tz.TZDateTime.from(event.scheduledAt, tz.local);
    final payload = NotificationActionEvent(
      actionId: null,
      event: event,
    ).toPayload();
    final repeat = event.repeatDaily ? DateTimeComponents.time : null;

    try {
      await _plugin.zonedSchedule(
        id,
        event.title,
        event.body,
        scheduled,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: repeat,
      );
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') {
        rethrow;
      }

      await _plugin.zonedSchedule(
        id,
        event.title,
        event.body,
        scheduled,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: repeat,
      );
    }
  }

  @override
  Future<void> scheduleWithId(int id, ReminderEvent event) async {
    final androidDetails = buildAndroidNotificationDetails(event);

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final scheduled = tz.TZDateTime.from(event.scheduledAt, tz.local);
    final payload =
        NotificationActionEvent(actionId: null, event: event).toPayload();
    final repeat = event.repeatDaily ? DateTimeComponents.time : null;

    try {
      await _plugin.zonedSchedule(
        id,
        event.title,
        event.body,
        scheduled,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: repeat,
      );
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') {
        rethrow;
      }

      await _plugin.zonedSchedule(
        id,
        event.title,
        event.body,
        scheduled,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: repeat,
      );
    }
  }

  @override
  Future<void> cancelByType(ReminderEventType type) {
    return _plugin.cancel(_idForType(type));
  }

  @override
  Future<void> cancelById(int id) {
    return _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() {
    return _plugin.cancelAll();
  }

  int _idForType(ReminderEventType type) {
    return switch (type) {
      ReminderEventType.quoteInterval => 100,
      ReminderEventType.angelusNoon => 200,
      ReminderEventType.laudes => 301,
      ReminderEventType.vespers => 302,
      ReminderEventType.compline => 303,
      ReminderEventType.oraMedia => 304,
      ReminderEventType.customMeditationAlarm => 400,
      ReminderEventType.customPhrase => 1000,
      ReminderEventType.prayerIntentionReminder => 500,
    };
  }

  static String _channelIdForType(ReminderEventType type) {
    return switch (type) {
      ReminderEventType.quoteInterval => 'quotes_reminder',
      ReminderEventType.angelusNoon => 'angelus_noon',
      ReminderEventType.laudes ||
      ReminderEventType.vespers ||
      ReminderEventType.compline ||
      ReminderEventType.oraMedia => 'liturgy_hours_alarm',
      ReminderEventType.customMeditationAlarm => 'custom_meditation_alarm',
      ReminderEventType.customPhrase => 'custom_phrases',
      ReminderEventType.prayerIntentionReminder => 'prayer_intention_reminder',
    };
  }

  static String _channelNameForType(ReminderEventType type) {
    return switch (type) {
      ReminderEventType.quoteInterval => 'Jaculatórias',
      ReminderEventType.angelusNoon => 'Angelus',
      ReminderEventType.laudes ||
      ReminderEventType.vespers ||
      ReminderEventType.compline ||
      ReminderEventType.oraMedia => 'Liturgia das Horas',
      ReminderEventType.customMeditationAlarm => 'Meditação',
      ReminderEventType.customPhrase => 'Minhas frases',
      ReminderEventType.prayerIntentionReminder => 'Intenções',
    };
  }

  static String _channelDescriptionForType(ReminderEventType type) {
    return switch (type) {
      ReminderEventType.quoteInterval => 'Lembretes de jaculatórias',
      ReminderEventType.angelusNoon => 'Lembrete do meio-dia',
      ReminderEventType.laudes ||
      ReminderEventType.vespers ||
      ReminderEventType.compline ||
      ReminderEventType.oraMedia => 'Alarmes da Liturgia das Horas',
      ReminderEventType.customMeditationAlarm => 'Alarmes de meditação',
      ReminderEventType.customPhrase => 'Notificações de frases personalizadas',
      ReminderEventType.prayerIntentionReminder => 'Lembretes para rezar por intenções',
    };
  }
}
