import 'dart:async';

import '../../domain/entities/notification_action_event.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/entities/short_interval_reliability.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

final class InMemoryNotificationSchedulerRepository
    implements NotificationSchedulerRepository {
  static int _idForEvent(ReminderEvent event) {
    return event.scheduledId ?? _idForType(event.type);
  }

  static int _idForType(ReminderEventType type) {
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

  final Map<int, ReminderEvent> _events = {};
  final _controller = StreamController<NotificationActionEvent>.broadcast();

  /// Tests only: override to simulate exact-alarm denial.
  ShortIntervalReliability? shortIntervalReliabilityOverrideForTest;

  List<ReminderEvent> get events => List.unmodifiable(_events.values);

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;

  @override
  Future<void> schedule(ReminderEvent event) async {
    final id = _idForEvent(event);
    _events[id] = event.copyWith(scheduledId: id);
  }

  @override
  Future<void> scheduleWithId(int id, ReminderEvent event) async {
    _events[id] = event.copyWith(scheduledId: id);
  }

  @override
  Future<void> showNow(int id, ReminderEvent event) async {
    _events[id] = event.copyWith(scheduledId: id);
  }

  @override
  Future<void> cancelByType(ReminderEventType type) async {
    final id = _idForType(type);
    _events.remove(id);
  }

  @override
  Future<void> cancelById(int id) async {
    _events.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    _events.clear();
  }

  @override
  Future<List<int>> pendingNotificationIds() async {
    return _events.keys.toList();
  }

  @override
  Future<bool?> canScheduleExactNotifications() async => true;

  @override
  Future<bool?> requestExactAlarmsPermission() async => true;

  @override
  void resetScheduleTelemetry() {}

  @override
  Future<ShortIntervalReliability> evaluateShortIntervalReliability({
    required bool notificationsEnabled,
    required int intervalMinutes,
  }) async {
    if (!notificationsEnabled || intervalMinutes > 15) {
      return ShortIntervalReliability.ok;
    }
    return shortIntervalReliabilityOverrideForTest ?? ShortIntervalReliability.ok;
  }
}
