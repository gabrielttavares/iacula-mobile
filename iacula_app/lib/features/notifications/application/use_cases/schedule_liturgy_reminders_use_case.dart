import '../../../settings/domain/entities/settings.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';
import '../../domain/services/next_occurrence_calculator.dart';

final class ScheduleLiturgyRemindersUseCase {
  const ScheduleLiturgyRemindersUseCase(this._scheduler);

  final NotificationSchedulerRepository _scheduler;

  Future<void> call(Settings settings, {DateTime? now}) async {
    final current = now ?? DateTime.now();

    if (settings.laudesEnabled) {
      await _scheduler.schedule(
        ReminderEvent(
          type: ReminderEventType.laudes,
          title: 'Laudes',
          body: 'Ofício do dia.',
          scheduledAt: NextOccurrenceCalculator.forHourMinute(now: current, hhmm: settings.laudesTime),
          withVibration: true,
          isAlarm: true,
          repeatDaily: true,
          routeTarget: NotificationRouteTarget.alarm,
        ),
      );
    }

    if (settings.vespersEnabled) {
      await _scheduler.schedule(
        ReminderEvent(
          type: ReminderEventType.vespers,
          title: 'Vésperas',
          body: 'Ofício do dia.',
          scheduledAt: NextOccurrenceCalculator.forHourMinute(now: current, hhmm: settings.vespersTime),
          withVibration: true,
          isAlarm: true,
          repeatDaily: true,
          routeTarget: NotificationRouteTarget.alarm,
        ),
      );
    }

    if (settings.complineEnabled) {
      await _scheduler.schedule(
        ReminderEvent(
          type: ReminderEventType.compline,
          title: 'Completas',
          body: 'Ofício do dia.',
          scheduledAt: NextOccurrenceCalculator.forHourMinute(now: current, hhmm: settings.complineTime),
          withVibration: true,
          isAlarm: true,
          repeatDaily: true,
          routeTarget: NotificationRouteTarget.alarm,
        ),
      );
    }

    if (settings.oraMediaEnabled) {
      await _scheduler.schedule(
        ReminderEvent(
          type: ReminderEventType.oraMedia,
          title: 'Hora Média',
          body: 'Ofício do dia.',
          scheduledAt: NextOccurrenceCalculator.forHourMinute(now: current, hhmm: settings.oraMediaTime),
          withVibration: true,
          isAlarm: true,
          repeatDaily: true,
          routeTarget: NotificationRouteTarget.alarm,
        ),
      );
    }
  }
}
