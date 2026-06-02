import '../../../settings/domain/entities/settings.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';
import '../../domain/services/next_occurrence_calculator.dart';

final class ScheduleLiturgyRemindersUseCase {
  const ScheduleLiturgyRemindersUseCase(this._scheduler);

  final NotificationSchedulerRepository _scheduler;

  /// Liturgy-hour reminders are user-set fixed-time alarms (like prayer alarms
  /// and intentions): a promise that is always kept. They fire at their chosen
  /// time regardless of the active notification window, which only governs the
  /// substitutable quote stream.
  Future<void> call(Settings settings, {DateTime? now}) async {
    final current = now ?? DateTime.now();

    if (settings.laudesEnabled) {
      await _scheduleHour(
        type: ReminderEventType.laudes,
        title: 'Laudes',
        hhmm: settings.laudesTime,
        now: current,
      );
    }
    if (settings.vespersEnabled) {
      await _scheduleHour(
        type: ReminderEventType.vespers,
        title: 'Vésperas',
        hhmm: settings.vespersTime,
        now: current,
      );
    }
    if (settings.complineEnabled) {
      await _scheduleHour(
        type: ReminderEventType.compline,
        title: 'Completas',
        hhmm: settings.complineTime,
        now: current,
      );
    }
    if (settings.oraMediaEnabled) {
      await _scheduleHour(
        type: ReminderEventType.oraMedia,
        title: 'Hora Média',
        hhmm: settings.oraMediaTime,
        now: current,
      );
    }
  }

  Future<void> _scheduleHour({
    required ReminderEventType type,
    required String title,
    required String hhmm,
    required DateTime now,
  }) async {
    await _scheduler.schedule(
      ReminderEvent(
        type: type,
        title: title,
        body: 'Ofício do dia.',
        scheduledAt: NextOccurrenceCalculator.forHourMinute(
          now: now,
          hhmm: hhmm,
        ),
        withVibration: true,
        isAlarm: true,
        repeatDaily: true,
        routeTarget: NotificationRouteTarget.alarm,
      ),
    );
  }
}
