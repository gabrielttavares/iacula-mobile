import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
  static const reminderCategoryIdentifier = 'iacula_reminder';
  static const _globalGroupKey = 'iacula_global';
  static const _iosThreadIdentifier = 'iacula_global';

  final FlutterLocalNotificationsPlugin _plugin;
  final _controller = StreamController<NotificationActionEvent>.broadcast();

  static LocalNotificationSchedulerRepository? _singleton;

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;

  bool _permissionGranted = false;

  bool get permissionGranted => _permissionGranted;

  Future<bool> initialize({bool requestPermission = true}) async {
    _singleton = this;
    tzdata.initializeTimeZones();

    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      debugPrint(
        '[LocalNotificationScheduler] local timezone set to $currentTimeZone',
      );
    } catch (e) {
      debugPrint(
        '[LocalNotificationScheduler] Failed to set local timezone: $e',
      );
    }

    const android = AndroidInitializationSettings(_smallIcon);
    final ios = DarwinInitializationSettings(
      requestAlertPermission: requestPermission,
      requestBadgePermission: requestPermission,
      requestSoundPermission: requestPermission,
      notificationCategories: darwinNotificationCategories,
    );

    await _plugin.initialize(
      InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    if (!requestPermission) {
      _permissionGranted = false;
      return _permissionGranted;
    }

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted =
        await androidImpl?.requestNotificationsPermission() ?? true;

    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted =
        await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    _permissionGranted = androidGranted && iosGranted;
    debugPrint(
      '[LocalNotificationScheduler] initialize requestPermission=$requestPermission '
      'androidGranted=$androidGranted iosGranted=$iosGranted '
      'permissionGranted=$_permissionGranted',
    );
    return _permissionGranted;
  }

  Future<bool> checkPermission() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      _permissionGranted = await androidImpl.areNotificationsEnabled() ?? false;
      return _permissionGranted;
    }

    // iOS: re-check by attempting request (returns current state if already decided)
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImpl != null) {
      _permissionGranted =
          await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return _permissionGranted;
    }

    return _permissionGranted;
  }

  Future<bool> requestPermission() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      _permissionGranted =
          await androidImpl.requestNotificationsPermission() ?? false;
      return _permissionGranted;
    }

    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImpl != null) {
      _permissionGranted =
          await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return _permissionGranted;
    }

    return _permissionGranted;
  }

  @override
  Future<NotificationActionEvent?> getLaunchNotificationAction() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    final response = details.notificationResponse;
    if (response == null) return null;
    return NotificationActionEvent.fromPayload(
      response.payload,
      fallbackActionId: response.actionId,
    );
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

  /// Title passed to [FlutterLocalNotificationsPlugin] show/zonedSchedule.
  /// On Android, jaculatória notifications use an empty title so the shade shows
  /// only the app name (system) plus [ReminderEvent.body]; iOS keeps [ReminderEvent.title].
  static String notificationTitleForPlugin(ReminderEvent event) {
    if (event.type == ReminderEventType.quoteInterval &&
        defaultTargetPlatform == TargetPlatform.android) {
      return '';
    }
    return event.title;
  }

  static AndroidNotificationDetails buildAndroidNotificationDetails(
    ReminderEvent event,
  ) {
    final requiresInteraction = requiresMandatoryInteraction(event.type);
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
      styleInformation: BigTextStyleInformation(event.body),
      ongoing: false,
      groupKey: _globalGroupKey,
      setAsGroupSummary: true,
      groupAlertBehavior: GroupAlertBehavior.summary,
      actions: requiresInteraction ? androidReminderActions : null,
    );
  }

  static DarwinNotificationDetails buildDarwinNotificationDetails(
    ReminderEvent event,
  ) {
    final requiresInteraction = requiresMandatoryInteraction(event.type);
    return DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      categoryIdentifier: requiresInteraction
          ? reminderCategoryIdentifier
          : null,
      threadIdentifier: _iosThreadIdentifier,
      interruptionLevel: requiresInteraction || event.isAlarm
          ? InterruptionLevel.timeSensitive
          : null,
      sound: event.isAlarm ? 'liturgy-reminder-soft.wav' : null,
    );
  }

  static bool requiresMandatoryInteraction(ReminderEventType type) {
    return switch (type) {
      ReminderEventType.quoteInterval ||
      ReminderEventType.angelusNoon ||
      ReminderEventType.customPhrase ||
      ReminderEventType.prayerIntentionReminder => true,
      ReminderEventType.laudes ||
      ReminderEventType.vespers ||
      ReminderEventType.compline ||
      ReminderEventType.oraMedia => false,
    };
  }

  static const List<AndroidNotificationAction> androidReminderActions =
      <AndroidNotificationAction>[
        AndroidNotificationAction(
          NotificationActionEvent.prayNowAction,
          'Rezar agora',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          NotificationActionEvent.snooze1hAction,
          'Adiar 1h',
        ),
      ];

  static final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          reminderCategoryIdentifier,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(
              NotificationActionEvent.prayNowAction,
              'Rezar agora',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              NotificationActionEvent.snooze1hAction,
              'Adiar 1h',
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.customDismissAction,
          },
        ),
      ];

  @override
  Future<void> schedule(ReminderEvent event) {
    final id = event.scheduledId ?? _idForType(event.type);
    return scheduleWithId(id, event);
  }

  @override
  Future<void> scheduleWithId(int id, ReminderEvent event) async {
    final androidDetails = buildAndroidNotificationDetails(event);

    final iosDetails = buildDarwinNotificationDetails(event);

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

    final title = notificationTitleForPlugin(event);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        event.body,
        scheduled,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: repeat,
      );
      debugPrint(
        '[LocalNotificationScheduler] scheduleWithId exactAllowWhileIdle id=$id type=${event.type.name} '
        'at=${event.scheduledAt.toIso8601String()} repeatDaily=${event.repeatDaily}',
      );
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') {
        rethrow;
      }


      debugPrint(
        '[LocalNotificationScheduler] scheduleWithId fell back to inexactAllowWhileIdle id=$id type=${event.type.name} '
        'at=${event.scheduledAt.toIso8601String()} repeatDaily=${event.repeatDaily}',
      );
      await _plugin.zonedSchedule(
        id,
        title,
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
  Future<void> showNow(int id, ReminderEvent event) async {
    final androidDetails = buildAndroidNotificationDetails(event);

    final iosDetails = buildDarwinNotificationDetails(event);

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final payload = NotificationActionEvent(
      actionId: null,
      event: event,
    ).toPayload();

    await _plugin.show(
      id,
      notificationTitleForPlugin(event),
      event.body,
      details,
      payload: payload,
    );
    debugPrint(
      '[LocalNotificationScheduler] showNow id=$id type=${event.type.name} at=${event.scheduledAt.toIso8601String()}',
    );
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
    debugPrint('[LocalNotificationScheduler] cancelAll requested');
    return _plugin.cancelAll();
  }

  @override
  Future<List<int>> pendingNotificationIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    final ids = pending.map((r) => r.id).toList();
    ids.sort();
    debugPrint(
      '[LocalNotificationScheduler] pendingNotificationIds count=${ids.length} ids=$ids',
    );
    return ids;
  }

  int _idForType(ReminderEventType type) {
    return switch (type) {
      ReminderEventType.quoteInterval => 100,
      ReminderEventType.angelusNoon => 200,
      ReminderEventType.laudes => 301,
      ReminderEventType.vespers => 302,
      ReminderEventType.compline => 303,
      ReminderEventType.oraMedia => 304,
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
      ReminderEventType.customPhrase => 'Notificações de frases personalizadas',
      ReminderEventType.prayerIntentionReminder =>
        'Lembretes para rezar por intenções',
    };
  }
}
