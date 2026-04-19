import '../../domain/entities/notification_action_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

final class HandleNotificationActionUseCase {
  const HandleNotificationActionUseCase(this._scheduler);

  final NotificationSchedulerRepository _scheduler;
  static const int maxConsecutiveSnoozes = 3;

  Future<bool> call(NotificationActionEvent action) async {
    switch (action.actionId) {
      case NotificationActionEvent.snooze1hAction:
      case NotificationActionEvent.dismissAction:
      case NotificationActionEvent.snooze10Action:
        await _snoozeOneHour(action);
        return false;
    }

    return true;
  }

  Future<void> _snoozeOneHour(NotificationActionEvent action) async {
    if (action.event.snoozeCount >= maxConsecutiveSnoozes) return;

    final snoozed = action.event.copyWith(
      scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      repeatDaily: false,
      snoozeCount: action.event.snoozeCount + 1,
    );
    await _scheduler.schedule(snoozed);
  }
}
