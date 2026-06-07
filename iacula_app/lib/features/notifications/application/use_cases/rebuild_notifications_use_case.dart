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
import '../../domain/services/active_window.dart';
import '../../domain/services/notification_budget.dart';
import '../../domain/services/notification_capacity_policy.dart';
import 'schedule_core_reminders_use_case.dart';
import 'schedule_season_transitions_use_case.dart';

final class RebuildNotificationsUseCase {
  RebuildNotificationsUseCase({
    required NotificationSchedulerRepository scheduler,
    required NotificationHistoryRepository notificationHistoryRepository,
    required LastDeliveredCardRepository lastDeliveredCardRepository,
    required SchedulePhraseNotificationsUseCase schedulePhraseNotifications,
    required ScheduleIntentionNotificationsUseCase scheduleIntentionNotifications,
    required QuoteFetcher quoteFetcher,
    NotificationCapacityPolicy capacityPolicy = NotificationCapacityPolicy.ios,
  }) : _scheduler = scheduler,
       _notificationHistoryRepository = notificationHistoryRepository,
       _lastDeliveredCardRepository = lastDeliveredCardRepository,
       _schedulePhraseNotifications = schedulePhraseNotifications,
       _scheduleIntentionNotifications = scheduleIntentionNotifications,
       _quoteFetcher = quoteFetcher,
       _capacityPolicy = capacityPolicy;

  final NotificationSchedulerRepository _scheduler;
  final NotificationHistoryRepository _notificationHistoryRepository;
  final LastDeliveredCardRepository _lastDeliveredCardRepository;
  final SchedulePhraseNotificationsUseCase _schedulePhraseNotifications;
  final ScheduleIntentionNotificationsUseCase _scheduleIntentionNotifications;
  final QuoteFetcher _quoteFetcher;
  final NotificationCapacityPolicy _capacityPolicy;

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

    // Cancel only quote notification IDs instead of wiping everything, and only
    // the ones actually pending — the quote id block is large (sized for
    // Android's uncapped queue) so iterating the whole range would be wasteful.
    // This spans the immediate id (8999) and the contiguous pre-rolled quote
    // block, so reopening replaces quotes rather than accumulating. Alarm-type
    // notifications (Angelus, liturgy hours) reschedule by fixed ID, so
    // re-scheduling naturally replaces them without needing a cancel step.
    const immediateQuoteId = ScheduleCoreRemindersUseCase.quoteScheduleIdBase - 1;
    final pendingQuoteIds = (await _scheduler.pendingNotificationIds()).where(
      (id) => id == immediateQuoteId ||
          ScheduleCoreRemindersUseCase.isQuoteReminderId(id),
    );
    for (final id in pendingQuoteIds) {
      await _scheduler.cancelById(id);
    }

    // Priority-ordered, single shared budget so the app never silently exceeds
    // the platform's pending cap (on iOS, excess notifications are dropped at
    // random; Android has no real cap, so this ceiling is high). Sacred,
    // user-set reminders are scheduled FIRST and win their slots; substitutable
    // quotes are scheduled LAST and absorb any squeeze. The order here is the
    // priority order: season transitions (liturgical correctness) → liturgy
    // hours → prayer intentions (promises) → custom phrases → quotes.
    final budget =
        NotificationBudget(capacity: _capacityPolicy.pendingTotalCapacity);

    // A time is "quiet" (no notification) when it falls OUTSIDE the active
    // window — the single source of truth shared with the quote scheduler, so
    // the season-transition noon bridge honors the same hours.
    final effectiveWindow = ActiveWindow.fromQuietHours(
      quietStart: settings.quietHoursStart,
      quietEnd: settings.quietHoursEnd,
    );
    bool isQuietAt(DateTime time) => !effectiveWindow.allows(time);

    // Tiers that schedule by fixed id (season transitions + bridge) run first
    // and own their slots. The quote pass later also schedules the Angelus daily
    // repeat and the immediate notification, so reserve those up front too —
    // otherwise intentions/phrases could fill the slots they need.
    await ScheduleSeasonTransitionsUseCase(_scheduler).call(
      now: now,
      angelusEnabled: settings.angelusEnabled,
      isQuietAt: isQuietAt,
    );
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
            .clamp(0, _capacityPolicy.pendingTotalCapacity);

    await ScheduleCoreRemindersUseCase(
      _scheduler,
      quoteFetcher: _quoteFetcher,
      notificationHistoryRepository: _notificationHistoryRepository,
      lastDeliveredCardRepository: _lastDeliveredCardRepository,
      capacityPolicy: _capacityPolicy,
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
