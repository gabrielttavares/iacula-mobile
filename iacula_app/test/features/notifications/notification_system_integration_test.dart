import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/phrase_schedule.dart';
import 'package:iacula_app/features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/application/use_cases/rebuild_notifications_use_case.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/schedule_intention_notifications_use_case.dart';
import 'package:iacula_app/features/quotes/application/use_cases/get_next_quote_use_case.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/quotes/infrastructure/repositories/in_memory_disabled_quotes_repository.dart';
import 'package:iacula_app/features/quotes/infrastructure/repositories/in_memory_quote_indices_repository.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class _InMemoryHistoryRepository
    implements NotificationHistoryRepository {
  final List<NotificationHistoryEntry> entries = [];

  @override
  Future<void> add(NotificationHistoryEntry entry) async {
    final alreadyExists = entries.any(
      (current) =>
          current.quoteText == entry.quoteText &&
          current.deliveredAt == entry.deliveredAt,
    );
    if (alreadyExists) return;
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

final class _InMemoryCustomPhraseRepository implements CustomPhraseRepository {
  final List<CustomPhrase> phrases = [];

  @override
  Future<List<CustomPhrase>> listAll() async => phrases;

  @override
  Future<CustomPhrase?> getById(String id) async =>
      phrases.where((p) => p.id == id).firstOrNull;

  @override
  Future<void> save(CustomPhrase phrase) async {
    phrases.removeWhere((p) => p.id == phrase.id);
    phrases.add(phrase);
  }

  @override
  Future<void> delete(String id) async {
    phrases.removeWhere((p) => p.id == id);
  }

  @override
  Stream<List<CustomPhrase>> watchAll() => const Stream.empty();
}

final class _EmptyIntentionRepository implements SpiritualEntryRepository {
  @override
  SpiritualModule get module => SpiritualModule.prayerIntention;

  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async =>
      [];

  @override
  Future<List<SpiritualEntry>> listDirty() async => [];

  @override
  Future<void> saveLocal(SpiritualEntry entry) async {}

  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {}

  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {}

  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {}
}

final class _EmptyCustomPhraseRepository implements CustomPhraseRepository {
  @override
  Future<List<CustomPhrase>> listAll() async => const [];

  @override
  Future<CustomPhrase?> getById(String id) async => null;

  @override
  Future<void> save(CustomPhrase phrase) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Stream<List<CustomPhrase>> watchAll() => const Stream.empty();
}

final class _FakeQuoteContentRepository implements QuoteContentRepository {
  _FakeQuoteContentRepository({
    required this.quotesByDay,
    required this.imagesByDay,
  });

  final Map<String, DayQuotes> quotesByDay;
  final Map<int, List<String>> imagesByDay;

  @override
  Future<Map<String, DayQuotes>> loadQuotes({
    required String language,
    required LiturgicalSeason season,
  }) async {
    return quotesByDay;
  }

  @override
  Future<List<String>> listDayImages({
    required int dayOfWeek,
    required LiturgicalSeason season,
  }) async {
    return imagesByDay[dayOfWeek] ?? const <String>[];
  }

  @override
  Future<List<String>> loadFeastQuotes(String feastSlug) async {
    return const <String>[];
  }

  @override
  Future<String?> getFeastImagePath(String feastSlug) async {
    return null;
  }
}

Quote _makeQuote(int index) => Quote(
  text: 'Jaculatória #$index',
  dayOfWeek: 1,
  theme: 'Tema',
  season: LiturgicalSeason.ordinary,
);

Settings _baseSettings({
  int intervalMinutes = 30,
  bool notificationsEnabled = true,
  bool angelusEnabled = true,
  bool quietHoursEnabled = false,
  String quietHoursStart = '22:00',
  String quietHoursEnd = '07:00',
}) => Settings.defaults.copyWith(
  intervalMinutes: intervalMinutes,
  language: 'pt-br',
  onboardingCompleted: true,
  notificationsEnabled: notificationsEnabled,
  angelusEnabled: angelusEnabled,
  quietHoursEnabled: quietHoursEnabled,
  quietHoursStart: quietHoursStart,
  quietHoursEnd: quietHoursEnd,
);

RebuildNotificationsUseCase _makeRebuild(
  InMemoryNotificationSchedulerRepository scheduler,
  _InMemoryHistoryRepository history, {
  _InMemoryCustomPhraseRepository? phraseRepo,
  SpiritualEntryRepository? intentionRepo,
}) {
  final phraseRepository = phraseRepo ?? _InMemoryCustomPhraseRepository();
  final intentionRepository = intentionRepo ?? _EmptyIntentionRepository();
  var quoteCounter = 0;
  return RebuildNotificationsUseCase(
    scheduler: scheduler,
    notificationHistoryRepository: history,
    lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    scheduleLiturgyReminders: ScheduleLiturgyRemindersUseCase(scheduler),
    schedulePhraseNotifications: SchedulePhraseNotificationsUseCase(
      scheduler,
      phraseRepository,
    ),
    scheduleIntentionNotifications: ScheduleIntentionNotificationsUseCase(
      scheduler,
      intentionRepository,
    ),
    quoteFetcher: ({required String language, required DateTime now}) async {
      quoteCounter++;
      return _makeQuote(quoteCounter);
    },
  );
}

RebuildNotificationsUseCase _makeRebuildWithQuoteUseCase(
  InMemoryNotificationSchedulerRepository scheduler,
  _InMemoryHistoryRepository history, {
  required QuoteContentRepository contentRepository,
}) {
  final quoteUseCase = GetNextQuoteUseCase(
    contentRepository: contentRepository,
    indicesRepository: InMemoryQuoteIndicesRepository(),
    disabledQuotesRepository: InMemoryDisabledQuotesRepository(),
    customPhraseRepository: _EmptyCustomPhraseRepository(),
  );

  return RebuildNotificationsUseCase(
    scheduler: scheduler,
    notificationHistoryRepository: history,
    lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    scheduleLiturgyReminders: ScheduleLiturgyRemindersUseCase(scheduler),
    schedulePhraseNotifications: SchedulePhraseNotificationsUseCase(
      scheduler,
      _InMemoryCustomPhraseRepository(),
    ),
    scheduleIntentionNotifications: ScheduleIntentionNotificationsUseCase(
      scheduler,
      _EmptyIntentionRepository(),
    ),
    quoteFetcher: ({required String language, required DateTime now}) {
      return quoteUseCase.call(language: language, now: now);
    },
  );
}

void main() {
  group('Full notification scheduling pipeline', () {
    test('registers a weekly grid of repeating quote notifications', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final now = DateTime(2026, 5, 12, 8, 0);
      // interval 180m, window 07:00-22:00 -> 6 slots/weekday -> 42 cells.
      await rebuild.call(
        _baseSettings(intervalMinutes: 180),
        isEasterSeason: false,
        showImmediate: false,
        now: now,
      );

      final quoteEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .toList();

      expect(quoteEvents.length, 42);
      // Every cell is an OS-owned weekly repeat.
      expect(quoteEvents.every((e) => e.repeatWeekly), isTrue);

      // All 7 weekdays are represented.
      final weekdays = quoteEvents
          .map((e) => e.scheduledAt.weekday)
          .toSet();
      expect(weekdays.length, 7);
    });

    test('schedules Angelus at noon with repeatDaily', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      // Use a date outside Easter season (June)
      final now = DateTime(2026, 6, 15, 8, 0);
      await rebuild.call(
        _baseSettings(angelusEnabled: true),
        isEasterSeason: false,
        now: now,
      );

      final angelusEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.angelusNoon)
          .toList();

      expect(angelusEvents.length, 1);
      expect(angelusEvents.first.repeatDaily, isTrue);
      expect(angelusEvents.first.scheduledAt.hour, 12);
      expect(angelusEvents.first.scheduledAt.minute, 0);
      expect(angelusEvents.first.title, 'Angelus');
      expect(angelusEvents.first.isAlarm, isTrue);
    });

    test('uses Regina Caeli title during Easter season', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final now = DateTime(2026, 4, 10, 8, 0);
      await rebuild.call(
        _baseSettings(angelusEnabled: true),
        isEasterSeason: true,
        now: now,
      );

      final angelusEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.angelusNoon)
          .toList();

      expect(angelusEvents.length, 1);
      expect(angelusEvents.first.title, 'Regina Caeli');
      expect(angelusEvents.first.prayerSlug, 'regina-coeli');
    });

    test('skips Angelus when disabled', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      await rebuild.call(
        _baseSettings(angelusEnabled: false),
        isEasterSeason: false,
      );

      final angelusEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.angelusNoon)
          .toList();

      expect(angelusEvents, isEmpty);
    });

    test(
      'respects quiet hours — skips notifications during quiet window',
      () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final history = _InMemoryHistoryRepository();
        final rebuild = _makeRebuild(scheduler, history);

        final now = DateTime(2026, 5, 12, 20, 0);
        await rebuild.call(
          _baseSettings(
            intervalMinutes: 60,
            quietHoursEnabled: true,
            quietHoursStart: '22:00',
            quietHoursEnd: '07:00',
          ),
          isEasterSeason: false,
          showImmediate: false,
          now: now,
        );

        final quoteEvents = scheduler.events
            .where((e) => e.type == ReminderEventType.quoteInterval)
            .toList();

        expect(quoteEvents, isNotEmpty);

        // No cell may fire inside the 22:00-06:59 quiet window, on any weekday.
        for (final event in quoteEvents) {
          final hour = event.scheduledAt.hour;
          final inQuietHours = hour >= 22 || hour < 7;
          expect(
            inQuietHours,
            isFalse,
            reason:
                'Notification at ${event.scheduledAt} is during quiet hours',
          );
        }
      },
    );

    test('disabling notifications cancels all', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      // Schedule notifications first
      await rebuild.call(
        _baseSettings(notificationsEnabled: true),
        isEasterSeason: false,
      );
      expect(scheduler.events, isNotEmpty);

      // Now disable
      await rebuild.call(
        _baseSettings(notificationsEnabled: false),
        isEasterSeason: false,
      );
      expect(scheduler.events, isEmpty);
    });

    test(
      'rebuild does not wipe alarm notifications when rescheduling quotes',
      () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final history = _InMemoryHistoryRepository();
        final rebuild = _makeRebuild(scheduler, history);

        // Initial schedule
        final now = DateTime(2026, 5, 12, 8, 0);
        await rebuild.call(
          _baseSettings(angelusEnabled: true),
          isEasterSeason: false,
          now: now,
        );

        final initialAngelus = scheduler.events
            .where((e) => e.type == ReminderEventType.angelusNoon)
            .toList();
        expect(initialAngelus.length, 1);

        // Rebuild again (simulates app resume health check)
        await rebuild.call(
          _baseSettings(angelusEnabled: true),
          isEasterSeason: false,
          showImmediate: false,
          now: now.add(const Duration(minutes: 5)),
        );

        // Angelus should still be present (not wiped by targeted cancel)
        final afterRebuild = scheduler.events
            .where((e) => e.type == ReminderEventType.angelusNoon)
            .toList();
        expect(afterRebuild.length, 1);
      },
    );

    test(
      'showImmediate fires instant notification and writes history',
      () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final history = _InMemoryHistoryRepository();
        final rebuild = _makeRebuild(scheduler, history);

        final now = DateTime(2026, 5, 12, 8, 0);
        await rebuild.call(
          _baseSettings(),
          isEasterSeason: false,
          showImmediate: true,
          now: now,
        );

        // Should have immediate notification (id 8999)
        final immediateId =
            ScheduleCoreRemindersUseCase.quoteScheduleIdBase - 1;
        final hasImmediate = scheduler.events.any(
          (e) => e.scheduledId == immediateId,
        );
        expect(hasImmediate, isTrue);

        // Only the immediate delivery is recorded; the grid writes no rows.
        expect(history.entries.length, 1);
        expect(history.entries.first.deliveredAt, now);
      },
    );

    test('quote notification IDs stay within the weekly-grid range', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      await rebuild.call(
        _baseSettings(),
        isEasterSeason: false,
        showImmediate: false,
      );

      final quoteIds = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .map((e) => e.scheduledId!)
          .toSet();

      // Grid ids span 9000 .. 9000 + 7*6 (exclusive).
      for (final id in quoteIds) {
        expect(id, greaterThanOrEqualTo(9000));
        expect(id, lessThan(9000 + 7 * 6));
      }
    });

    test('Angelus notification ID is 200', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      await rebuild.call(
        _baseSettings(angelusEnabled: true),
        isEasterSeason: false,
      );

      final pendingIds = await scheduler.pendingNotificationIds();
      expect(pendingIds, contains(200));
    });

    test(
      'weekday quote and image bags continue across rebuilds after crossing into another weekday',
      () async {
        final scheduler = InMemoryNotificationSchedulerRepository();
        final history = _InMemoryHistoryRepository();
        final rebuild = _makeRebuildWithQuoteUseCase(
          scheduler,
          history,
          contentRepository: _FakeQuoteContentRepository(
            quotesByDay: {
              '5': const DayQuotes(
                day: 'Quinta-feira',
                theme: 'Eucaristia',
                quotes: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9'],
              ),
              '6': const DayQuotes(
                day: 'Sexta-feira',
                theme: 'Cruz',
                quotes: ['F1', 'F2'],
              ),
            },
            imagesByDay: {
              5: const [
                'thu-1.jpg',
                'thu-2.jpg',
                'thu-3.jpg',
                'thu-4.jpg',
                'thu-5.jpg',
                'thu-6.jpg',
              ],
              6: const ['fri-1.jpg', 'fri-2.jpg'],
            },
          ),
        );

        // Helper: the Thursday (weekday 4) grid cells' quote texts.
        Set<String> thursdayQuotes() => scheduler.events
            .where(
              (e) =>
                  e.type == ReminderEventType.quoteInterval &&
                  e.scheduledAt.weekday == DateTime.thursday,
            )
            .map((e) => e.body)
            .toSet();

        // First build. interval 60m over 08:00-22:00 capped at 6 -> 6 cells
        // per weekday, but Thursday's bucket only has 6 quotes, so the bag
        // yields all 6 distinct before repeating.
        final firstNow = DateTime(2026, 5, 14, 20, 0);
        await rebuild.call(
          _baseSettings(intervalMinutes: 60),
          isEasterSeason: false,
          showImmediate: false,
          now: firstNow,
        );
        const thursdayBucket = {
          'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9',
        };
        final firstQuotes = thursdayQuotes();
        expect(firstQuotes, isNotEmpty);
        // Every Thursday quote drawn must come from Thursday's bucket.
        expect(firstQuotes.every(thursdayBucket.contains), isTrue);

        // Rebuild a few times: the bag keeps advancing through Thursday's
        // bucket rather than resetting to the same draw every time.
        final draws = <Set<String>>[firstQuotes];
        for (var i = 0; i < 3; i++) {
          await scheduler.cancelAll();
          await rebuild.call(
            _baseSettings(intervalMinutes: 60),
            isEasterSeason: false,
            showImmediate: false,
            now: firstNow.add(Duration(minutes: 10 * (i + 1))),
          );
          draws.add(thursdayQuotes());
        }

        // The bag rotates: not every rebuild produces the identical set.
        final allIdentical = draws.every((d) => d.containsAll(draws.first) &&
            draws.first.containsAll(d));
        expect(
          allIdentical,
          isFalse,
          reason: 'weekday bag must advance across rebuilds, not repeat',
        );
      },
    );

    test('liturgy hour alarms are scheduled with repeatDaily', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final settings = _baseSettings().copyWith(
        laudesEnabled: true,
        vespersEnabled: true,
        complineEnabled: true,
      );

      await rebuild.call(settings, isEasterSeason: false);

      final liturgyEvents = scheduler.events.where(
        (e) =>
            e.type == ReminderEventType.laudes ||
            e.type == ReminderEventType.vespers ||
            e.type == ReminderEventType.compline,
      );

      for (final event in liturgyEvents) {
        expect(
          event.repeatDaily,
          isTrue,
          reason: '${event.type.name} should repeat daily',
        );
        expect(
          event.isAlarm,
          isTrue,
          reason: '${event.type.name} should be an alarm',
        );
      }
    });

    test('custom phrase notifications are scheduled', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final phraseRepo = _InMemoryCustomPhraseRepository();

      phraseRepo.phrases.add(
        CustomPhrase(
          id: 'phrase-1',
          text: 'Minha frase pessoal',
          isActive: true,
          displayAsNotification: true,
          useFixedSchedule: true,
          schedule: PhraseSchedule(
            type: PhraseScheduleType.daily,
            times: ['09:00', '15:00'],
          ),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );

      final rebuild = _makeRebuild(scheduler, history, phraseRepo: phraseRepo);

      await rebuild.call(_baseSettings(), isEasterSeason: false);

      final phraseEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.customPhrase)
          .toList();

      expect(phraseEvents.length, 2);
      expect(phraseEvents.first.body, 'Minha frase pessoal');
    });

    test('changing interval changes the number of daily slots', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final now = DateTime(2026, 5, 12, 8, 0);

      // 180m interval over 07:00-22:00 -> 6 slots/weekday (capped).
      await rebuild.call(
        _baseSettings(intervalMinutes: 180),
        isEasterSeason: false,
        showImmediate: false,
        now: now,
      );
      final cellsAt180 = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .length;
      expect(cellsAt180, 6 * 7);

      // 360m interval over 07:00-22:00 -> 3 slots/weekday (07:00, 13:00, 19:00).
      await rebuild.call(
        _baseSettings(intervalMinutes: 360),
        isEasterSeason: false,
        showImmediate: false,
        now: now,
      );
      final cellsAt360 = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .length;
      expect(cellsAt360, 3 * 7);
    });

    test('all notification types coexist without ID collision', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final phraseRepo = _InMemoryCustomPhraseRepository();

      phraseRepo.phrases.add(
        CustomPhrase(
          id: 'phrase-coexist',
          text: 'Coexist phrase',
          isActive: true,
          displayAsNotification: true,
          useFixedSchedule: true,
          schedule: PhraseSchedule(
            type: PhraseScheduleType.daily,
            times: ['10:00'],
          ),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );

      final rebuild = _makeRebuild(scheduler, history, phraseRepo: phraseRepo);

      final settings = _baseSettings(
        angelusEnabled: true,
      ).copyWith(laudesEnabled: true, vespersEnabled: true);

      await rebuild.call(settings, isEasterSeason: false);

      final allIds = scheduler.events
          .map((e) => e.scheduledId ?? 0)
          .where((id) => id > 0)
          .toList();
      final uniqueIds = allIds.toSet();

      // All IDs should be unique — no collision
      expect(
        uniqueIds.length,
        allIds.length,
        reason: 'Notification IDs must not collide',
      );

      // Verify each type was scheduled
      final types = scheduler.events.map((e) => e.type).toSet();
      expect(types, contains(ReminderEventType.quoteInterval));
      expect(types, contains(ReminderEventType.angelusNoon));
      expect(types, contains(ReminderEventType.laudes));
      expect(types, contains(ReminderEventType.vespers));
      expect(types, contains(ReminderEventType.customPhrase));
    });

    test('Angelus not scheduled during quiet hours at noon', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final now = DateTime(2026, 5, 12, 8, 0);
      await rebuild.call(
        _baseSettings(
          angelusEnabled: true,
          quietHoursEnabled: true,
          quietHoursStart: '11:00',
          quietHoursEnd: '13:00',
        ),
        isEasterSeason: false,
        now: now,
      );

      final angelusEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.angelusNoon)
          .toList();

      expect(
        angelusEvents,
        isEmpty,
        reason: 'Angelus at noon should be skipped when noon is in quiet hours',
      );
    });

    test('notifications have correct route targets', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final settings = _baseSettings(
        angelusEnabled: true,
      ).copyWith(laudesEnabled: true);

      await rebuild.call(settings, isEasterSeason: false);

      for (final event in scheduler.events) {
        switch (event.type) {
          case ReminderEventType.quoteInterval:
            expect(event.routeTarget, NotificationRouteTarget.home);
          case ReminderEventType.angelusNoon:
            expect(event.routeTarget, NotificationRouteTarget.prayer);
            expect(event.prayerSlug, isNotNull);
          case ReminderEventType.laudes:
          case ReminderEventType.vespers:
            expect(event.routeTarget, NotificationRouteTarget.alarm);
          case ReminderEventType.customPhrase:
            expect(event.routeTarget, NotificationRouteTarget.home);
          case ReminderEventType.prayerIntentionReminder:
            expect(event.routeTarget, NotificationRouteTarget.prayerIntention);
          default:
            break;
        }
      }
    });
  });


  group('Weekly-grid quote scheduling', () {
    test('grid scheduling writes no future history rows', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final now = DateTime(2026, 5, 16, 9, 0);

      // showImmediate:false -> the grid must not write any history entries.
      await rebuild.call(
        _baseSettings(intervalMinutes: 180),
        isEasterSeason: false,
        showImmediate: false,
        now: now,
      );

      final quoteEntries = history.entries
          .where((e) => e.deliveredAt.isAfter(now))
          .toList();
      expect(
        quoteEntries,
        isEmpty,
        reason: 'weekly-grid quotes no longer predict future history rows',
      );
    });

    test('immediate delivery is recorded and past entries survive rebuild',
        () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      // Seed a past, already-delivered entry.
      final pastDelivery = DateTime(2026, 5, 16, 8, 0);
      history.entries.add(
        NotificationHistoryEntry(
          quoteText: 'Past delivered quote',
          theme: 'tema',
          season: LiturgicalSeason.ordinary.name,
          deliveredAt: pastDelivery,
        ),
      );

      final now = DateTime(2026, 5, 16, 10, 0);

      // Rebuild with an immediate notification: records exactly one new row.
      await rebuild.call(
        _baseSettings(intervalMinutes: 180),
        isEasterSeason: false,
        showImmediate: true,
        now: now,
      );

      // The past delivery survives untouched.
      final survivingPast = history.entries.where(
        (e) =>
            e.deliveredAt == pastDelivery &&
            e.quoteText == 'Past delivered quote',
      );
      expect(survivingPast, hasLength(1));

      // Exactly one new delivery row at `now` for the immediate notification.
      final immediateRows = history.entries.where(
        (e) => e.deliveredAt == now,
      );
      expect(immediateRows, hasLength(1));
    });
  });
}
