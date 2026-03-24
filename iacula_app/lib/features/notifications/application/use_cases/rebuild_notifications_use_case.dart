import 'dart:async';

import '../../../custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';
import '../../domain/repositories/notification_history_repository.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';
import '../../infrastructure/repositories/local_notification_scheduler_repository.dart';
import 'schedule_core_reminders_use_case.dart';
import 'schedule_liturgy_reminders_use_case.dart';

typedef QuoteBatchFetcherForSettings = QuoteBatchFetcher? Function(
  Settings settings,
);

final class RebuildNotificationsUseCase {
  RebuildNotificationsUseCase({
    required NotificationSchedulerRepository scheduler,
    required NotificationHistoryRepository notificationHistoryRepository,
    required LastDeliveredCardRepository lastDeliveredCardRepository,
    required ScheduleLiturgyRemindersUseCase scheduleLiturgyReminders,
    required SchedulePhraseNotificationsUseCase schedulePhraseNotifications,
    required QuoteFetcher quoteFetcher,
    required QuoteBatchFetcherForSettings batchFetcherForSettings,
  }) : _scheduler = scheduler,
       _notificationHistoryRepository = notificationHistoryRepository,
       _lastDeliveredCardRepository = lastDeliveredCardRepository,
       _scheduleLiturgyReminders = scheduleLiturgyReminders,
       _schedulePhraseNotifications = schedulePhraseNotifications,
       _quoteFetcher = quoteFetcher,
       _batchFetcherForSettings = batchFetcherForSettings;

  final NotificationSchedulerRepository _scheduler;
  final NotificationHistoryRepository _notificationHistoryRepository;
  final LastDeliveredCardRepository _lastDeliveredCardRepository;
  final ScheduleLiturgyRemindersUseCase _scheduleLiturgyReminders;
  final SchedulePhraseNotificationsUseCase _schedulePhraseNotifications;
  final QuoteFetcher _quoteFetcher;
  final QuoteBatchFetcherForSettings _batchFetcherForSettings;

  Future<void>? _chain;

  Future<void> call(
    Settings settings, {
    required bool isEasterSeason,
    bool showImmediate = false,
    Quote? immediateQuote,
    DateTime? now,
  }) async {
    Future<void> run() async {
      final scheduler = _scheduler;
      scheduler.resetScheduleTelemetry();
      if (scheduler is LocalNotificationSchedulerRepository) {
        await scheduler.ensureExactAlarmsForShortIntervals(
          notificationsEnabled: settings.notificationsEnabled,
          intervalMinutes: settings.intervalMinutes,
        );
      }
      await scheduler.cancelAll();
      if (!settings.notificationsEnabled) {
        return;
      }
      await ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher: _quoteFetcher,
        notificationHistoryRepository: _notificationHistoryRepository,
        lastDeliveredCardRepository: _lastDeliveredCardRepository,
        batchFetcher: _batchFetcherForSettings(settings),
      ).call(
        settings,
        now: now,
        isEasterSeason: isEasterSeason,
        immediateQuote: immediateQuote,
        showImmediate: showImmediate,
      );
      await Future.wait([
        _schedulePhraseNotifications.call(),
        _scheduleLiturgyReminders.call(settings),
      ]);
    }

    _chain = (_chain ?? Future.value()).then((_) => run());
    return _chain!;
  }
}
