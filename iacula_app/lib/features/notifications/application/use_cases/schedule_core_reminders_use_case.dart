import 'dart:math' show max, min;

import 'package:flutter/foundation.dart';

import '../../../../core/utils/datetime_slot.dart';
import '../../../home_widget/home_widget_service.dart';
import '../../../liturgical/domain/easter_calculator.dart';
import '../../../prayers/domain/services/prayer_scheduler.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../../settings/domain/jaculatoria_cadence_preset.dart';
import '../../domain/entities/last_delivered_card.dart';
import '../../domain/entities/notification_history_entry.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';
import '../../domain/repositories/notification_history_repository.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';
import '../../domain/services/active_window.dart';
import '../../domain/services/quote_slot_planner.dart';

typedef QuoteFetcher =
    Future<Quote> Function({required String language, required DateTime now});

final class ScheduleCoreRemindersUseCase {
  /// First id of the single contiguous quote one-shot block. The pre-rolled
  /// multi-day queue occupies [quoteScheduleIdBase] .. +[maxQueuedQuoteReminders).
  static const int quoteScheduleIdBase = 9000;
  static const int maxQueuedQuoteReminders = 64;

  /// Closed-app coverage guarantee: pre-roll quotes for this many days ahead so
  /// a never-opened app keeps delivering for at least a week. The per-day quote
  /// count is the shared quote budget divided across these days (see below).
  static const int runwayDays = 7;

  /// Quotes never drop to zero even under heavy alarm load: always schedule at
  /// least this many per day so the app's core feature keeps a pulse.
  static const int minQuotesPerDay = 1;

  /// Pending notifications reserved for non-quote consumers when no live count
  /// is supplied: 1 Angelus + ~9 headroom for custom phrases / prayer
  /// intentions. (RebuildNotificationsUseCase passes the real pending count.)
  static const int kReservedNonQuoteBudget = 10;

  /// Whether [id] belongs to the rotating quote one-shot block.
  static bool isQuoteReminderId(int id) =>
      id >= quoteScheduleIdBase &&
      id < quoteScheduleIdBase + maxQueuedQuoteReminders;

  const ScheduleCoreRemindersUseCase(
    this._scheduler, {
    required QuoteFetcher quoteFetcher,
    required NotificationHistoryRepository notificationHistoryRepository,
    required LastDeliveredCardRepository lastDeliveredCardRepository,
  }) : _quoteFetcher = quoteFetcher,
       _notificationHistoryRepository = notificationHistoryRepository,
       _lastDeliveredCardRepository = lastDeliveredCardRepository;

  final NotificationSchedulerRepository _scheduler;
  final QuoteFetcher _quoteFetcher;
  final NotificationHistoryRepository _notificationHistoryRepository;
  final LastDeliveredCardRepository _lastDeliveredCardRepository;

