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
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class _InMemoryHistoryRepository implements NotificationHistoryRepository {
  final List<NotificationHistoryEntry> entries = [];

  @override
  Future<void> add(NotificationHistoryEntry entry) async => entries.add(entry);

  @override
  Future<void> clearFrom(DateTime instant) async {}

  @override
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day) async =>
      entries;
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
}) =>
    Settings.defaults.copyWith(
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

void main() {
  group('Full notification scheduling pipeline', () {
    test('schedules 64 quote notifications at correct intervals', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final now = DateTime(2026, 5, 12, 8, 0);
      await rebuild.call(
        _baseSettings(intervalMinutes: 30),
        isEasterSeason: false,
        showImmediate: false,
        now: now,
      );

      final quoteEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      expect(quoteEvents.length, 64);

      // First quote is 30 minutes from now
      expect(
        quoteEvents.first.scheduledAt,
        DateTime(2026, 5, 12, 8, 30),
      );

      // Each subsequent quote is 30 minutes apart
      for (var i = 1; i < quoteEvents.length; i++) {
        final gap = quoteEvents[i]
            .scheduledAt
            .difference(quoteEvents[i - 1].scheduledAt);
        expect(gap.inMinutes, 30, reason: 'gap between quote $i and ${i - 1}');
      }
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

    test('respects quiet hours — skips notifications during quiet window',
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
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      // First slot: 21:00 (OK, before quiet hours)
      expect(quoteEvents.first.scheduledAt.hour, 21);

      // Second slot should jump to 07:00 next day (after quiet hours)
      expect(quoteEvents[1].scheduledAt.hour, 7);
      expect(quoteEvents[1].scheduledAt.day, 13);

      // No notification should be in 22:00-06:59 range
      for (final event in quoteEvents) {
        final hour = event.scheduledAt.hour;
        final inQuietHours = hour >= 22 || hour < 7;
        expect(inQuietHours, isFalse,
            reason:
                'Notification at ${event.scheduledAt} is during quiet hours');
      }
    });

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

    test('rebuild does not wipe alarm notifications when rescheduling quotes',
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
    });

    test('showImmediate fires instant notification and writes history',
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
      final immediateId = ScheduleCoreRemindersUseCase.quoteScheduleIdBase - 1;
      final hasImmediate = scheduler.events
          .any((e) => e.scheduledId == immediateId);
      expect(hasImmediate, isTrue);

      // 1 immediate + 64 scheduled = 65 history entries
      expect(history.entries.length, 65);
      expect(history.entries.first.deliveredAt, now);
    });

    test('quote notification IDs use expected range 9000-9063', () async {
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

      for (final id in quoteIds) {
        expect(id, greaterThanOrEqualTo(9000));
        expect(id, lessThan(9064));
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

    test('liturgy hour alarms are scheduled with repeatDaily', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final settings = _baseSettings().copyWith(
        laudesEnabled: true,
        vespersEnabled: true,
        complineEnabled: true,
      );

      await rebuild.call(
        settings,
        isEasterSeason: false,
      );

      final liturgyEvents = scheduler.events.where((e) =>
          e.type == ReminderEventType.laudes ||
          e.type == ReminderEventType.vespers ||
          e.type == ReminderEventType.compline);

      for (final event in liturgyEvents) {
        expect(event.repeatDaily, isTrue,
            reason: '${event.type.name} should repeat daily');
        expect(event.isAlarm, isTrue,
            reason: '${event.type.name} should be an alarm');
      }
    });

    test('custom phrase notifications are scheduled', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final phraseRepo = _InMemoryCustomPhraseRepository();

      phraseRepo.phrases.add(CustomPhrase(
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
      ));

      final rebuild =
          _makeRebuild(scheduler, history, phraseRepo: phraseRepo);

      await rebuild.call(
        _baseSettings(),
        isEasterSeason: false,
      );

      final phraseEvents = scheduler.events
          .where((e) => e.type == ReminderEventType.customPhrase)
          .toList();

      expect(phraseEvents.length, 2);
      expect(phraseEvents.first.body, 'Minha frase pessoal');
    });

    test('changing interval reschedules at new cadence', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final now = DateTime(2026, 5, 12, 8, 0);

      // Schedule at 30min interval
      await rebuild.call(
        _baseSettings(intervalMinutes: 30),
        isEasterSeason: false,
        showImmediate: false,
        now: now,
      );

      final firstQuoteAt30 = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      expect(firstQuoteAt30.first.scheduledAt, DateTime(2026, 5, 12, 8, 30));

      // Reschedule at 60min interval
      await rebuild.call(
        _baseSettings(intervalMinutes: 60),
        isEasterSeason: false,
        showImmediate: false,
        now: now,
      );

      final firstQuoteAt60 = scheduler.events
          .where((e) => e.type == ReminderEventType.quoteInterval)
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      expect(firstQuoteAt60.first.scheduledAt, DateTime(2026, 5, 12, 9, 0));
    });

    test('all notification types coexist without ID collision', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final phraseRepo = _InMemoryCustomPhraseRepository();

      phraseRepo.phrases.add(CustomPhrase(
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
      ));

      final rebuild =
          _makeRebuild(scheduler, history, phraseRepo: phraseRepo);

      final settings = _baseSettings(angelusEnabled: true).copyWith(
        laudesEnabled: true,
        vespersEnabled: true,
      );

      await rebuild.call(
        settings,
        isEasterSeason: false,
      );

      final allIds = scheduler.events
          .map((e) => e.scheduledId ?? 0)
          .where((id) => id > 0)
          .toList();
      final uniqueIds = allIds.toSet();

      // All IDs should be unique — no collision
      expect(uniqueIds.length, allIds.length,
          reason: 'Notification IDs must not collide');

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

      expect(angelusEvents, isEmpty,
          reason: 'Angelus at noon should be skipped when noon is in quiet hours');
    });

    test('notifications have correct route targets', () async {
      final scheduler = InMemoryNotificationSchedulerRepository();
      final history = _InMemoryHistoryRepository();
      final rebuild = _makeRebuild(scheduler, history);

      final settings = _baseSettings(angelusEnabled: true).copyWith(
        laudesEnabled: true,
      );

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
}
