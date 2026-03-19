import '../../domain/entities/notification_action_event.dart';
import '../../domain/entities/notification_history_entry.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_history_repository.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

final class HandleNotificationActionUseCase {
  const HandleNotificationActionUseCase(
    this._scheduler,
    this._notificationHistoryRepository,
  );

  final NotificationSchedulerRepository _scheduler;
  final NotificationHistoryRepository _notificationHistoryRepository;

  Future<bool> call(NotificationActionEvent action) async {
    if (action.actionId == NotificationActionEvent.snooze10Action) {
      final snoozed = action.event.copyWith(
        scheduledAt: DateTime.now().add(const Duration(minutes: 10)),
        repeatDaily: false,
      );
      await _scheduler.schedule(snoozed);
      return false;
    }

    if (action.event.type == ReminderEventType.quoteInterval) {
      await _notificationHistoryRepository.add(
        NotificationHistoryEntry(
          quoteText: action.event.body,
          theme: action.event.quoteTheme ?? 'Jaculatória',
          season: action.event.quoteSeason ?? 'ordinary',
          deliveredAt: DateTime.now(),
          feastName: action.event.quoteFeastName,
        ),
      );
    }

    return true;
  }
}
