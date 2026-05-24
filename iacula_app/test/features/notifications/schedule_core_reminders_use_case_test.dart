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
  test(
    'schedules quote reminders and writes only immediate history entry',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();

      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              return const Quote(
                text: 'Sede santos, porque eu sou santo.',
                dayOfWeek: 1,
                theme: 'todos os santos',
                season: LiturgicalSeason.ordinary,
                imagePath: 'assets/seed/images/ordinary/1/E.jpg',
                feast: 'all-saints',
                feastName: 'todos os santos',
              );
            },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      final settings = Settings.defaults.copyWith(
        intervalMinutes: 15,
        language: 'pt-br',
      );
      final now = DateTime(2026, 2, 21, 10, 0);

      await useCase(settings, now: now);

      final allQuoteEvents =
          scheduler.events
              .where((e) => e.type == ReminderEventType.quoteInterval)
              .toList()
            ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      expect(allQuoteEvents.length, 65);

      expect(allQuoteEvents.first.scheduledId, 8999);
      expect(allQuoteEvents.first.scheduledAt, now);

      final scheduledEvents = allQuoteEvents.skip(1).toList();
      expect(scheduledEvents.length, 64);
      expect(scheduledEvents.first.title, 'Iacula');
      expect(scheduledEvents.first.body, 'Sede santos, porque eu sou santo.');
      expect(scheduledEvents.first.scheduledId, 9000);
      expect(
        scheduledEvents.first.scheduledAt,
        now.add(const Duration(minutes: 15)),
      );
      expect(scheduledEvents.last.scheduledId, 9063);
      expect(
        scheduledEvents.last.scheduledAt,
        now.add(const Duration(minutes: 15 * 64)),
      );
      final scheduledIds = scheduledEvents.map((e) => e.scheduledId).toSet();
      expect(scheduledIds.length, 64);

      // 1 immediate + 64 scheduled = 65 history entries
      expect(history.entries, hasLength(65));
      expect(
        history.entries.first.quoteText,
        'Sede santos, porque eu sou santo.',
      );
      expect(history.entries.first.theme, 'todos os santos');
      expect(history.entries.first.deliveredAt, now);

      final angelusEvent = scheduler.events.firstWhere(
        (e) => e.type == ReminderEventType.angelusNoon,
      );
      expect(angelusEvent.scheduledId, 200);
      expect(angelusEvent.prayerSlug, 'angelus');
    },
  );

  test(
    'showImmediate false does not enqueue immediate notification id 8999',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();

      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              return const Quote(
                text: 'A',
                dayOfWeek: 1,
                theme: 't',
                season: LiturgicalSeason.ordinary,
              );
            },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      final settings = Settings.defaults.copyWith(intervalMinutes: 5);
      final now = DateTime(2026, 2, 21, 10, 0);

      await useCase(settings, now: now, showImmediate: false);

      final quoteIds = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .map((e) => e.scheduledId)
          .toList();
      expect(quoteIds, isNot(contains(8999)));
      final firstQueued = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .map((e) => e.scheduledAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      expect(firstQueued, now.add(const Duration(minutes: 5)));
    },
  );

  test(
    'showImmediate false still writes history for scheduled quotes',
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

      final now = DateTime(2026, 2, 21, 10, 0);
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 15),
        now: now,
        showImmediate: false,
      );

      expect(history.entries, hasLength(64));
    },
  );

  test('earliest queued quote fires at now + intervalMinutes', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return Quote(
          text: 'Q',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    final now = DateTime(2026, 3, 1, 8, 0);
    await useCase(
      Settings.defaults.copyWith(intervalMinutes: 10),
      now: now,
      showImmediate: false,
    );

    final futureQuotes =
        scheduler.events
            .where((e) => e.type == ReminderEventType.quoteInterval)
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    expect(
      futureQuotes.first.scheduledAt,
      now.add(const Duration(minutes: 10)),
    );
    expect(futureQuotes.first.scheduledId, 9000);
  });

  test(
    'rebuilding preserves history entry delivered at current notification time',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();
      final deliveredAt = DateTime(2026, 2, 21, 12);
      history.entries.add(
        NotificationHistoryEntry(
          quoteText: 'Received Escriva notification',
          theme: 'Escriva',
          season: LiturgicalSeason.ordinary.name,
          deliveredAt: deliveredAt,
          source: QuoteSource.escrivaPoints.name,
          referenceLabel: 'Caminho, 1',
        ),
      );

      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              return Quote(
                text: 'Next Escriva notification',
                dayOfWeek: 1,
                theme: 'Escriva',
                season: LiturgicalSeason.ordinary,
                source: QuoteSource.escrivaPoints,
                referenceLabel: 'Caminho, 2',
              );
            },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      await useCase(
        Settings.defaults.copyWith(
          intervalMinutes: 15,
          escrivaPointsFeedEnabled: true,
        ),
        now: deliveredAt,
        showImmediate: false,
      );

      expect(
        history.entries.where(
          (entry) =>
              entry.quoteText == 'Received Escriva notification' &&
              entry.deliveredAt == deliveredAt,
        ),
        hasLength(1),
      );
    },
  );

  test('quiet hours skip queued quote slots inside the quiet window', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return Quote(
          text: 'Quote ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
          dayOfWeek: 1,
          theme: 'Tema',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    final now = DateTime(2026, 2, 21, 21, 50);
    await useCase(
      Settings.defaults.copyWith(
        intervalMinutes: 15,
        quietHoursEnabled: true,
        quietHoursStart: '22:00',
        quietHoursEnd: '07:00',
      ),
      now: now,
      showImmediate: false,
    );

    final queuedQuotes =
        scheduler.events
            .where((event) => event.type == ReminderEventType.quoteInterval)
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    expect(queuedQuotes, hasLength(64));
    expect(queuedQuotes.first.scheduledAt, DateTime(2026, 2, 22, 7, 0));

    for (final event in queuedQuotes) {
      final minutes = event.scheduledAt.hour * 60 + event.scheduledAt.minute;
      final inQuiet = minutes >= (22 * 60) || minutes < (7 * 60);
      expect(
        inQuiet,
        isFalse,
        reason: 'scheduled during quiet hours: ${event.scheduledAt}',
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

  test(
    'Angelus switches from Regina Caeli to Angelus across Pentecost boundary',
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

      // Schedule from May 21 2026 — Pentecost is May 24, so days 0-3 are Easter,
      // days 4-6 are ordinary time.
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30, angelusEnabled: true),
        now: DateTime(2026, 5, 21, 8),
        isEasterSeason: false,
        showImmediate: false,
      );

      final angelusEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.angelusNoon)
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      // May 21-24 are Easter season → Regina Caeli
      for (final event in angelusEvents.where(
        (e) => e.scheduledAt.day <= 24,
      )) {
        expect(event.title, 'Regina Caeli',
            reason: 'May ${event.scheduledAt.day} is still Easter season');
        expect(event.prayerSlug, 'regina-coeli');
      }

      // May 25+ are ordinary time → Angelus
      for (final event in angelusEvents.where(
        (e) => e.scheduledAt.day > 24,
      )) {
        expect(event.title, 'Angelus',
            reason: 'May ${event.scheduledAt.day} is after Pentecost');
        expect(event.prayerSlug, 'angelus');
      }

      expect(
        angelusEvents.where((e) => e.title == 'Regina Caeli'),
        isNotEmpty,
        reason: 'Should have at least one Regina Caeli before Pentecost',
      );
      expect(
        angelusEvents.where((e) => e.title == 'Angelus'),
        isNotEmpty,
        reason: 'Should have at least one Angelus after Pentecost',
      );
    },
  );

  test(
    'rebuild reuses existing history entries so OS notifications match the tab',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();
      final now = DateTime(2026, 5, 16, 10, 0);

      var fetchCount = 0;
      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              fetchCount++;
              return Quote(
                text: 'Quote-$fetchCount',
                dayOfWeek: 1,
                theme: 'tema',
                season: LiturgicalSeason.ordinary,
              );
            },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      final settings = Settings.defaults.copyWith(intervalMinutes: 30);

      // First run: writes fresh history entries.
      await useCase(settings, now: now, showImmediate: false);
      final firstRunTexts =
          history.entries.map((entry) => entry.quoteText).toList();
      expect(firstRunTexts, hasLength(64));

      // Capture the text of the first scheduled slot (10:30).
      final firstSlotTime = now.add(const Duration(minutes: 30));
      final originalFirstSlotText = history.entries
          .firstWhere((entry) => entry.deliveredAt == firstSlotTime)
          .quoteText;

      // Second run at the same time (e.g. settings toggled): must reuse quotes.
      fetchCount = 1000;
      await scheduler.cancelAll();
      await useCase(settings, now: now, showImmediate: false);

      // The 10:30 slot must still have the original quote text, not a new one.
      final reusedEntry = history.entries.firstWhere(
        (entry) => entry.deliveredAt == firstSlotTime,
      );
      expect(
        reusedEntry.quoteText,
        originalFirstSlotText,
        reason: 'Existing history entry must be reused, not replaced',
      );

      // OS notifications for today's slots must match history entries.
      final todayEnd = DateTime(2026, 5, 17);
      final scheduledQuotesToday =
          scheduler.events
              .where(
                (e) =>
                    e.type == ReminderEventType.quoteInterval &&
                    e.scheduledAt.isBefore(todayEnd),
              )
              .toList();
      for (final event in scheduledQuotesToday) {
        final matchingEntry = history.entries.firstWhere(
          (entry) => entry.deliveredAt == event.scheduledAt,
        );
        expect(
          event.body,
          matchingEntry.quoteText,
          reason:
              'OS notification at ${event.scheduledAt} must match history entry',
        );
      }
    },
  );

  test(
    'interval change removes orphaned history entries and fills new slots',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();
      final now = DateTime(2026, 5, 16, 10, 0);

      var fetchCount = 0;
      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              fetchCount++;
              return Quote(
                text: 'Q-$fetchCount',
                dayOfWeek: 1,
                theme: 'tema',
                season: LiturgicalSeason.ordinary,
              );
            },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      // First run at 15m interval.
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 15),
        now: now,
        showImmediate: false,
      );
      expect(history.entries, hasLength(64));
      final firstSlotTime = now.add(const Duration(minutes: 15));
      final firstSlotEntry = history.entries.firstWhere(
        (entry) => entry.deliveredAt == firstSlotTime,
      );

      // Switch to 30m interval and rebuild.
      await scheduler.cancelAll();
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30),
        now: now,
        showImmediate: false,
      );

      // 30m slots that existed in the 15m schedule should be reused.
      final thirtyMinSlot = now.add(const Duration(minutes: 30));
      final reusedEntry = history.entries.where(
        (entry) => entry.deliveredAt == thirtyMinSlot,
      );
      expect(reusedEntry, hasLength(1));

      // 15m-only slots (like 10:15) should be cleaned up.
      final orphanedSlot = history.entries.where(
        (entry) => entry.deliveredAt == firstSlotTime,
      );
      expect(
        orphanedSlot,
        isEmpty,
        reason: '15m slot must be removed after switching to 30m interval',
      );
    },
  );

  test(
    'past history entries are never deleted during rebuild',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();
      final pastEntry = NotificationHistoryEntry(
        quoteText: 'Past quote',
        theme: 'tema',
        season: LiturgicalSeason.ordinary.name,
        deliveredAt: DateTime(2026, 5, 16, 9, 0),
      );
      history.entries.add(pastEntry);

      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              return const Quote(
                text: 'New',
                dayOfWeek: 1,
                theme: 'tema',
                season: LiturgicalSeason.ordinary,
              );
            },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30),
        now: DateTime(2026, 5, 16, 10, 0),
        showImmediate: false,
      );

      final pastEntries = history.entries.where(
        (entry) => entry.quoteText == 'Past quote',
      );
      expect(
        pastEntries,
        hasLength(1),
        reason: 'Past entries must survive rebuild',
      );
    },
  );

}
