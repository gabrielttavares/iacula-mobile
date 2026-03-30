import '../../../settings/domain/entities/settings.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';
import '../../domain/services/next_occurrence_calculator.dart';
import '../../domain/services/quiet_hours_checker.dart';

final class ScheduleLiturgyRemindersUseCase {
  const ScheduleLiturgyRemindersUseCase(this._scheduler);

  final NotificationSchedulerRepository _scheduler;

  Future<void> call(Settings settings, {DateTime? now}) async {
    final current = now ?? DateTime.now();

    if (settings.laudesEnabled) {
      final scheduledAt = NextOccurrenceCalculator.forHourMinute(
        now: current,
        hhmm: settings.laudesTime,
      );
      if (!_isInQuietHours(settings, scheduledAt)) {
        await _scheduler.schedule(
          ReminderEvent(
            type: ReminderEventType.laudes,
            title: 'Laudes',
            body: 'Ofício do dia.',
            scheduledAt: scheduledAt,
            withVibration: true,
            isAlarm: true,
            repeatDaily: true,
            routeTarget: NotificationRouteTarget.alarm,
          ),
        );
      }
    }

    if (settings.vespersEnabled) {
      final scheduledAt = NextOccurrenceCalculator.forHourMinute(
        now: current,
        hhmm: settings.vespersTime,
      );
      if (!_isInQuietHours(settings, scheduledAt)) {
        await _scheduler.schedule(
          ReminderEvent(
            type: ReminderEventType.vespers,
            title: 'Vésperas',
            body: 'Ofício do dia.',
            scheduledAt: scheduledAt,
            withVibration: true,
            isAlarm: true,
            repeatDaily: true,
            routeTarget: NotificationRouteTarget.alarm,
          ),
        );
      }
    }

    if (settings.complineEnabled) {
      final scheduledAt = NextOccurrenceCalculator.forHourMinute(
        now: current,
        hhmm: settings.complineTime,
      );
      if (!_isInQuietHours(settings, scheduledAt)) {
        await _scheduler.schedule(
          ReminderEvent(
            type: ReminderEventType.compline,
            title: 'Completas',
            body: 'Ofício do dia.',
            scheduledAt: scheduledAt,
            withVibration: true,
            isAlarm: true,
            repeatDaily: true,
            routeTarget: NotificationRouteTarget.alarm,
          ),
        );
      }
    }

    if (settings.oraMediaEnabled) {
      final scheduledAt = NextOccurrenceCalculator.forHourMinute(
        now: current,
        hhmm: settings.oraMediaTime,
      );
      if (!_isInQuietHours(settings, scheduledAt)) {
        await _scheduler.schedule(
          ReminderEvent(
            type: ReminderEventType.oraMedia,
            title: 'Hora Média',
            body: 'Ofício do dia.',
            scheduledAt: scheduledAt,
            withVibration: true,
            isAlarm: true,
            repeatDaily: true,
            routeTarget: NotificationRouteTarget.alarm,
          ),
        );
      }
    }
  }

  bool _isInQuietHours(Settings settings, DateTime scheduledAt) {
    if (!settings.quietHoursEnabled) {
      return false;
    }
    return QuietHoursChecker.isDuringQuietHours(
      scheduledAt,
      settings.quietHoursStart,
      settings.quietHoursEnd,
    );
  }
}
