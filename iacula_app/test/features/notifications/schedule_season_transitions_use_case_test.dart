import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_season_transitions_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';

void main() {
  late InMemoryNotificationSchedulerRepository scheduler;

  setUp(() {
    scheduler = InMemoryNotificationSchedulerRepository();
  });

  test('schedules Easter and Pentecost transitions when both are in the future', () async {
    // 2026: Easter is April 5, Pentecost is May 24 (Easter + 49)
    final now = DateTime(2026, 1, 15, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    expect(transitions, hasLength(2));

    // First: Easter Sunday midnight → switch to Regina Caeli
    expect(transitions[0].scheduledAt, DateTime(2026, 4, 5, 0, 0));
    expect(transitions[0].prayerSlug, 'regina-coeli');
    expect(transitions[0].repeatDaily, isFalse);
    expect(transitions[0].scheduledId, ScheduleSeasonTransitionsUseCase.easterTransitionId);

    // Second: day after Pentecost midnight → switch back to Angelus
    expect(transitions[1].scheduledAt, DateTime(2026, 5, 25, 0, 0));
    expect(transitions[1].prayerSlug, 'angelus');
    expect(transitions[1].repeatDaily, isFalse);
    expect(transitions[1].scheduledId, ScheduleSeasonTransitionsUseCase.pentecostTransitionId);
  });

  test('skips Easter transition when Easter is already past', () async {
    // During Easter season: Easter was April 5, now is April 20
    final now = DateTime(2026, 4, 20, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList();

    expect(transitions, hasLength(1));
    // Only the Pentecost transition should be scheduled
    expect(transitions[0].prayerSlug, 'angelus');
    expect(transitions[0].scheduledAt, DateTime(2026, 5, 25, 0, 0));
  });

  test('skips both transitions when both are already past', () async {
    // After Pentecost: both transitions are in the past
    final now = DateTime(2026, 6, 10, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList();

    expect(transitions, isEmpty);
  });

  test('cancels previous transition notifications before scheduling new ones', () async {
    final now = DateTime(2026, 1, 15, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    // Schedule once
    await useCase.call(now: now);
    expect(
      scheduler.events.where((e) => e.type == ReminderEventType.seasonTransition),
      hasLength(2),
    );

    // Schedule again (e.g. from a rebuild) — should still be exactly 2, not 4
    await useCase.call(now: now);
    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList();
    expect(transitions, hasLength(2));
  });

  test('transition notifications are not alarms and have no vibration', () async {
    final now = DateTime(2026, 1, 15, 10, 0);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList();

    for (final transition in transitions) {
      expect(transition.isAlarm, isFalse);
      expect(transition.withVibration, isFalse);
    }
  });

  test('handles 2025 Easter date correctly', () async {
    // 2025: Easter is April 20, Pentecost is June 8
    final now = DateTime(2025, 1, 1);
    final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

    await useCase.call(now: now);

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    expect(transitions, hasLength(2));
    expect(transitions[0].scheduledAt, DateTime(2025, 4, 20, 0, 0));
    expect(transitions[1].scheduledAt, DateTime(2025, 6, 9, 0, 0));
  });

  group('pre-baked boundary noon prayer one-shots', () {
    // These fire the *correct* prayer at noon on the boundary days even if the
    // app is never opened — iOS runs no code on background delivery, so the
    // silent 401/402 re-bake trigger alone cannot flip the daily Angelus while
    // closed. A short window of real noon notifications bridges each boundary
    // until the user's next open re-bakes the daily repeat.

    List<ReminderEvent> noonOneShots() => scheduler.events
        .where(
          (e) =>
              e.type == ReminderEventType.angelusNoon &&
              e.repeatDaily == false,
        )
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    test(
      'schedules a 7-day window of Regina Caeli noon one-shots from Easter Sunday',
      () async {
        // 2026: Easter = April 5. Both boundaries in the future.
        final now = DateTime(2026, 1, 15, 10, 0);
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final reginaNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'regina-coeli')
            .toList();

        expect(reginaNoon, hasLength(7));
        for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
          final fireAt = reginaNoon[dayOffset].scheduledAt;
          expect(fireAt, DateTime(2026, 4, 5 + dayOffset, 12, 0));
          expect(reginaNoon[dayOffset].title, 'Regina Caeli');
          expect(reginaNoon[dayOffset].isAlarm, isTrue);
          expect(reginaNoon[dayOffset].repeatDaily, isFalse);
        }
      },
    );

    test(
      'schedules a 7-day window of Angelus noon one-shots from the day after Pentecost',
      () async {
        // 2026: Pentecost = May 24, day after = May 25.
        final now = DateTime(2026, 1, 15, 10, 0);
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final angelusNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'angelus')
            .toList();

        expect(angelusNoon, hasLength(7));
        for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
          expect(
            angelusNoon[dayOffset].scheduledAt,
            DateTime(2026, 5, 25 + dayOffset, 12, 0),
          );
          expect(angelusNoon[dayOffset].title, 'Angelus');
        }
      },
    );

    test('noon one-shots use a stable, non-colliding id block (idempotent rebuild)',
        () async {
      final now = DateTime(2026, 1, 15, 10, 0);
      final useCase = ScheduleSeasonTransitionsUseCase(scheduler);

      await useCase.call(now: now);
      final firstPass = noonOneShots().map((e) => e.scheduledId).toSet();

      // 14 one-shots (7 + 7), all distinct, none clashing with Angelus(200) or
      // the 401/402 transition triggers.
      expect(firstPass, hasLength(14));
      expect(firstPass, isNot(contains(200)));
      expect(firstPass, isNot(contains(401)));
      expect(firstPass, isNot(contains(402)));

      // Re-running the pass overwrites in place — still 14, no duplicates.
      await useCase.call(now: now);
      expect(noonOneShots(), hasLength(14));
    });

    test('only schedules noon one-shots whose day is still in the future', () async {
      // Mid-Easter-season: Easter (Apr 5) is past, three of its 7 bridge days
      // are already gone; Pentecost window is fully future.
      final now = DateTime(2026, 4, 8, 10, 0);
      await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

      final reginaNoon = noonOneShots()
          .where((e) => e.prayerSlug == 'regina-coeli')
          .toList();

      // Apr 5,6,7 noon are past (now is Apr 8 10:00); Apr 8 noon is still
      // future but skipped because it is today (daily Angelus covers it), so
      // Apr 9,10,11 remain.
      expect(reginaNoon.map((e) => e.scheduledAt), <DateTime>[
        DateTime(2026, 4, 9, 12, 0),
        DateTime(2026, 4, 10, 12, 0),
        DateTime(2026, 4, 11, 12, 0),
      ]);
    });

    test('schedules no noon one-shots once both boundaries are fully past', () async {
      final now = DateTime(2026, 6, 10, 10, 0);
      await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

      expect(noonOneShots(), isEmpty);
    });

    test('schedules no noon one-shots when the noon prayer is disabled', () async {
      final now = DateTime(2026, 1, 15, 10, 0);
      await ScheduleSeasonTransitionsUseCase(scheduler)
          .call(now: now, angelusEnabled: false);

      expect(noonOneShots(), isEmpty);
    });

    test('skips the bridge one-shot for today (the daily Angelus already covers it)',
        () async {
      // It is Easter Sunday morning. A rebuild just re-baked the daily Angelus
      // (id 200) to Regina Caeli for today, so a bridge one-shot for today would
      // be a duplicate noon notification. Future bridge days are still needed
      // because id 200 stays stale-baked until the next open.
      final now = DateTime(2026, 4, 5, 9, 0);
      await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

      final reginaNoon = noonOneShots()
          .where((e) => e.prayerSlug == 'regina-coeli')
          .toList();

      // Today (Apr 5) is skipped; Apr 6..11 remain → 6 one-shots.
      expect(reginaNoon.map((e) => e.scheduledAt), <DateTime>[
        DateTime(2026, 4, 6, 12, 0),
        DateTime(2026, 4, 7, 12, 0),
        DateTime(2026, 4, 8, 12, 0),
        DateTime(2026, 4, 9, 12, 0),
        DateTime(2026, 4, 10, 12, 0),
        DateTime(2026, 4, 11, 12, 0),
      ]);
    });

    group('bridge renewal CTA on the final scheduled day', () {
      // 2026: Easter = Apr 5 (window: Apr 5..11), day-after-Pentecost = May 25
      // (window: May 25..31). now = Jan 15 10:00 → all 7 days of each window
      // are future and not today, so the last scheduled day is offset 6 (Apr 11
      // for Regina Caeli, May 31 for Angelus).
      final now = DateTime(2026, 1, 15, 10, 0);

      test('the last Regina Caeli bridge day body ends with the CTA', () async {
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final reginaNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'regina-coeli')
            .toList();

        // Apr 11 is the last bridge day — its body must end with the CTA.
        final lastDay =
            reginaNoon.firstWhere((e) => e.scheduledAt == DateTime(2026, 4, 11, 12, 0));
        expect(
          lastDay.body,
          endsWith(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta),
        );
      });

      test('earlier Regina Caeli bridge days do NOT carry the CTA', () async {
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final reginaNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'regina-coeli')
            .toList();

        // All days except the last (Apr 5..10) must NOT contain the CTA.
        final earlierDays =
            reginaNoon.where((e) => e.scheduledAt != DateTime(2026, 4, 11, 12, 0));
        for (final day in earlierDays) {
          expect(
            day.body,
            isNot(contains(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta)),
          );
        }
      });

      test('exactly one Regina Caeli bridge notification carries the CTA', () async {
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final reginaNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'regina-coeli')
            .toList();

        final withCta = reginaNoon
            .where((e) => e.body.contains(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta))
            .toList();
        expect(withCta, hasLength(1));
      });

      test('the last Angelus bridge day body ends with the CTA', () async {
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final angelusNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'angelus')
            .toList();

        // May 31 is the last bridge day — its body must end with the CTA.
        final lastDay =
            angelusNoon.firstWhere((e) => e.scheduledAt == DateTime(2026, 5, 31, 12, 0));
        expect(
          lastDay.body,
          endsWith(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta),
        );
      });

      test('earlier Angelus bridge days do NOT carry the CTA', () async {
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final angelusNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'angelus')
            .toList();

        // All days except the last (May 25..30) must NOT contain the CTA.
        final earlierDays =
            angelusNoon.where((e) => e.scheduledAt != DateTime(2026, 5, 31, 12, 0));
        for (final day in earlierDays) {
          expect(
            day.body,
            isNot(contains(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta)),
          );
        }
      });

      test('exactly one Angelus bridge notification carries the CTA', () async {
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final angelusNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'angelus')
            .toList();

        final withCta = angelusNoon
            .where((e) => e.body.contains(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta))
            .toList();
        expect(withCta, hasLength(1));
      });

      test('CTA day title and prayerSlug are unchanged (Regina Caeli)', () async {
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final reginaNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'regina-coeli')
            .toList();

        final ctaDay = reginaNoon
            .firstWhere((e) => e.body.contains(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta));
        expect(ctaDay.title, 'Regina Caeli');
        expect(ctaDay.prayerSlug, 'regina-coeli');
      });

      test('CTA day title and prayerSlug are unchanged (Angelus)', () async {
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: now);

        final angelusNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'angelus')
            .toList();

        final ctaDay = angelusNoon
            .firstWhere((e) => e.body.contains(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta));
        expect(ctaDay.title, 'Angelus');
        expect(ctaDay.prayerSlug, 'angelus');
      });

      test('when earlier days are skipped the single remaining day gets the CTA', () async {
        // Mid-Easter: now = Apr 8 10:00. Bridge window: Apr 5..11. Past: Apr 5,6,7.
        // Today (Apr 8) is skipped. Remaining: Apr 9, 10, 11 → last is Apr 11.
        final midSeason = DateTime(2026, 4, 8, 10, 0);
        await ScheduleSeasonTransitionsUseCase(scheduler).call(now: midSeason);

        final reginaNoon = noonOneShots()
            .where((e) => e.prayerSlug == 'regina-coeli')
            .toList();

        // Only Apr 9, 10, 11 scheduled; Apr 11 is the final one and gets the CTA.
        expect(reginaNoon, hasLength(3));
        final lastDay =
            reginaNoon.firstWhere((e) => e.scheduledAt == DateTime(2026, 4, 11, 12, 0));
        expect(
          lastDay.body,
          endsWith(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta),
        );

        final withCta = reginaNoon
            .where((e) => e.body.contains(ScheduleSeasonTransitionsUseCase.bridgeRenewalCta))
            .toList();
        expect(withCta, hasLength(1));
      });
    });
  });
}
