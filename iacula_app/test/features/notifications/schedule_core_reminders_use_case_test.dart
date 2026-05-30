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
  test('registers a weekly grid of repeating quote notifications', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        // Encode the weekday so we can assert the right bucket was used.
        final weekday = (now.weekday % 7) + 1;
        return Quote(
          text: 'weekday-$weekday',
          dayOfWeek: weekday,
          theme: 'tema',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    // interval 3h, default window 07:00-22:00 -> 6 slots/weekday -> 42 cells.
    final settings = Settings.defaults.copyWith(intervalMinutes: 180);
    await useCase(
      settings,
      now: DateTime(2026, 2, 21, 10, 0),
      showImmediate: false,
    );

    final quoteEvents = scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval)
        .toList();

    expect(quoteEvents, hasLength(42));
    expect(quoteEvents.every((e) => e.repeatWeekly), isTrue);

    // Ids are stable, unique, and within the reserved range.
    final ids = quoteEvents.map((e) => e.scheduledId!).toSet();
    expect(ids.length, 42);
    expect(ids.every((id) => id >= 9000 && id < 9000 + 7 * 6), isTrue);
  });

  test('each grid cell draws from its own weekday bucket', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        final weekday = (now.weekday % 7) + 1;
        return Quote(
          text: 'weekday-$weekday',
          dayOfWeek: weekday,
          theme: 'tema',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    await useCase(
      Settings.defaults.copyWith(intervalMinutes: 180),
      now: DateTime(2026, 2, 21, 10, 0),
      showImmediate: false,
    );

    final quoteEvents = scheduler.events.where(
      (e) => e.type == ReminderEventType.quoteInterval,
    );

    for (final event in quoteEvents) {
      final firedWeekday = (event.scheduledAt.weekday % 7) + 1;
      expect(
        event.body,
        'weekday-$firedWeekday',
        reason: 'cell firing on weekday $firedWeekday used the wrong bucket',
      );
    }

    // All 7 weekday buckets are represented across the grid.
    final bodies = quoteEvents.map((e) => e.body).toSet();
    expect(bodies, {
      for (var weekday = 1; weekday <= 7; weekday++) 'weekday-$weekday',
    });
  });

  test('quote scheduling writes no future history rows', () async {
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
      Settings.defaults.copyWith(intervalMinutes: 180),
      now: DateTime(2026, 2, 21, 10, 0),
      showImmediate: false,
    );

    // showImmediate:false -> no immediate delivery row, and the grid writes none.
    expect(history.entries, isEmpty);
  });

  test('immediate notification still records exactly one delivery', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'Immediate quote',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    final now = DateTime(2026, 2, 21, 10, 0);
    await useCase(Settings.defaults.copyWith(intervalMinutes: 180), now: now);

    expect(history.entries, hasLength(1));
    expect(history.entries.single.quoteText, 'Immediate quote');
    expect(history.entries.single.deliveredAt, now);

    // The immediate notification keeps id 8999 and is not weekly-repeating.
    final immediate = scheduler.events.firstWhere(
      (e) => e.scheduledId == 8999,
    );
    expect(immediate.repeatWeekly, isFalse);
  });

  test('re-running the pass replaces the same ids (idempotent)', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    var fetchCount = 0;
    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        fetchCount++;
        return Quote(
          text: 'Q-$fetchCount',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    final settings = Settings.defaults.copyWith(intervalMinutes: 180);
    final now = DateTime(2026, 2, 21, 10, 0);

    await useCase(settings, now: now, showImmediate: false);
    final firstRunIds = scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval)
        .map((e) => e.scheduledId)
        .toSet();

    await useCase(settings, now: now, showImmediate: false);
    final secondRunIds = scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval)
        .map((e) => e.scheduledId)
        .toSet();

    // Same id set both runs: the grid replaces in place rather than piling up.
    expect(secondRunIds, firstRunIds);
  });

  test('a daytime quiet window still leaves quote slots outside it', () async {
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

    // Midday quiet window (does not wrap midnight) must not collapse the
    // active window: slots before 11:00 and after 13:00 should remain.
    await useCase(
      Settings.defaults.copyWith(
        intervalMinutes: 60,
        quietHoursEnabled: true,
        quietHoursStart: '11:00',
        quietHoursEnd: '13:00',
      ),
      now: DateTime(2026, 2, 21, 8),
      showImmediate: false,
    );

    final quoteEvents = scheduler.events.where(
      (e) => e.type == ReminderEventType.quoteInterval,
    );
    expect(quoteEvents, isNotEmpty);

    // No cell may fire inside the 11:00-13:00 quiet window.
    for (final event in quoteEvents) {
      final minutes = event.scheduledAt.hour * 60 + event.scheduledAt.minute;
      final inQuiet = minutes >= 11 * 60 && minutes < 13 * 60;
      expect(
        inQuiet,
        isFalse,
        reason: 'cell scheduled inside quiet window: ${event.scheduledAt}',
      );
    }
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
