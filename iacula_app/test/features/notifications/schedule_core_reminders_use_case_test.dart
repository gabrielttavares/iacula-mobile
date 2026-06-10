import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/services/notification_capacity_policy.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

void main() {
  // Quote fetcher that encodes the fired weekday into the text, so tests can
  // assert each slot drew from the correct quotes.json weekday bucket.
  Future<Quote> weekdayQuote({
    required String language,
    required DateTime now,
  }) async {
    final weekday = (now.weekday % 7) + 1;
    return Quote(
      text: 'weekday-$weekday',
      dayOfWeek: weekday,
      theme: 'tema',
      season: LiturgicalSeason.ordinary,
    );
  }

  ScheduleCoreRemindersUseCase makeUseCase(
    InMemoryNotificationSchedulerRepository scheduler,
    InMemoryNotificationHistoryRepository history, {
    QuoteFetcher? fetcher,
  }) {
    return ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: fetcher ?? weekdayQuote,
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );
  }

  List<ReminderEvent> quoteEventsOf(
    InMemoryNotificationSchedulerRepository scheduler,
  ) =>
      scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .toList();

  group('pre-rolled multi-day quote queue', () {
    test('covers multiple days including today, all as plain one-shots',
        () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);

      // 2026-05-31 is a Sunday. Frequente (interval 60).
      final now = DateTime(2026, 5, 31, 8, 0);
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: now,
        showImmediate: false,
      );

      final quotes = quoteEventsOf(scheduler);
      expect(quotes, isNotEmpty);

      // No weekly repeats anymore — every quote is a one-shot.
      expect(quotes.every((e) => !e.repeatWeekly), isTrue);
      // All ids live in the single contiguous block from 9000.
      expect(
        quotes.every(
          (e) => ScheduleCoreRemindersUseCase.isQuoteReminderId(e.scheduledId!),
        ),
        isTrue,
      );
      // Crucially: TODAY is covered (the old bug skipped today's weekday floor).
      expect(quotes.any((e) => e.scheduledAt.day == now.day), isTrue);
      // And future days are covered too.
      final distinctDays = quotes.map((e) => e.scheduledAt.day).toSet();
      expect(distinctDays.length, greaterThan(1));
    });

    test('each slot draws from its own fired weekday bucket', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: DateTime(2026, 5, 31, 8, 0),
        showImmediate: false,
      );

      for (final event in quoteEventsOf(scheduler)) {
        final firedWeekday = (event.scheduledAt.weekday % 7) + 1;
        expect(event.body, 'weekday-$firedWeekday');
      }
    });

    test('never schedules a quote in the past', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);

      final now = DateTime(2026, 5, 31, 16, 0);
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 60),
        now: now,
        showImmediate: false,
      );

      for (final event in quoteEventsOf(scheduler)) {
        expect(event.scheduledAt.isBefore(now), isFalse);
      }
    });

    test('honors quiet hours so the allowed window is their complement',
        () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);

      await useCase(
        // Quiet 08:30-06:30 -> allowed window is the complement, 06:30-08:30.
        Settings.defaults.copyWith(
          intervalMinutes: 30,
          quietHoursStart: '08:30',
          quietHoursEnd: '06:30',
        ),
        now: DateTime(2026, 5, 31, 6, 0),
        showImmediate: false,
      );

      for (final event in quoteEventsOf(scheduler)) {
        final minutes = event.scheduledAt.hour * 60 + event.scheduledAt.minute;
        expect(minutes >= 6 * 60 + 30 && minutes < 8 * 60 + 30, isTrue,
            reason: '${event.scheduledAt} outside the allowed 06:30-08:30');
      }
    });

    test('same-instant rebuild reuses future slots without redrawing',
        () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      var drawCount = 0;
      Future<Quote> counting({
        required String language,
        required DateTime now,
      }) async {
        drawCount++;
        return Quote(
          text: 'draw-${now.toIso8601String()}',
          dayOfWeek: (now.weekday % 7) + 1,
          theme: 'tema',
          season: LiturgicalSeason.ordinary,
        );
      }

      final useCase = makeUseCase(scheduler, history, fetcher: counting);
      final settings = Settings.defaults.copyWith(intervalMinutes: 60);
      final now = DateTime(2026, 5, 31, 8, 0);

      await useCase(settings, now: now, showImmediate: false);
      final drawsAfterFirst = drawCount;
      expect(drawsAfterFirst, greaterThan(0));

      // Simulate the production cancel-then-reschedule, same instant.
      for (var id = ScheduleCoreRemindersUseCase.quoteScheduleIdBase;
          id <
              ScheduleCoreRemindersUseCase.quoteScheduleIdBase +
                  ScheduleCoreRemindersUseCase.quoteIdBlockSize;
          id++) {
        await scheduler.cancelById(id);
      }
      await useCase(settings, now: now, showImmediate: false);

      // All future slots reused their cached rows: no fresh draws.
      expect(drawCount, drawsAfterFirst);
    });

    test('stale future rows pruned when the window shrinks', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);
      final now = DateTime(2026, 5, 31, 7, 0);

      // Wide allowed window first: quiet 21:00-07:00 -> allowed 07:00-21:00.
      await useCase(
        Settings.defaults.copyWith(
          intervalMinutes: 60,
          quietHoursStart: '21:00',
          quietHoursEnd: '07:00',
        ),
        now: now,
        showImmediate: false,
      );

      // Shrink the allowed window: quiet 10:00-07:00 -> allowed only 07:00-10:00,
      // so rows for fire times now in quiet hours must be pruned.
      for (var id = ScheduleCoreRemindersUseCase.quoteScheduleIdBase;
          id <
              ScheduleCoreRemindersUseCase.quoteScheduleIdBase +
                  ScheduleCoreRemindersUseCase.quoteIdBlockSize;
          id++) {
        await scheduler.cancelById(id);
      }
      await useCase(
        Settings.defaults.copyWith(
          intervalMinutes: 60,
          quietHoursStart: '10:00',
          quietHoursEnd: '07:00',
        ),
        now: now,
        showImmediate: false,
      );

      // Every surviving future row maps to a currently scheduled slot.
      final scheduledFireTimes = quoteEventsOf(scheduler)
          .map((e) => e.scheduledAt)
          .toSet();
      final futureRows = (await history.listBetween(
        now,
        now.add(const Duration(days: 8)),
      ))
          .where((entry) => entry.deliveredAt.isAfter(now));
      expect(
        futureRows.every(
          (entry) => scheduledFireTimes.contains(entry.deliveredAt),
        ),
        isTrue,
      );
    });

    test('immediate notification records a delivery row at now', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(
        scheduler,
        history,
        fetcher: ({required String language, required DateTime now}) async {
          return Quote(
            text: 'quote-${now.toIso8601String()}',
            dayOfWeek: 1,
            theme: 't',
            season: LiturgicalSeason.ordinary,
          );
        },
      );

      final now = DateTime(2026, 5, 31, 8, 0);
      await useCase(Settings.defaults.copyWith(intervalMinutes: 60), now: now);

      final atNow = await history.listBetween(now, now);
      expect(atNow.where((entry) => entry.deliveredAt == now), hasLength(1));

      final immediate =
          scheduler.events.firstWhere((e) => e.scheduledId == 8999);
      expect(immediate.repeatWeekly, isFalse);
    });

    test('denser preset schedules at least as many per day', () async {
      Future<int> firstDayCount(int intervalMinutes) async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final history = InMemoryNotificationHistoryRepository();
        final useCase = makeUseCase(scheduler, history);
        final now = DateTime(2026, 5, 31, 7, 0);
        await useCase(
          Settings.defaults.copyWith(intervalMinutes: intervalMinutes),
          now: now,
          showImmediate: false,
        );
        return quoteEventsOf(scheduler)
            .where((e) => e.scheduledAt.day == now.day)
            .length;
      }

      final suave = await firstDayCount(180); // 2h
      final frequente = await firstDayCount(60); // 1h
      expect(frequente, greaterThanOrEqualTo(suave));
    });

    test('total scheduled notifications stay within the iOS 64 budget',
        () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);

      // Densest case: Mais frequente at window open with Angelus + immediate.
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30, angelusEnabled: true),
        now: DateTime(2026, 5, 31, 7, 0),
        showImmediate: true,
      );

      expect(scheduler.events.length, lessThanOrEqualTo(64));
    });

    test('keeps a quote floor when alarms reserve most of the budget',
        () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);

      // Reserve almost the whole budget for non-quote consumers.
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30, angelusEnabled: true),
        now: DateTime(2026, 5, 31, 7, 0),
        showImmediate: false,
        reservedNonQuoteBudget: 55,
      );

      // Quotes shrink but do not vanish (>= floor for the covered days).
      final quotes = quoteEventsOf(scheduler);
      expect(quotes, isNotEmpty);
      expect(scheduler.events.length, lessThanOrEqualTo(64));
    });
  });

  group('platform capacity policy', () {
    ScheduleCoreRemindersUseCase makeWithPolicy(
      InMemoryNotificationSchedulerRepository scheduler,
      InMemoryNotificationHistoryRepository history,
      NotificationCapacityPolicy policy,
    ) {
      return ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher: weekdayQuote,
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
        capacityPolicy: policy,
      );
    }

    test('iOS spreads a tight cadence within the 64 budget (no full cadence)',
        () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase =
          makeWithPolicy(scheduler, history, NotificationCapacityPolicy.ios);

      // Muito intenso (10 min) at window open: a 14h window holds ~75/day, but
      // the 64 cap forces a thinned spread.
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 10),
        now: DateTime(2026, 5, 31, 7, 0),
        showImmediate: false,
      );

      final quotes = quoteEventsOf(scheduler);
      expect(quotes.length, lessThanOrEqualTo(64));
      // Spread across the runway, so the first day is far below the ~75 the
      // window could hold at 10-min cadence.
      final firstDay = quotes.where((e) => e.scheduledAt.day == 31).length;
      expect(firstDay, lessThan(30));
    });

    test('Android honors full cadence and exceeds the iOS 64 cap', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeWithPolicy(
        scheduler,
        history,
        NotificationCapacityPolicy.android,
      );

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 10),
        now: DateTime(2026, 5, 31, 7, 0),
        showImmediate: false,
      );

      final quotes = quoteEventsOf(scheduler);
      // No 64 cap: a tight multi-day cadence schedules far more than iOS allows.
      expect(quotes.length, greaterThan(64));
      // The dense first day runs at the full 10-min cadence (~80+ in a 14h
      // window), not a thinned spread.
      final firstDay = quotes.where((e) => e.scheduledAt.day == 31).length;
      expect(firstDay, greaterThan(60));
    });

    test('Android tail thins out after the dense runway but keeps delivering',
        () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeWithPolicy(
        scheduler,
        history,
        NotificationCapacityPolicy.android,
      );

      final now = DateTime(2026, 5, 31, 7, 0);
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 10),
        now: now,
        showImmediate: false,
      );

      final quotes = quoteEventsOf(scheduler);
      int countOnDayOffset(int offset) {
        final day = now.add(Duration(days: offset));
        return quotes
            .where((e) =>
                e.scheduledAt.year == day.year &&
                e.scheduledAt.month == day.month &&
                e.scheduledAt.day == day.day)
            .length;
      }

      // Dense days (0..2) deliver more than tail days (3+), but the tail is
      // non-empty — a long-closed app still receives quotes.
      final denseDay = countOnDayOffset(1);
      final tailDay = countOnDayOffset(5);
      expect(denseDay, greaterThan(tailDay));
      expect(tailDay, greaterThan(0));
      // Coverage reaches the Android tail horizon (14 days).
      expect(countOnDayOffset(10), greaterThan(0));
    });
  });

  group('Angelus / season daily repeat (unchanged behavior)', () {
    test('Angelus is not scheduled when noon falls in quiet hours', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();

      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
          return const Quote(
            text: 'Q',
            dayOfWeek: 1,
            theme: 't',
            season: LiturgicalSeason.ordinary,
          );
        },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      await useCase(
        // Quiet 11:00-07:00 -> allowed only 07:00-11:00, which excludes noon, so
        // Angelus is suppressed.
        Settings.defaults.copyWith(
          intervalMinutes: 30,
          angelusEnabled: true,
          quietHoursStart: '11:00',
          quietHoursEnd: '07:00',
        ),
        now: DateTime(2026, 2, 21, 8),
        showImmediate: false,
      );

      expect(
        scheduler.events.where(
          (event) => event.type == ReminderEventType.angelusNoon,
        ),
        isEmpty,
      );
    });

    test(
      'Angelus shows Regina Caeli during Easter even when toggle is off',
      () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final history = InMemoryNotificationHistoryRepository();
        final useCase = makeUseCase(scheduler, history);

        await useCase(
          Settings.defaults.copyWith(intervalMinutes: 30, angelusEnabled: true),
          now: DateTime(2026, 4, 10, 8),
          isEasterSeason: true,
          showImmediate: false,
        );

        final angelus = scheduler.events.firstWhere(
          (e) => e.type == ReminderEventType.angelusNoon,
        );
        expect(angelus.title, 'Regina Caeli');
        expect(angelus.body, 'Hora de rezar a Regina Caeli.');
        expect(angelus.prayerSlug, 'regina-coeli');
      },
    );

    test(
      'Angelus uses local Easter fallback when caller passes false',
      () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final history = InMemoryNotificationHistoryRepository();
        final useCase = makeUseCase(scheduler, history);

        await useCase(
          Settings.defaults.copyWith(
            intervalMinutes: 30,
            angelusEnabled: true,
            escrivaPointsFeedEnabled: true,
          ),
          now: DateTime(2026, 4, 10, 8),
          isEasterSeason: false,
          showImmediate: false,
        );

        final angelus = scheduler.events.firstWhere(
          (e) => e.type == ReminderEventType.angelusNoon,
        );
        expect(angelus.title, 'Regina Caeli');
        expect(angelus.prayerSlug, 'regina-coeli');
      },
    );

    test('daily noon repeat is named per season far from a boundary', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30, angelusEnabled: true),
        now: DateTime(2026, 2, 10, 8),
        isEasterSeason: false,
        showImmediate: false,
      );
      final ordinary = scheduler.events.firstWhere(
        (e) => e.type == ReminderEventType.angelusNoon,
      );
      expect(ordinary.title, 'Angelus');
      expect(ordinary.body, 'Hora de rezar o Angelus.');
      expect(ordinary.prayerSlug, 'angelus');
    });

    test('daily noon repeat does not switch early before Easter', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30, angelusEnabled: true),
        now: DateTime(2026, 4, 3, 8),
        isEasterSeason: false,
        showImmediate: false,
      );

      final angelus = scheduler.events.firstWhere(
        (e) => e.type == ReminderEventType.angelusNoon && e.repeatDaily,
      );
      expect(angelus.title, 'Angelus');
      expect(angelus.prayerSlug, 'angelus');
    });

    test('daily noon repeat stays Regina Caeli before Pentecost ends',
        () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = InMemoryNotificationHistoryRepository();
      final useCase = makeUseCase(scheduler, history);

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30, angelusEnabled: true),
        now: DateTime(2026, 5, 22, 8),
        isEasterSeason: true,
        showImmediate: false,
      );

      final angelus = scheduler.events.firstWhere(
        (e) => e.type == ReminderEventType.angelusNoon && e.repeatDaily,
      );
      expect(angelus.title, 'Regina Caeli');
      expect(angelus.prayerSlug, 'regina-coeli');
    });
  });
}
