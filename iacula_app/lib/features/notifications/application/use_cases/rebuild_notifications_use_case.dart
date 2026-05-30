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

    // Angelus daily repeat (id 200) is scheduled inside the quote pass below but
    // is sacred, so reserve its slot up front.
    if (settings.angelusEnabled) budget.reserve(1);

    bool isQuietAt(DateTime time) =>
        settings.quietHoursEnabled &&
        QuietHoursChecker.isDuringQuietHours(
          time,
          settings.quietHoursStart,
          settings.quietHoursEnd,
        );

    await ScheduleSeasonTransitionsUseCase(_scheduler).call(
      now: now,
      angelusEnabled: settings.angelusEnabled,
      isQuietAt: isQuietAt,
    );
    await _scheduleLiturgyReminders.call(settings, now: now);
    // Re-sync the budget to whatever those fixed-id tiers actually scheduled.
    budget.reserve(
      (await _scheduler.pendingNotificationIds()).length - budget.consumed,
    );

    await _scheduleIntentionNotifications.call(budget: budget);
    await _schedulePhraseNotifications.call(settings: settings, budget: budget);

    // Quotes fill only what remains. The quote pass also schedules the Angelus
    // daily repeat (≤1) and the immediate notification (≤1) on top of its grid
    // + today slots, so reserve those alongside what the sacred tiers already
    // took. quoteSlotBudget inside the quote pass = 64 − reservedForOthers, and
    // that budget must leave room for Angelus + immediate too.
    final takenBySacredTiers =
        (await _scheduler.pendingNotificationIds()).length;
    final angelusSlot = settings.angelusEnabled ? 1 : 0;
    final immediateSlot = showImmediate ? 1 : 0;
    final reservedForOthers =
        (takenBySacredTiers + angelusSlot + immediateSlot)
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