  Future<void> call(
    Settings settings, {
    DateTime? now,
    bool isEasterSeason = false,
    Quote? immediateQuote,
    bool showImmediate = true,
    int? reservedNonQuoteBudget,
  }) async {
    final reservedForOthers = reservedNonQuoteBudget ?? kReservedNonQuoteBudget;
    final current = now ?? DateTime.now();

    debugPrint(
      '[ScheduleCoreRemindersUseCase] scheduling at ${current.toIso8601String()} '
      'interval=${settings.intervalMinutes}m showImmediate=$showImmediate',
    );

    // Tracks quote texts already used in this scheduling pass so adjacent slots
    // don't deliver the same quote twice within a short window. Bounded to the
    // most recent slots so a small pool still cycles eventually.
    final recentQuoteTexts = <String>[];
    const recentLookbackSize = 6;

    Future<Quote> fetchNonRepeatingQuote({
      required String language,
      required DateTime slot,
    }) async {
      const maxRetries = 3;
      Quote candidate = await _quoteFetcher(language: language, now: slot);
      var attempts = 0;
      while (recentQuoteTexts.contains(candidate.text) &&
          attempts < maxRetries) {
        candidate = await _quoteFetcher(language: language, now: slot);
        attempts++;
      }
      recentQuoteTexts.add(candidate.text);
      if (recentQuoteTexts.length > recentLookbackSize) {
        recentQuoteTexts.removeAt(0);
      }
      return candidate;
    }

    // Show an immediate notification if requested
    if (showImmediate) {
      final quote = immediateQuote ??
          await fetchNonRepeatingQuote(
            language: settings.language,
            slot: current,
          );
      if (immediateQuote != null) {
        recentQuoteTexts.add(immediateQuote.text);
      }

      const immediateId = quoteScheduleIdBase - 1;
      await _scheduler.showNow(
        immediateId,
        _buildQuoteEvent(id: immediateId, fireAt: current, quote: quote),
      );

      final deliveredCard = LastDeliveredCard.fromQuote(
        quote,
        deliveredAt: current,
      );
      await _lastDeliveredCardRepository.save(deliveredCard);
      await HomeWidgetService.instance.updateWidget(
        deliveredCard,
        intervalMinutes: settings.intervalMinutes,
      );
      await _notificationHistoryRepository.add(
        NotificationHistoryEntry.fromQuote(quote, deliveredAt: current),
      );
    }

    final preset =
        JaculatoriaCadencePreset.fromIntervalMinutes(settings.intervalMinutes);
    final effectiveWindow = ActiveWindow.fromQuietHours(
      quietStart: settings.quietHoursStart,
      quietEnd: settings.quietHoursEnd,
    );

    // ---- Pre-rolled multi-day quote queue ----
    // One layer of plain one-shots covering the next [runwayDays] days (today
    // first), each pre-assigned a distinct shuffle-bag draw at schedule time so
    // the OS fires theme-correct, rotating quotes even while the app stays closed
    // for days. Replaces the old Layer A (today-only, needed the app open) +
    // Layer B (weekly grid that skipped today). Every day, including today, is
    // now covered identically whether or not the app is opened.

    // Quote budget = the 64 cap minus everything reserved for higher-priority
    // (sacred) consumers and this pass's own Angelus + immediate slots. Quotes
    // absorb whatever is left; under heavy alarm load this shrinks toward the
    // per-day floor rather than pushing past the cap.
    final angelusOwnSlot = settings.angelusEnabled ? 1 : 0;
    final immediateOwnSlot = showImmediate ? 1 : 0;
    final quoteSlotBudget = max(
      0,
      maxQueuedQuoteReminders -
          reservedForOthers -
          angelusOwnSlot -
          immediateOwnSlot,
    );

    // Per-day count honors the user's cadence but is capped so the budget
    // stretches across the whole runway; never below the floor unless the budget
    // is fully exhausted.
    final naturalSlotsPerDay = effectiveWindow.slotCount(
      cadenceMinutes: preset.todayCadenceMinutes,
    );
    final runwayCap = quoteSlotBudget ~/ runwayDays;
    final slotsPerDay = quoteSlotBudget <= 0
        ? 0
        : max(minQuotesPerDay, min(naturalSlotsPerDay, runwayCap));

    final plannedSlots = QuoteSlotPlanner.multiDaySlots(
      now: current,
      window: effectiveWindow,
      cadenceMinutes: preset.todayCadenceMinutes,
      slotsPerDay: slotsPerDay,
      days: runwayDays,
    ).map((slot) => slot.flooredToMinute()).toList();

    // Cap to the absolute budget (defensive: per-day math already keeps us under).
    final scheduledSlots = plannedSlots.take(quoteSlotBudget).toList();

    // Reuse/prune horizon = the full runway from `current`, independent of where
    // this pass's slots happen to end. Anchoring to the runway (not the last
    // scheduled slot) means a pass that shrinks the queue — e.g. the window
    // narrowed — still reaches and prunes stale rows left by an earlier, wider
    // pass that lay beyond the new last slot.
    final horizonEnd = current.add(const Duration(days: runwayDays + 1));

    // Assignment cache: a slot (identified by its floored fire DateTime) is
    // assigned a quote once and persisted as a future history row. While that
    // fire time is still ahead, a later rebuild reuses the cached assignment
    // instead of drawing again — so the shuffle bag advances ~once per delivered
    // quote, not once per scheduled slot per reopen.
    final existingAssignments = await _notificationHistoryRepository.listBetween(
      current,
      horizonEnd,
    );
    final assignmentByFireTime = {
      for (final entry in existingAssignments)
        entry.deliveredAt.toIso8601String(): entry,
    };
    final keepFireTimes = {
      for (final slot in scheduledSlots) slot.toIso8601String(),
    };

    for (var slotIndex = 0; slotIndex < scheduledSlots.length; slotIndex++) {
      final fireAt = scheduledSlots[slotIndex];
      final cached = assignmentByFireTime[fireAt.toIso8601String()];

      final Quote quote;
      if (cached != null) {
        // Slot already assigned and still in the future: reuse, no bag draw.
        quote = cached.toQuote(dayOfWeek: fireAt.weekday);
        recentQuoteTexts.add(quote.text);
        if (recentQuoteTexts.length > recentLookbackSize) {
          recentQuoteTexts.removeAt(0);
        }
      } else {
        // New (or newly elapsed) slot: draw once (keyed on the slot's DATE so it
        // picks that weekday's theme and advances the bag) and persist it.
        quote = await fetchNonRepeatingQuote(
          language: settings.language,
          slot: fireAt,
        );
        await _notificationHistoryRepository.add(
          NotificationHistoryEntry.fromQuote(quote, deliveredAt: fireAt),
        );
      }

      final scheduledId = quoteScheduleIdBase + slotIndex;
      await _scheduler.scheduleWithId(
        scheduledId,
        _buildQuoteEvent(id: scheduledId, fireAt: fireAt, quote: quote),
      );
    }

    // Prune stale future assignment rows across the whole queue (e.g. window or
    // cadence changed so previously scheduled fire times no longer exist).
    // Strict lower bound means real past deliveries (and the just-fired row)
    // survive.
    await _notificationHistoryRepository.clearBetweenExcept(
      current,
      horizonEnd,
      keepFireTimes,
    );

    debugPrint(
      '[ScheduleCoreRemindersUseCase] registered pre-rolled queue: '
      '${scheduledSlots.length} one-shots over $runwayDays days '
      '($slotsPerDay/day cap, cadence=${preset.todayCadenceMinutes}m, '
      'budget=$quoteSlotBudget)',
    );

    // Schedule the daily noon repeat (Angelus / Regina Caeli) for the season
    // that is true RIGHT NOW — never a future season. It must never show Regina
    // Caeli before Easter begins, nor Angelus before Easter ends. The widened
    // season noon bridge carries the correct prayer across each boundary while
    // the app is closed; this repeat only ever reflects the present season.
    if (settings.angelusEnabled) {
      final noon = PrayerScheduler.calculateNextNoon(current).nextTriggerTime;
      final repeatIsEasterSeason =
          isEasterSeason || _isDateWithinEasterSeason(current);
      final noonTitle = repeatIsEasterSeason ? 'Regina Caeli' : 'Angelus';
      final noonBody = repeatIsEasterSeason
          ? 'Hora de rezar a Regina Caeli.'
          : 'Hora de rezar o Angelus.';
      // Angelus respects the single active window (no separate quiet-hours
      // concept): if noon falls outside the window the user has chosen to be
      // silent then, so the daily repeat is not scheduled.
      final noonInsideWindow = effectiveWindow.allows(noon);
      if (noonInsideWindow) {
        final prayerSlug = repeatIsEasterSeason ? 'regina-coeli' : 'angelus';
        await _scheduler.schedule(
          ReminderEvent(
            type: ReminderEventType.angelusNoon,
            title: noonTitle,
            body: noonBody,
            scheduledAt: noon,
            withVibration: true,
            isAlarm: true,
            repeatDaily: true,
            routeTarget: NotificationRouteTarget.prayer,
            prayerSlug: prayerSlug,
          ),
        );
      }
    }
  }

  bool _isDateWithinEasterSeason(DateTime date) =>
      EasterCalculator.isWithinEasterSeason(date);

  /// Builds a quote-interval [ReminderEvent] from a fetched quote. Shared by the
  /// immediate notification and every pre-rolled queue slot so the shared fields
  /// live in one place. Quote events are always plain one-shots (the OS fires
  /// the pre-assigned quote at its time); there is no repeating quote anymore.
  ReminderEvent _buildQuoteEvent({
    required int id,
    required DateTime fireAt,
    required Quote quote,
  }) {
    return ReminderEvent(
      type: ReminderEventType.quoteInterval,
      title: 'Iacula',
      body: quote.text,
      scheduledAt: fireAt,
      withVibration: true,
      isAlarm: false,
      routeTarget: NotificationRouteTarget.home,
      scheduledId: id,
      quoteTheme: quote.theme,
      quoteSeason: quote.season.name,
      quoteFeastName: quote.feastName,
      quoteImagePath: quote.imagePath,
    );
  }
}
