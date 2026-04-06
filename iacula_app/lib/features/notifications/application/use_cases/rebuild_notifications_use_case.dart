import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import '../../../home_widget/home_widget_service.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../domain/entities/notification_rebuild_result.dart';
import '../../domain/entities/short_interval_reliability.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';
import '../../domain/repositories/notification_history_repository.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';
import 'schedule_core_reminders_use_case.dart';
import 'schedule_liturgy_reminders_use_case.dart';

typedef QuoteBatchFetcherForSettings =
    QuoteBatchFetcher? Function(Settings settings);

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

  Future<void>? _queueTail;

  Future<NotificationRebuildResult> call(
    Settings settings, {
    required bool isEasterSeason,
    bool showImmediate = false,
    Quote? immediateQuote,
    DateTime? now,
  }) async {
    Future<NotificationRebuildResult> run() async {
      final scheduler = _scheduler;
      debugPrint(
        '[RebuildNotificationsUseCase] start notificationsEnabled=${settings.notificationsEnabled} '
        'interval=${settings.intervalMinutes} showImmediate=$showImmediate '
        'isEasterSeason=$isEasterSeason',
      );
      await HomeWidgetService.instance.saveIntervalMinutes(
        settings.intervalMinutes,
      );
      scheduler.resetScheduleTelemetry();
      final reliability = await scheduler.evaluateShortIntervalReliability(
        notificationsEnabled: settings.notificationsEnabled,
        intervalMinutes: settings.intervalMinutes,
      );
      final latestOnlyQueuedQuote =
          reliability == ShortIntervalReliability.exactAlarmsUnavailable;
      debugPrint(
        '[RebuildNotificationsUseCase] short-interval reliability guaranteed=${reliability.guaranteed}',
      );
      await scheduler.cancelAll();
      debugPrint(
        '[RebuildNotificationsUseCase] cancelAll completed; proceeding to schedule reminders.',
      );
      if (!settings.notificationsEnabled) {
        debugPrint(
          '[RebuildNotificationsUseCase] finished early because notifications are disabled.',
        );
        return NotificationRebuildResult(
          shortIntervalReliabilityNotGuaranteed: false,
        );
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
        latestOnlyQueuedQuote: latestOnlyQueuedQuote,
      );
      await Future.wait([
        _schedulePhraseNotifications.call(settings: settings),
        _scheduleLiturgyReminders.call(settings),
      ]);
      final pendingAfter = await scheduler.pendingNotificationIds();
      debugPrint(
        '[RebuildNotificationsUseCase] complete; pending IDs total=${pendingAfter.length}.',
      );
      return NotificationRebuildResult(
        shortIntervalReliabilityNotGuaranteed: !reliability.guaranteed,
      );
    }

    final previous = _queueTail ?? Future<void>.value();
    final resultFuture = previous.then((_) => run());
    _queueTail = resultFuture.then(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return resultFuture;
  }
}
