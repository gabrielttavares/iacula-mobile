import '../entities/notification_action_event.dart';
import '../entities/reminder_event.dart';

abstract interface class NotificationSchedulerRepository {
  Stream<NotificationActionEvent> get actions;

  Future<void> schedule(ReminderEvent event);
  Future<void> scheduleWithId(int id, ReminderEvent event);
  Future<void> showNow(int id, ReminderEvent event);
  Future<void> cancelByType(ReminderEventType type);
  Future<void> cancelById(int id);
  Future<void> cancelAll();

  /// Android: whether exact alarms are permitted. Null on other platforms or unknown.
  Future<bool?> canScheduleExactNotifications();

  /// Android: request [SCHEDULE_EXACT_ALARM]. Null when not applicable.
  Future<bool?> requestExactAlarmsPermission();

  void resetScheduleTelemetry();
}
