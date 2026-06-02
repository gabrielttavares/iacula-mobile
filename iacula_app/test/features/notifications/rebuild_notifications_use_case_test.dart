import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/phrase_schedule.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/notifications/application/use_cases/rebuild_notifications_use_case.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_season_transitions_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/schedule_intention_notifications_use_case.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class _EmptyCustomPhraseRepository implements CustomPhraseRepository {
  @override
  Future<void> delete(String id) async {}

  @override
  Future<CustomPhrase?> getById(String id) async => null;

  @override
  Future<List<CustomPhrase>> listAll() async => [];

  @override
  Future<void> save(CustomPhrase phrase) async {}

  @override
  Stream<List<CustomPhrase>> watchAll() => const Stream.empty();
}

final class _FakeLiturgicalSeasonService implements LiturgicalSeasonService {
  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async {
    return LiturgicalContext.ordinaryFallback;
  }

  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async {
    return LiturgicalSeason.ordinary;
  }
}

class _EmptySpiritualEntryRepository implements SpiritualEntryRepository {
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

final class _ManyPhrasesRepository implements CustomPhraseRepository {
  _ManyPhrasesRepository(this.count);
  final int count;

  @override
  Future<List<CustomPhrase>> listAll() async => List.generate(
        count,
        (i) => CustomPhrase(
          id: 'phrase-$i',
          text: 'Frase $i',
          isActive: true,
          displayAsNotification: true,
          useFixedSchedule: true,
          schedule: const PhraseSchedule(
            type: PhraseScheduleType.daily,
            times: ['08:00'],
          ),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      );

  @override
  Future<void> delete(String id) async {}
  @override
  Future<CustomPhrase?> getById(String id) async => null;
  @override
  Future<void> save(CustomPhrase phrase) async {}
  @override
  Stream<List<CustomPhrase>> watchAll() => const Stream.empty();
}

final class _ManyIntentionsRepository implements SpiritualEntryRepository {
  _ManyIntentionsRepository(this.count);
  final int count;

  @override
  SpiritualModule get module => SpiritualModule.prayerIntention;
  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async =>
      List.generate(
        count,
        (i) => SpiritualEntry(
          id: 'intention-$i',
          module: SpiritualModule.prayerIntention,
          title: 'Intenção $i',
          body: 'Reze por $i',
          scheduleJson: '{"type":"daily","times":["09:00"]}',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      );

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

RebuildNotificationsUseCase _makeRebuild(
  InMemoryNotificationSchedulerRepository scheduler, {
  required Future<Quote> Function({
    required String language,
    required DateTime now,
  })
  quoteFetcher,
  CustomPhraseRepository? phraseRepository,
  SpiritualEntryRepository? intentionRepository,
}) {
  return RebuildNotificationsUseCase(
    scheduler: scheduler,
    notificationHistoryRepository: InMemoryNotificationHistoryRepository(),
    lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    schedulePhraseNotifications: SchedulePhraseNotificationsUseCase(
      scheduler,
      phraseRepository ?? _EmptyCustomPhraseRepository(),
    ),
    scheduleIntentionNotifications: ScheduleIntentionNotificationsUseCase(
      scheduler,
      intentionRepository ?? _EmptySpiritualEntryRepository(),
    ),
    quoteFetcher: quoteFetcher,
  );
}

void main() {
  test('parallel rebuild calls complete without overlapping duplicate quote ids', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final rebuild = _makeRebuild(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return Quote(
          text: 'x',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
    );

    final settings = Settings.defaults.copyWith(notificationsEnabled: true);
    final season = await _FakeLiturgicalSeasonService().getCurrentSeason();

    await Future.wait([
      rebuild.call(settings, isEasterSeason: season == LiturgicalSeason.easter, showImmediate: false),
      rebuild.call(settings, isEasterSeason: season == LiturgicalSeason.easter, showImmediate: false),
    ]);

    final quoteEvents = scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval)
        .toList();
    final quoteIds = quoteEvents.map((e) => e.scheduledId).toSet();
    // Concurrent rebuilds must not produce overlapping/duplicate ids: the set of
    // ids equals the number of scheduled quote events, and there is at least one.
    expect(quoteEvents, isNotEmpty);
    expect(quoteIds.length, quoteEvents.length);
  });

  test('showImmediate true keeps immediate quote channel (id 8999)', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final rebuild = _makeRebuild(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'primeira',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
    );

    final settings = Settings.defaults.copyWith(notificationsEnabled: true);
    final season = await _FakeLiturgicalSeasonService().getCurrentSeason();

    await rebuild.call(
      settings,
      isEasterSeason: season == LiturgicalSeason.easter,
      showImmediate: true,
    );

    expect(
      scheduler.events.any(
        (e) => e.type == ReminderEventType.quoteInterval && e.scheduledId == 8999,
      ),
      isTrue,
    );
  });

