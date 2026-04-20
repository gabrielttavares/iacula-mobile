import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/notifications/application/use_cases/rebuild_notifications_use_case.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/short_interval_reliability.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_scheduler_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/schedule_intention_notifications_use_case.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote_indices.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_indices_repository.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class _FakeNotificationSchedulerRepository
    implements NotificationSchedulerRepository {
  final _controller = StreamController<NotificationActionEvent>.broadcast();

  int cancelAllCalls = 0;
  final List<ReminderEvent> scheduled = [];

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled.clear();
  }

  @override
  Future<void> cancelByType(ReminderEventType type) async {
    scheduled.removeWhere((event) => event.type == type);
  }

  @override
  Future<void> schedule(ReminderEvent event) async {
    scheduled.removeWhere((e) => e.type == event.type);
    scheduled.add(event);
  }

  @override
  Future<void> scheduleWithId(int id, ReminderEvent event) async {
    scheduled.add(event);
  }

  @override
  Future<void> showNow(int id, ReminderEvent event) async {
    scheduled.add(event.copyWith(scheduledId: id));
  }

  @override
  Future<void> cancelById(int id) async {
    scheduled.removeWhere((e) => e.scheduledId == id);
  }

  @override
  Future<bool?> canScheduleExactNotifications() async => true;

  @override
  Future<bool?> requestExactAlarmsPermission() async => true;

  @override
  Future<List<int>> pendingNotificationIds() async {
    return scheduled
        .where((e) => e.scheduledId != null)
        .map((e) => e.scheduledId!)
        .toList();
  }

  @override
  Future<NotificationActionEvent?> getLaunchNotificationAction() async => null;

  @override
  void resetScheduleTelemetry() {}

  @override
  Future<ShortIntervalReliability> evaluateShortIntervalReliability({
    required bool notificationsEnabled,
    required int intervalMinutes,
  }) async {
    return ShortIntervalReliability.ok;
  }
}

final class _FakeQuoteContentRepository implements QuoteContentRepository {
  @override
  Future<String?> getFeastImagePath(String feastSlug) async => null;

  @override
  Future<List<String>> listDayImages({
    required int dayOfWeek,
    required LiturgicalSeason season,
  }) async {
    return ['assets/seed/images/ordinary/1/E.jpg'];
  }

  @override
  Future<Map<String, DayQuotes>> loadQuotes({
    required String language,
    required LiturgicalSeason season,
  }) async {
    return {
      '1': const DayQuotes(
        day: 'Domingo',
        theme: 'Tema',
        quotes: ['Jaculatoria de teste'],
      ),
    };
  }

  @override
  Future<List<String>> loadFeastQuotes(String feastSlug) async =>
      const <String>[];
}

final class _FakeQuoteIndicesRepository implements QuoteIndicesRepository {
  QuoteIndices _indices = QuoteIndices.empty(1);

  @override
  Future<QuoteIndices> load({required int dayOfWeek}) async => _indices;

  @override
  Future<void> save(QuoteIndices indices) async {
    _indices = indices;
  }
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

final class _InMemoryLastDeliveredCardRepository
    implements LastDeliveredCardRepository {
  LastDeliveredCard? value;

  @override
  Future<LastDeliveredCard?> load() async => value;

  @override
  Future<void> save(LastDeliveredCard card) async {
    value = card;
  }
}

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

final class _EmptySpiritualEntryRepository implements SpiritualEntryRepository {
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

void main() {
  test('saving settings cancels and rebuilds reminders', () async {
    final settings = Settings.defaults.copyWith(laudesEnabled: true);
    final schedulerRepo = _FakeNotificationSchedulerRepository();

    final season = await _FakeLiturgicalSeasonService().getCurrentSeason();
    await RebuildNotificationsUseCase(
      scheduler: schedulerRepo,
      notificationHistoryRepository: InMemoryNotificationHistoryRepository(),
      lastDeliveredCardRepository: _InMemoryLastDeliveredCardRepository(),
      scheduleLiturgyReminders: ScheduleLiturgyRemindersUseCase(schedulerRepo),
      schedulePhraseNotifications: SchedulePhraseNotificationsUseCase(
        schedulerRepo,
        _EmptyCustomPhraseRepository(),
      ),
      scheduleIntentionNotifications: ScheduleIntentionNotificationsUseCase(
        schedulerRepo,
        _EmptySpiritualEntryRepository(),
      ),
      quoteFetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'Jaculatoria de teste',
          dayOfWeek: 1,
          theme: 'Tema',
          season: LiturgicalSeason.ordinary,
        );
      },
      batchFetcherForSettings: (_) => null,
    ).call(
      settings,
      isEasterSeason: season == LiturgicalSeason.easter,
      showImmediate: false,
    );

    expect(schedulerRepo.cancelAllCalls, 1);
    expect(
      schedulerRepo.scheduled.any(
        (e) => e.type == ReminderEventType.quoteInterval,
      ),
      isTrue,
    );
    expect(
      schedulerRepo.scheduled.any(
        (e) => e.type == ReminderEventType.angelusNoon,
      ),
      isTrue,
    );
    expect(
      schedulerRepo.scheduled.any((e) => e.type == ReminderEventType.laudes),
      isTrue,
    );
  });
}
