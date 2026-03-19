import '../../domain/entities/notification_action_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

final class HandleNotificationActionUseCase {
  const HandleNotificationActionUseCase(this._scheduler);

  final NotificationSchedulerRepository _scheduler;

  Future<bool> call(NotificationActionEvent action) async {
    if (action.actionId == NotificationActionEvent.snooze10Action) {
      final snoozed = action.event.copyWith(
        scheduledAt: DateTime.now().add(const Duration(minutes: 10)),
        repeatDaily: false,
      );
      await _scheduler.schedule(snoozed);
      return false;
    }

    return true;
  }
}
