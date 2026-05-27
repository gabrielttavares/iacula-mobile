import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import '../../../home_widget/home_widget_service.dart';
import '../../../prayer_intentions/application/use_cases/schedule_intention_notifications_use_case.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';
import '../../domain/repositories/notification_history_repository.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';
import 'schedule_core_reminders_use_case.dart';
import 'schedule_liturgy_reminders_use_case.dart';
import 'schedule_season_transitions_use_case.dart';

final class RebuildNotificationsUseCase {
  RebuildNotificationsUseCase({
    required NotificationSchedulerRepository scheduler,
    required NotificationHistoryRepository notificationHistoryRepository,
    required LastDeliveredCardRepository lastDeliveredCardRepository,
    required ScheduleLiturgyRemindersUseCase scheduleLiturgyReminders,
    required SchedulePhraseNotificationsUseCase schedulePhraseNotifications,
    required ScheduleIntentionNotificationsUseCase scheduleIntentionNotifications,
    required QuoteFetcher quoteFetcher,
  }) : _scheduler = scheduler,
       _notificationHistoryRepository = notificationHistoryRepository,
       _lastDeliveredCardRepository = lastDeliveredCardRepository,
       _scheduleLiturgyReminders = scheduleLiturgyReminders,
       _schedulePhraseNotifications = schedulePhraseNotifications,
       _scheduleIntentionNotifications = scheduleIntentionNotifications,
       _quoteFetcher = quoteFetcher;

  final NotificationSchedulerRepository _scheduler;
  final NotificationHistoryRepository _notificationHistoryRepository;
  final LastDeliveredCardRepository _lastDeliveredCardRepository;
  final ScheduleLiturgyRemindersUseCase _scheduleLiturgyReminders;
  final SchedulePhraseNotificationsUseCase _schedulePhraseNotifications;
  final ScheduleIntentionNotificationsUseCase _scheduleIntentionNotifications;
  final QuoteFetcher _quoteFetcher;

  Future<void> call(
    Settings settings, {
    required bool isEasterSeason,
    bool showImmediate = false,
    Quote? immediateQuote,
    DateTime? now,
  }) async {
    debugPrint(
      '[RebuildNotificationsUseCase] start notificationsEnabled=${settings.notificationsEnabled} '
      'interval=${settings.intervalMinutes} showImmediate=$showImmediate '
      'isEasterSeason=$isEasterSeason',
    );

    await HomeWidgetService.instance.saveIntervalMinutes(
      settings.intervalMinutes,
    );

    if (!settings.notificationsEnabled) {
      await _scheduler.cancelAll();
      debugPrint(
        '[RebuildNotificationsUseCase] notifications disabled; canceled all.',
      );
      return;
    }

    // Cancel only quote notification IDs (8999-9063) instead of wiping everything.
    // Alarm-type notifications (Angelus, liturgy hours) reschedule by fixed ID,
    // so re-scheduling naturally replaces them without needing a cancel step.
    for (var id = ScheduleCoreRemindersUseCase.quoteScheduleIdBase - 1;
        id < ScheduleCoreRemindersUseCase.quoteScheduleIdBase +
            ScheduleCoreRemindersUseCase.maxQueuedQuoteReminders;
        id++) {
      await _scheduler.cancelById(id);
    }

    await ScheduleCoreRemindersUseCase(
      _scheduler,
      quoteFetcher: _quoteFetcher,
      notificationHistoryRepository: _notificationHistoryRepository,
      lastDeliveredCardRepository: _lastDeliveredCardRepository,
    ).call(
      settings,
      now: now,
      isEasterSeason: isEasterSeason,
      immediateQuote: immediateQuote,
      showImmediate: showImmediate,
    );

    await Future.wait([
      _schedulePhraseNotifications.call(settings: settings),
      _scheduleLiturgyReminders.call(settings, now: now),
      _scheduleIntentionNotifications.call(),
      ScheduleSeasonTransitionsUseCase(_scheduler).call(now: now),
    ]);

    final pendingAfter = await _scheduler.pendingNotificationIds();
    debugPrint(
      '[RebuildNotificationsUseCase] complete; pending IDs total=${pendingAfter.length}.',
    );
  }
}
