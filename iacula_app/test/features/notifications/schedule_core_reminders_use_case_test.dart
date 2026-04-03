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
          !entry.deliveredAt.isBefore(instant) &&
          entry.deliveredAt.isBefore(end),
    );
  }

  @override
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day) async =>
      entries;
}

void main() {
  test(
    'schedules quote history for today without depending on notification taps',
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

      expect(history.entries, hasLength(56));
      expect(
        history.entries.first.quoteText,
        'Sede santos, porque eu sou santo.',
      );
      expect(history.entries.first.theme, 'todos os santos');
      expect(history.entries.first.deliveredAt, now);
      expect(history.entries.last.deliveredAt, DateTime(2026, 2, 21, 23, 45));

      final angelusEvent = scheduler.events.firstWhere(
        (e) => e.type == ReminderEventType.angelusNoon,
      );
      expect(angelusEvent.scheduledId, 200);
      expect(angelusEvent.prayerSlug, 'angelus');
    },
  );

  test(
    'rebuilding reminders replaces future history for the same day',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();

      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              return Quote(
                text: 'Quote ${now.hour}:${now.minute}',
                dayOfWeek: 1,
                theme: 'Tema',
                season: LiturgicalSeason.ordinary,
                imagePath: null,
                feast: null,
                feastName: null,
              );
            },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 15),
        now: DateTime(2026, 2, 21, 10),
      );
      final firstRunCount = history.entries.length;

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30),
        now: DateTime(2026, 2, 21, 12),
      );

      expect(firstRunCount, 56);
      expect(
        history.entries
            .where(
              (entry) => !entry.deliveredAt.isBefore(DateTime(2026, 2, 21, 12)),
            )
            .length,
        23,
      );
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
    'showImmediate false does not add synthetic history entry at current time',
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

      expect(
        history.entries.where((entry) => entry.deliveredAt == now),
        isEmpty,
      );
      expect(
        history.entries.any(
          (entry) => entry.deliveredAt == now.add(const Duration(minutes: 15)),
        ),
        isTrue,
      );
    },
  );

  test(
    'showImmediate true skips immediate when a recent due quote already exists',
    () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryNotificationHistoryRepository();
      history.entries.add(
        NotificationHistoryEntry(
          quoteText: 'Recent scheduled quote',
          theme: 't',
          season: LiturgicalSeason.ordinary.name,
          deliveredAt: DateTime(2026, 2, 21, 21, 33),
        ),
      );

      final useCase = ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              return const Quote(
                text: 'Immediate candidate',
                dayOfWeek: 1,
                theme: 't',
                season: LiturgicalSeason.ordinary,
              );
            },
        notificationHistoryRepository: history,
        lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
      );

      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 15),
        now: DateTime(2026, 2, 21, 21, 35),
        showImmediate: true,
      );

      final immediateEvents = scheduler.events.where(
        (e) => e.type == ReminderEventType.quoteInterval && e.scheduledId == 8999,
      );
      expect(immediateEvents, isEmpty);
      expect(
        history.entries.where(
          (entry) => entry.deliveredAt == DateTime(2026, 2, 21, 21, 35),
        ),
        isEmpty,
      );
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
    'rebuilding preserves history entries delivered before current time',
    () async {
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

      // First run at 08:00 with 30-minute interval
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30),
        now: DateTime(2026, 2, 21, 8),
      );

      // Should have entries from 08:00 through 23:30
      expect(history.entries.length, 32);

      // Second run at 12:00 (simulating app reopen)
      await useCase(
        Settings.defaults.copyWith(intervalMinutes: 30),
        now: DateTime(2026, 2, 21, 12),
      );

      // Entries before 12:00 from first run must be preserved
      final preservedEntries = history.entries
          .where((e) => e.deliveredAt.isBefore(DateTime(2026, 2, 21, 12)))
          .toList();
      expect(preservedEntries, hasLength(8)); // 08:00, 08:30, ..., 11:30

      expect(preservedEntries.first.quoteText, 'Quote 8:00');
      expect(preservedEntries.last.quoteText, 'Quote 11:30');
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

      // The liturgical season toggle is OFF, but it IS Easter.
      // isEasterSeason must always reflect the real season for the Angelus,
      // regardless of the toggle (which only controls quote theming).
      const liturgicalSeasonEnabled = false;
      const actualSeason = LiturgicalSeason.easter;
      // Fixed: always use the real season for isEasterSeason
      final isEasterSeason = actualSeason == LiturgicalSeason.easter;

      await useCase(
        Settings.defaults.copyWith(
          intervalMinutes: 30,
          angelusEnabled: true,
          liturgicalSeasonEnabled: liturgicalSeasonEnabled,
        ),
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
}
