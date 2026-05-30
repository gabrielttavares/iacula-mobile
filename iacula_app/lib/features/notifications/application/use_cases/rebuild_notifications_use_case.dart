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
import '../../domain/services/notification_budget.dart';
import '../../domain/services/quiet_hours_checker.dart';
import 'schedule_core_reminders_use_case.dart';
import 'schedule_liturgy_reminders_use_case.dart';
import 'schedule_season_transitions_use_case.dart';

final class RebuildNotificationsUseCase {
  /// iOS holds at most 64 pending local notifications app-wide; beyond this the
  /// OS silently drops the excess. Every feature draws from this one budget.
  static const int maxPendingNotifications = 64;

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

    // Cancel only quote notification IDs instead of wiping everything. This must
    // span the immediate id (8999), the weekly grid floor (9000+), AND the dense
    // today layer (9100+), so reopening replaces quotes rather than accumulating.
    // Alarm-type notifications (Angelus, liturgy hours) reschedule by fixed ID,
    // so re-scheduling naturally replaces them without needing a cancel step.
    for (var id = ScheduleCoreRemindersUseCase.quoteScheduleIdBase - 1;
        id < ScheduleCoreRemindersUseCase.todayLayerIdBase +
            ScheduleCoreRemindersUseCase.maxTodayLayerSlots;
        id++) {
      await _scheduler.cancelById(id);
    }

    // Priority-ordered, single shared budget so the app never silently exceeds
    // the iOS 64-pending cap (where excess notifications are dropped at random).
    // Sacred, user-set reminders are scheduled FIRST and win their slots;
    // substitutable quotes are scheduled LAST and absorb any squeeze. The order
    // here is the priority order: season transitions (liturgical correctness) →
    // liturgy hours → prayer intentions (promises) → custom phrases → quotes.
    final budget = NotificationBudget(capacity: maxPendingNotifications);

    bool isQuietAt(DateTime time) =>
        settings.quietHoursEnabled &&
        QuietHoursChecker.isDuringQuietHours(
          time,
          settings.quietHoursStart,
          settings.quietHoursEnd,
        );

    // Tiers that schedule by fixed id (season transitions + bridge, liturgy)
    // run first and own their slots. The quote pass later also schedules the
    // Angelus daily repeat and the immediate notification, so reserve those up
    // front too — otherwise intentions/phrases could fill the slots they need.
    await ScheduleSeasonTransitionsUseCase(_scheduler).call(
      now: now,
      angelusEnabled: settings.angelusEnabled,
      isQuietAt: isQuietAt,
    );
    await _scheduleLiturgyReminders.call(settings, now: now);
    final fixedIdTierCount = (await _scheduler.pendingNotificationIds()).length;
    final quotePassSelfSlots =
        (settings.angelusEnabled ? 1 : 0) + (showImmediate ? 1 : 0);
    budget.reserve(fixedIdTierCount + quotePassSelfSlots);

    await _scheduleIntentionNotifications.call(budget: budget);
    await _schedulePhraseNotifications.call(settings: settings, budget: budget);

    // Quotes fill only what remains. The reserve = everything already pending
    // (sacred fixed-id tiers + intentions + phrases). The quote pass internally
    // also reserves for its own Angelus + immediate, so the grand total can
    // never exceed the 64 cap.
    final reservedForOthers =
        (await _scheduler.pendingNotificationIds()).length
            .clamp(0, maxPendingNotifications);

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
      reservedNonQuoteBudget: reservedForOthers,
    );

    final pendingAfter = await _scheduler.pendingNotificationIds();
    debugPrint(
      '[RebuildNotificationsUseCase] complete; pending IDs total=${pendingAfter.length}.',
    );
  }
}