  test('first rebuild throws but second rebuild still runs successfully', () async {
    var fetches = 0;
    final scheduler = InMemoryNotificationSchedulerRepository();
    final rebuild = _makeRebuild(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        fetches++;
        if (fetches == 1) {
          throw StateError('boom');
        }
        return const Quote(
          text: 'ok',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
    );

    final settings = Settings.defaults.copyWith(notificationsEnabled: true);
    final season = await _FakeLiturgicalSeasonService().getCurrentSeason();

    await expectLater(
      rebuild.call(
        settings,
        isEasterSeason: season == LiturgicalSeason.easter,
        showImmediate: false,
      ),
      throwsA(isA<StateError>()),
    );

    await rebuild.call(
      settings,
      isEasterSeason: season == LiturgicalSeason.easter,
      showImmediate: false,
    );
    expect(
      scheduler.events.where((e) => e.type == ReminderEventType.quoteInterval),
      isNotEmpty,
    );
  });

  test('first concurrent rebuild fails but second still schedules', () async {
    var fetches = 0;
    final scheduler = InMemoryNotificationSchedulerRepository();
    final rebuild = _makeRebuild(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        fetches++;
        if (fetches == 1) {
          throw StateError('boom');
        }
        return const Quote(
          text: 'ok',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
    );

    final settings = Settings.defaults.copyWith(notificationsEnabled: true);
    final season = await _FakeLiturgicalSeasonService().getCurrentSeason();

    final first = rebuild.call(
      settings,
      isEasterSeason: season == LiturgicalSeason.easter,
      showImmediate: false,
    );
    final second = rebuild.call(
      settings,
      isEasterSeason: season == LiturgicalSeason.easter,
      showImmediate: false,
    );

    await expectLater(first, throwsA(isA<StateError>()));
    await second;
    expect(
      scheduler.events.where((e) => e.type == ReminderEventType.quoteInterval),
      isNotEmpty,
    );
  });

  test('rebuild schedules season transition notifications', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final rebuild = _makeRebuild(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'x',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
    );

    final settings = Settings.defaults.copyWith(notificationsEnabled: true);
    // January 2026: both Easter (April 5) and Pentecost+1 (May 25) are future
    final now = DateTime(2026, 1, 15, 10, 0);

    await rebuild.call(
      settings,
      isEasterSeason: false,
      showImmediate: false,
      now: now,
    );

    final transitions = scheduler.events
        .where((e) => e.type == ReminderEventType.seasonTransition)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    expect(transitions, hasLength(2));
    expect(
      transitions[0].scheduledId,
      ScheduleSeasonTransitionsUseCase.easterTransitionId,
    );
    expect(
      transitions[1].scheduledId,
      ScheduleSeasonTransitionsUseCase.pentecostTransitionId,
    );
  });

  test('total pending never exceeds the 64 iOS cap under heavy load', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final rebuild = _makeRebuild(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'x',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
      // Far more reminders than the budget can hold.
      phraseRepository: _ManyPhrasesRepository(40),
      intentionRepository: _ManyIntentionsRepository(40),
    );

    final settings = Settings.defaults.copyWith(
      notificationsEnabled: true,
      angelusEnabled: true,
    );

    await rebuild.call(
      settings,
      isEasterSeason: false,
      showImmediate: false,
      now: DateTime(2026, 1, 15, 10, 0),
    );

    expect(scheduler.events.length, lessThanOrEqualTo(64));
  });

  test('sacred reminders win over quotes when the budget is tight', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final rebuild = _makeRebuild(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'x',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
      // 40 intentions × 1 time would alone exceed the post-quote headroom;
      // they must still all be scheduled, with quotes ceding slots first.
      intentionRepository: _ManyIntentionsRepository(40),
    );

    final settings = Settings.defaults.copyWith(
      notificationsEnabled: true,
      angelusEnabled: true,
    );

    await rebuild.call(
      settings,
      isEasterSeason: false,
      showImmediate: false,
      now: DateTime(2026, 1, 15, 10, 0),
    );

    expect(scheduler.events.length, lessThanOrEqualTo(64));

    final intentionCount = scheduler.events
        .where((e) => e.type == ReminderEventType.prayerIntentionReminder)
        .length;
    final quoteCount = scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval)
        .length;

    // Every intention got a slot; quotes absorbed the squeeze.
    expect(intentionCount, 40);
    expect(quoteCount, greaterThan(0));
  });
}
