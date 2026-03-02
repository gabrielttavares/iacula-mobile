import '../entities/notification_action_event.dart';
import '../entities/reminder_event.dart';

abstract interface class NotificationSchedulerRepository {
  Stream<NotificationActionEvent> get actions;

  Future<void> schedule(ReminderEvent event);
  Future<void> scheduleWithId(int id, ReminderEvent event);
  Future<void> cancelByType(ReminderEventType type);
  Future<void> cancelById(int id);
  Future<void> cancelAll();
}
