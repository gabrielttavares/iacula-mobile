import '../../../liturgical/domain/easter_calculator.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

final class ScheduleSeasonTransitionsUseCase {
  const ScheduleSeasonTransitionsUseCase(this._scheduler);

  final NotificationSchedulerRepository _scheduler;

  static const int easterTransitionId = 401;
  static const int pentecostTransitionId = 402;

  Future<void> call({DateTime? now}) async {
    final current = now ?? DateTime.now();

    await _scheduler.cancelById(easterTransitionId);
    await _scheduler.cancelById(pentecostTransitionId);

    final easterSunday = EasterCalculator.easterSunday(current.year);
    final dayAfterPentecost = easterSunday.add(const Duration(days: 50));

    final easterMidnight = DateTime(
      easterSunday.year,
      easterSunday.month,
      easterSunday.day,
    );
    if (easterMidnight.isAfter(current)) {
      await _scheduler.scheduleWithId(
        easterTransitionId,
        ReminderEvent(
          type: ReminderEventType.seasonTransition,
          title: 'Season Transition',
          body: '',
          scheduledAt: easterMidnight,
          withVibration: false,
          isAlarm: false,
          repeatDaily: false,
          routeTarget: NotificationRouteTarget.home,
          prayerSlug: 'regina-coeli',
          scheduledId: easterTransitionId,
        ),
      );
    }

    final pentecostMidnight = DateTime(
      dayAfterPentecost.year,
      dayAfterPentecost.month,
      dayAfterPentecost.day,
    );
    if (pentecostMidnight.isAfter(current)) {
      await _scheduler.scheduleWithId(
        pentecostTransitionId,
        ReminderEvent(
          type: ReminderEventType.seasonTransition,
          title: 'Season Transition',
          body: '',
          scheduledAt: pentecostMidnight,
          withVibration: false,
          isAlarm: false,
          repeatDaily: false,
          routeTarget: NotificationRouteTarget.home,
          prayerSlug: 'angelus',
          scheduledId: pentecostTransitionId,
        ),
      );
    }
  }
}
