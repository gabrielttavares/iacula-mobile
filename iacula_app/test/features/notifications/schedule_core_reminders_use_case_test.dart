import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

final class _InMemoryNotificationHistoryRepository
    implements NotificationHistoryRepository {
  final List<NotificationHistoryEntry> entries = [];

  @override
  Future<void> add(NotificationHistoryEntry entry) async {
    entries.removeWhere(
      (current) =>
          current.quoteText == entry.quoteText &&
          current.deliveredAt == entry.deliveredAt,
    );
    entries.add(entry);
  }

  @override
  Future<void> clearFrom(DateTime instant) async {
    final end = DateTime(
      instant.year,
      instant.month,
      instant.day,
    ).add(const Duration(days: 1));
    entries.removeWhere(
      (entry) =>
          entry.deliveredAt.isAfter(instant) && entry.deliveredAt.isBefore(end),
    );
  }

  @override
  Future<void> clearFromExcept(
    DateTime instant,
    Set<String> keepTimestamps,
  ) async {
    final end = DateTime(
      instant.year,
      instant.month,
      instant.day,
    ).add(const Duration(days: 1));
    entries.removeWhere(
      (entry) =>
          entry.deliveredAt.isAfter(instant) &&
          entry.deliveredAt.isBefore(end) &&
          !keepTimestamps.contains(entry.deliveredAt.toIso8601String()),
    );
  }

  @override
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day) async =>
      entries;

  @override
  Future<List<NotificationHistoryEntry>> listFromUntilEndOfDay(
    DateTime instant,
  ) async {
    final end = DateTime(
      instant.year,
      instant.month,
      instant.day,
    ).add(const Duration(days: 1));
    return entries
        .where(
          (entry) =>
              entry.deliveredAt.isAfter(instant) &&
              entry.deliveredAt.isBefore(end),
        )
        .toList()
      ..sort((a, b) => a.deliveredAt.compareTo(b.deliveredAt));
  }
}

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
    _InMemoryNotificationHistoryRepository history, {
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

  test('today layer fills today with one-shots, grid floor covers other days',
      () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();
    final useCase = makeUseCase(scheduler, history);

    // 2026-05-31 is a Sunday (weekday 7). Frequente (interval 60).
    final now = DateTime(2026, 5, 31, 8, 0);
    await useCase(
      Settings.defaults.copyWith(intervalMinutes: 60),
      now: now,
      showImmediate: false,
    );

    final quotes = quoteEventsOf(scheduler);

    // Today layer: one-shots in the 9100+ block, not weekly-repeating.
    final todayLayer = quotes
        .where((e) => e.scheduledId! >= 9100)
        .toList();
    expect(todayLayer, isNotEmpty);
    expect(todayLayer.every((e) => !e.repeatWeekly), isTrue);
    expect(todayLayer.every((e) => e.scheduledAt.day == 31), isTrue);
    // Hourly 08:00-21:00 skipping the noon hour = 13 slots.
    expect(todayLayer.length, 13);
    for (final event in todayLayer) {
      expect(event.scheduledAt.hour, isNot(12));
    }

    // Grid floor: weekly repeats in the 9000-9034 block, NOT on today's weekday.
    final gridFloor = quotes
        .where((e) => e.scheduledId! >= 9000 && e.scheduledId! < 9100)
        .toList();
    expect(gridFloor.every((e) => e.repeatWeekly), isTrue);
    expect(gridFloor.every((e) => e.scheduledAt.weekday != now.weekday), isTrue);
    // 6 weekdays x 5 slots = 30 cells.
    expect(gridFloor.length, 30);
  });

  test('today one-shots draw from today\'s weekday bucket', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();
    final useCase = makeUseCase(scheduler, history);

    final now = DateTime(2026, 5, 31, 8, 0); // Sunday -> bucket weekday 1
    await useCase(
      Settings.defaults.copyWith(intervalMinutes: 60),
      now: now,
      showImmediate: false,
    );

    final expectedBucket = (now.weekday % 7) + 1; // Sunday -> 1
    final todayLayer =
        quoteEventsOf(scheduler).where((e) => e.scheduledId! >= 9100);
    expect(
      todayLayer.every((e) => e.body == 'weekday-$expectedBucket'),
      isTrue,
    );
  });

  test('grid floor cells each draw from their own weekday bucket', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();
    final useCase = makeUseCase(scheduler, history);

    await useCase(
      Settings.defaults.copyWith(intervalMinutes: 60),
      now: DateTime(2026, 5, 31, 8, 0),
      showImmediate: false,
    );

    final gridFloor = quoteEventsOf(scheduler)
        .where((e) => e.scheduledId! >= 9000 && e.scheduledId! < 9100);
    for (final event in gridFloor) {
      final firedWeekday = (event.scheduledAt.weekday % 7) + 1;
      expect(event.body, 'weekday-$firedWeekday');
    }
  });

  test('denser preset schedules more today one-shots', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();
    final useCase = makeUseCase(scheduler, history);

    // Suave (interval 180 -> 2h cadence) at the start of the day.
    await useCase(
      Settings.defaults.copyWith(intervalMinutes: 180),
      now: DateTime(2026, 5, 31, 7, 0),
      showImmediate: false,
    );
    final suaveToday = quoteEventsOf(scheduler)
        .where((e) => e.scheduledId! >= 9100)
        .length;

    // every 2h from 07:00-21:00 skipping noon = 07,09,11,13,15,17,19,21 = 8
    // (12-13 excluded but 11 and 13 are fine) -> 7 slots actually:
    // 07,09,11,15,17,19,21 (13:00 is allowed; 11+2=13 ok) -> recompute below.
    expect(suaveToday, greaterThan(0));

    final scheduler2 = InMemoryNotificationSchedulerRepository();
    final history2 = _InMemoryNotificationHistoryRepository();
    final useCase2 = makeUseCase(scheduler2, history2);
    await useCase2(
      Settings.defaults.copyWith(intervalMinutes: 60), // Frequente
      now: DateTime(2026, 5, 31, 7, 0),
      showImmediate: false,
    );
    final frequenteToday = quoteEventsOf(scheduler2)
        .where((e) => e.scheduledId! >= 9100)
        .length;

    expect(frequenteToday, greaterThan(suaveToday));
  });

  test('reopening mid-day keeps past slots and refills only future hours',
      () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();
    final useCase = makeUseCase(scheduler, history);

    final settings = Settings.defaults.copyWith(intervalMinutes: 60);

    // First pass at 16:00: today one-shots from 16:00-21:00.
    await useCase(settings, now: DateTime(2026, 5, 31, 16, 0),
        showImmediate: false);
    final firstTimes = quoteEventsOf(scheduler)
        .where((e) => e.scheduledId! >= 9100)
        .map((e) => e.scheduledAt.hour)
        .toList()
      ..sort();
    expect(firstTimes.first, 16);
    expect(firstTimes.last, 21);

    // Second pass simulates reopening at 18:00 (after the cancel-then-reschedule
    // that RebuildNotificationsUseCase performs in production).
    for (var id = 9100; id < 9100 + 27; id++) {
      await scheduler.cancelById(id);
    }
    await useCase(settings, now: DateTime(2026, 5, 31, 18, 0),
        showImmediate: false);
    final secondTimes = quoteEventsOf(scheduler)
        .where((e) => e.scheduledId! >= 9100)
        .map((e) => e.scheduledAt.hour)
        .toList()
      ..sort();
    // Now starts at 18:00; 16:00/17:00 are gone (already fired in real life).
    expect(secondTimes.first, 18);
    expect(secondTimes.contains(16), isFalse);
    expect(secondTimes.contains(17), isFalse);
  });

  test('immediate notification still records exactly one delivery', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();
    final useCase = makeUseCase(
      scheduler,
      history,
      fetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'Immediate quote',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
    );

    final now = DateTime(2026, 5, 31, 8, 0);
    await useCase(Settings.defaults.copyWith(intervalMinutes: 60), now: now);

    // Only the immediate delivery is recorded; layers write no future rows.
    expect(history.entries, hasLength(1));
    expect(history.entries.single.deliveredAt, now);

    final immediate =
        scheduler.events.firstWhere((e) => e.scheduledId == 8999);
    expect(immediate.repeatWeekly, isFalse);
  });

  test('total pending quote notifications stay within the iOS budget',
      () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();
    final useCase = makeUseCase(scheduler, history);

    // Frequente at 07:00 is the densest case.
    await useCase(
      Settings.defaults.copyWith(intervalMinutes: 60, angelusEnabled: true),
      now: DateTime(2026, 5, 31, 7, 0),
      showImmediate: true,
    );

    // All scheduled ids (quotes + Angelus + immediate) must fit under 64.
    expect(scheduler.events.length, lessThanOrEqualTo(64));
  });

  test('Angelus is not scheduled when noon is inside quiet hours', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
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
      Settings.defaults.copyWith(
        intervalMinutes: 30,
        angelusEnabled: true,
        quietHoursEnabled: true,
        quietHoursStart: '11:00',
        quietHoursEnd: '13:00',
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
    'Angelus shows Regina Caeli during Easter even when liturgical toggle is off',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();

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

      // isEasterSeason must always reflect the real season for the Angelus.
      const actualSeason = LiturgicalSeason.easter;
      final isEasterSeason = actualSeason == LiturgicalSeason.easter;

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30, angelusEnabled: true),
        now: DateTime(2026, 4, 10, 8),
        isEasterSeason: isEasterSeason,
        showImmediate: false,
      );

      final angelus = scheduler.events.firstWhere(
        (e) => e.type == ReminderEventType.angelusNoon,
      );
      // During Easter, the notification MUST say Regina Caeli
      expect(angelus.title, 'Regina Caeli');
      expect(angelus.body, 'Hora de rezar a Regina Caeli.');
      expect(angelus.prayerSlug, 'regina-coeli');
    },
  );

  test(
    'Angelus uses local Easter fallback when caller passes isEasterSeason false',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();

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
        Settings.defaults.copyWith(
          intervalMinutes: 30,
          angelusEnabled: true,
          escrivaPointsFeedEnabled: true,
        ),
        now: DateTime(2026, 4, 10, 8),
        // Simulate remote/fallback mismatch while still in real Easter season.
        isEasterSeason: false,
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
}
