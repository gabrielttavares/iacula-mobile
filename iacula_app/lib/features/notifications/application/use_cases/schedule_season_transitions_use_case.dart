import '../../../liturgical/domain/easter_calculator.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

final class ScheduleSeasonTransitionsUseCase {
  const ScheduleSeasonTransitionsUseCase(this._scheduler);

  final NotificationSchedulerRepository _scheduler;

  static const int easterTransitionId = 401;
  static const int pentecostTransitionId = 402;

  /// How many consecutive days of real noon prayer notifications are pre-baked
  /// from each season boundary. iOS runs no code on background delivery, so the
  /// silent 401/402 re-bake trigger cannot flip the daily Angelus while the app
  /// is closed. This window of one-shots fires the *correct* prayer at noon on
  /// the boundary days regardless of whether the user opens the app; the next
  /// open re-bakes the daily repeat (id 200) to cover the rest of the season.
  static const int boundaryBridgeDays = 7;

  /// Id block for the Easter (Regina Caeli) noon bridge one-shots: 410..416.
  /// Distinct from Angelus(200) and the 401/402 transition triggers.
  static const int easterNoonIdBase = 410;

  /// Id block for the day-after-Pentecost (Angelus) noon bridge one-shots:
  /// 420..426.
  static const int pentecostNoonIdBase = 420;

  /// Appended to the body of the LAST scheduled bridge day per window.
  /// Nudges the user to open the app before the stale daily repeat resurfaces.
  static const String bridgeRenewalCta =
      'Toque para manter as orações da estação atualizadas.';

  Future<void> call({
    DateTime? now,
    bool angelusEnabled = true,
    bool Function(DateTime)? isQuietAt,
  }) async {
    final current = now ?? DateTime.now();
    final isQuiet = isQuietAt ?? (_) => false;

    await _scheduler.cancelById(easterTransitionId);
    await _scheduler.cancelById(pentecostTransitionId);
    for (var dayOffset = 0; dayOffset < boundaryBridgeDays; dayOffset++) {
      await _scheduler.cancelById(easterNoonIdBase + dayOffset);
      await _scheduler.cancelById(pentecostNoonIdBase + dayOffset);
    }

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

    // Pre-baked noon prayer one-shots bridging each boundary (closed-app safe).
    // Only when the noon prayer is enabled — the cancellation above already
    // cleared any previously-scheduled bridge if the user just disabled it.
    if (!angelusEnabled) return;
    await _scheduleNoonBridge(
      from: easterMidnight,
      idBase: easterNoonIdBase,
      prayerSlug: 'regina-coeli',
      title: 'Regina Caeli',
      body: 'Hora de rezar a Regina Caeli.',
      current: current,
      isQuiet: isQuiet,
    );
    await _scheduleNoonBridge(
      from: pentecostMidnight,
      idBase: pentecostNoonIdBase,
      prayerSlug: 'angelus',
      title: 'Angelus',
      body: 'Hora de rezar o Angelus.',
      current: current,
      isQuiet: isQuiet,
    );
  }

  /// Schedules [boundaryBridgeDays] real noon prayer notifications starting on
  /// the day of [from], one per day, skipping any whose noon is already past.
  /// The final scheduled day appends [bridgeRenewalCta] to its body to nudge
  /// the user to open the app before the stale daily repeat resurfaces.
  Future<void> _scheduleNoonBridge({
    required DateTime from,
    required int idBase,
    required String prayerSlug,
    required String title,
    required String body,
    required DateTime current,
    required bool Function(DateTime) isQuiet,
  }) async {
    final today = DateTime(current.year, current.month, current.day);

    // Collect all eligible (dayOffset, noon) pairs before scheduling so we
    // know which one is the last and can attach the CTA exclusively to it.
    final eligibleDays = <(int dayOffset, DateTime noon)>[];
    for (var dayOffset = 0; dayOffset < boundaryBridgeDays; dayOffset++) {
      final day = from.add(Duration(days: dayOffset));
      final noon = DateTime(day.year, day.month, day.day, 12);
      if (!noon.isAfter(current)) continue;
      // The live daily Angelus (id 200) already covers today with the correct
      // prayer after a rebuild — a bridge one-shot for today would duplicate it.
      if (DateTime(day.year, day.month, day.day) == today) continue;
      // Honor quiet hours exactly like the daily noon prayer does.
      if (isQuiet(noon)) continue;
      eligibleDays.add((dayOffset, noon));
    }

    for (var index = 0; index < eligibleDays.length; index++) {
      final (dayOffset, noon) = eligibleDays[index];
      final isLastDay = index == eligibleDays.length - 1;
      final scheduledId = idBase + dayOffset;
      final notificationBody =
          isLastDay ? '$body $bridgeRenewalCta' : body;

      await _scheduler.scheduleWithId(
        scheduledId,
        ReminderEvent(
          type: ReminderEventType.angelusNoon,
          title: title,
          body: notificationBody,
          scheduledAt: noon,
          withVibration: true,
          isAlarm: true,
          repeatDaily: false,
          routeTarget: NotificationRouteTarget.prayer,
          prayerSlug: prayerSlug,
          scheduledId: scheduledId,
        ),
      );
    }
  }
}
