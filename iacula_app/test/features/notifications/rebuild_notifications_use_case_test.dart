import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/notifications/application/use_cases/rebuild_notifications_use_case.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/short_interval_reliability.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

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

RebuildNotificationsUseCase _makeRebuild(
  InMemoryNotificationSchedulerRepository scheduler, {
  required Future<Quote> Function({
    required String language,
    required DateTime now,
  })
  quoteFetcher,
}) {
  return RebuildNotificationsUseCase(
    scheduler: scheduler,
    notificationHistoryRepository: InMemoryNotificationHistoryRepository(),
    lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    scheduleLiturgyReminders: ScheduleLiturgyRemindersUseCase(scheduler),
    schedulePhraseNotifications: SchedulePhraseNotificationsUseCase(
      scheduler,
      _EmptyCustomPhraseRepository(),
    ),
    quoteFetcher: quoteFetcher,
    batchFetcherForSettings: (_) => null,
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

    final quoteScheduled =
        scheduler.events
            .where((e) => e.type == ReminderEventType.quoteInterval)
            .map((e) => e.scheduledId)
            .toSet();
    expect(quoteScheduled.length, 64);
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

    final second = await rebuild.call(
      settings,
      isEasterSeason: season == LiturgicalSeason.easter,
      showImmediate: false,
    );
    expect(second.shortIntervalReliabilityNotGuaranteed, isFalse);
    expect(
      scheduler.events.where((e) => e.type == ReminderEventType.quoteInterval).length,
      64,
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
    final secondResult = await second;
    expect(secondResult.shortIntervalReliabilityNotGuaranteed, isFalse);
    expect(
      scheduler.events.where((e) => e.type == ReminderEventType.quoteInterval).length,
      64,
    );
  });

  test('short interval with exact reliability ok reports notGuaranteed false', () async {
    final scheduler = InMemoryNotificationSchedulerRepository()
      ..shortIntervalReliabilityOverrideForTest = ShortIntervalReliability.ok;
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

    final settings = Settings.defaults.copyWith(
      notificationsEnabled: true,
      intervalMinutes: 5,
    );
    final season = await _FakeLiturgicalSeasonService().getCurrentSeason();

    final r = await rebuild.call(
      settings,
      isEasterSeason: season == LiturgicalSeason.easter,
      showImmediate: false,
    );
    expect(r.shortIntervalReliabilityNotGuaranteed, isFalse);
  });

  test('short interval with exact denied reports notGuaranteed true', () async {
    final scheduler = InMemoryNotificationSchedulerRepository()
      ..shortIntervalReliabilityOverrideForTest =
          ShortIntervalReliability.exactAlarmsUnavailable;
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

    final settings = Settings.defaults.copyWith(
      notificationsEnabled: true,
      intervalMinutes: 5,
    );
    final season = await _FakeLiturgicalSeasonService().getCurrentSeason();

    final r = await rebuild.call(
      settings,
      isEasterSeason: season == LiturgicalSeason.easter,
      showImmediate: false,
    );
    expect(r.shortIntervalReliabilityNotGuaranteed, isTrue);

    final quoteEvents = scheduler.events
        .where((event) => event.type == ReminderEventType.quoteInterval)
        .toList();
    expect(
      quoteEvents,
      hasLength(1),
      reason:
          'When exact alarms are unavailable, keep only the latest upcoming quote to avoid Android burst delivery.',
    );
    expect(quoteEvents.single.scheduledId, 9000);
  });

  test('notifications disabled yields notGuaranteed false even if exact denied', () async {
    final scheduler = InMemoryNotificationSchedulerRepository()
      ..shortIntervalReliabilityOverrideForTest =
          ShortIntervalReliability.exactAlarmsUnavailable;
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

    final settings = Settings.defaults.copyWith(
      notificationsEnabled: false,
      intervalMinutes: 5,
    );
    final season = await _FakeLiturgicalSeasonService().getCurrentSeason();

    final r = await rebuild.call(
      settings,
      isEasterSeason: season == LiturgicalSeason.easter,
      showImmediate: false,
    );
    expect(r.shortIntervalReliabilityNotGuaranteed, isFalse);
  });
}
