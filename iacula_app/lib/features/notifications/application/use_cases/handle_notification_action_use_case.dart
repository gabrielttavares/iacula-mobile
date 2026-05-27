import '../../../prayers/domain/services/prayer_scheduler.dart';
import '../../domain/entities/notification_action_event.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

final class HandleNotificationActionUseCase {
  const HandleNotificationActionUseCase(this._scheduler);

  final NotificationSchedulerRepository _scheduler;
  static const int maxConsecutiveSnoozes = 3;
  static const int _angelusNotificationId = 200;

  Future<bool> call(NotificationActionEvent action) async {
    if (action.event.type == ReminderEventType.seasonTransition) {
      await _handleSeasonTransition(action.event);
      return false;
    }

    switch (action.actionId) {
      case NotificationActionEvent.snooze1hAction:
      case NotificationActionEvent.dismissAction:
      case NotificationActionEvent.snooze10Action:
        await _snoozeOneHour(action);
        return false;
    }

    return true;
  }

  Future<void> _handleSeasonTransition(ReminderEvent event) async {
    final isEaster = event.prayerSlug == 'regina-coeli';
    final title = isEaster ? 'Regina Caeli' : 'Angelus';
    final body = isEaster
        ? 'Hora de rezar a Regina Caeli.'
        : 'Hora de rezar o Angelus.';

    await _scheduler.cancelById(_angelusNotificationId);

    final noon = PrayerScheduler.calculateNextNoon(DateTime.now()).nextTriggerTime;
    await _scheduler.scheduleWithId(
      _angelusNotificationId,
      ReminderEvent(
        type: ReminderEventType.angelusNoon,
        title: title,
        body: body,
        scheduledAt: noon,
        withVibration: true,
        isAlarm: true,
        repeatDaily: true,
        routeTarget: NotificationRouteTarget.prayer,
        prayerSlug: event.prayerSlug,
        scheduledId: _angelusNotificationId,
      ),
    );
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
