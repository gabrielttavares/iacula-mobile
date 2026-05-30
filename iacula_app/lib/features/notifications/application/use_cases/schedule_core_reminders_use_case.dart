import 'dart:math' show max, min;

import 'package:flutter/foundation.dart';

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
import '../../domain/services/quiet_hours_checker.dart';
import '../../domain/services/quote_slot_planner.dart';

typedef QuoteFetcher =
    Future<Quote> Function({required String language, required DateTime now});

final class ScheduleCoreRemindersUseCase {
  static const int quoteScheduleIdBase = 9000;
  static const int maxQueuedQuoteReminders = 64;

  /// Reserved id block for the dense "today" one-shot layer (Layer A), distinct
  /// from the weekly grid floor (9000-9034), Angelus (200), immediate (8999).
  /// 28 covers a full-window 30-min day (27 slots) without the id ceiling
  /// clipping it; the binding limit is the reserved-budget guard below.
  static const int todayLayerIdBase = 9100;
  static const int maxTodayLayerSlots = 28;

  /// Pending notifications reserved for non-quote consumers so the today layer
  /// never pushes the app over the 64-pending iOS cap: 1 Angelus + ~9 headroom
  /// for custom phrases and prayer intentions. (Liturgy hours are not a live
  /// consumer — no settings toggle — so they are not counted.)
  static const int kReservedNonQuoteBudget = 10;

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

    // ---- Layer A: today's dense one-shots ----
    // Fill the rest of today at the preset's cadence with fresh one-shot quotes
    // (not OS-repeating). Past hours are left untouched and future hours refilled
    // on each pass, so reopening the app never re-rolls a slot that hasn't fired.
    // The grid floor (Layer B) skips today's weekday so today isn't double-fired.
    final todaySlots = QuoteSlotPlanner.todaySlotsFrom(
      now: current,
      cadenceMinutes: preset.todayCadenceMinutes,
      windowStartMinutes: kQuoteWindowStartMinutes,
      windowEndMinutes: kQuoteWindowEndMinutes,
      quietHoursEnabled: settings.quietHoursEnabled,
      quietHoursStart: settings.quietHoursStart,
      quietHoursEnd: settings.quietHoursEnd,
    );

    // Weekly grid floor slot times (Layer B), computed up front because the
    // today layer's budget depends on how many grid cells we will register.
    final gridSlotMinutes = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: preset.todayCadenceMinutes,
      windowStartMinutes: kQuoteWindowStartMinutes,
      windowEndMinutes: kQuoteWindowEndMinutes,
      quietHoursEnabled: settings.quietHoursEnabled,
      quietHoursStart: settings.quietHoursStart,
      quietHoursEnd: settings.quietHoursEnd,
      maxSlots: preset.weeklyFloorSlotsPerWeekday,
    );
    // 6 weekdays carry the grid floor (today's weekday is covered by Layer A).
    const gridFloorWeekdays = 6;
    final plannedGridFloorCount = gridFloorWeekdays * gridSlotMinutes.length;

    // Total slots quotes may occupy = the 64 cap minus everything reserved for
    // higher-priority (sacred) consumers. Grid floor fills first, then the today
    // layer takes whatever is left. Under heavy sacred load this shrinks quotes
    // to zero before it would ever push the app past the cap.
    final quoteSlotBudget = max(0, maxQueuedQuoteReminders - reservedForOthers);
    final gridFloorCount = min(plannedGridFloorCount, quoteSlotBudget);

    // Reserved-budget guard: keep the today layer below the iOS 64-pending cap
    // with headroom for the grid floor and non-quote consumers. The denser the
    // preset, the more this binds (e.g. 30-min full window: min(28, 64-30-10)=24).
    // The max(0, …) floor is defensive: if the reserve/grid constants are ever
    // tuned so the budget goes negative, the loop schedules zero today slots
    // rather than passing a negative count to take().
    final effectiveTodayCap = max(
      0,
      min(maxTodayLayerSlots, quoteSlotBudget - gridFloorCount),
    );

    // Assignment cache: a today slot (identified by its concrete fire DateTime)
    // is assigned a quote once and persisted as a future history row. While that
    // fire time is still ahead, re-running this pass on a same-day reopen reuses
    // the cached assignment instead of drawing again — so the shuffle bag advances
    // ~once per delivered quote, not once per scheduled slot per reopen. Rows whose
    // fire time has already passed are real past deliveries and are never reused
    // for a future slot, so an elapsed-then-recreated slot redraws exactly once.
    final existingAssignments =
        await _notificationHistoryRepository.listFromUntilEndOfDay(current);
    final assignmentByFireTime = {
      for (final entry in existingAssignments)
        entry.deliveredAt.toIso8601String(): entry,
    };
    // The fire times we will (re)schedule this pass; every other future row on
    // today's calendar day is stale and gets pruned below.
    final scheduledSlots = todaySlots.take(effectiveTodayCap).toList();
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
        // New (or newly elapsed) slot: draw once and persist the assignment.
        quote = await fetchNonRepeatingQuote(
          language: settings.language,
          slot: fireAt,
        );
        await _notificationHistoryRepository.add(
          NotificationHistoryEntry.fromQuote(quote, deliveredAt: fireAt),
        );
      }

      final scheduledId = todayLayerIdBase + slotIndex;
      await _scheduler.scheduleWithId(
        scheduledId,
        _buildQuoteEvent(id: scheduledId, fireAt: fireAt, quote: quote),
      );
    }

    // Prune stale future assignment rows (e.g. cadence changed so a previously
    // scheduled fire time no longer exists). clearFromExcept only touches rows
    // after `current` on today's calendar day, so real past deliveries survive.
    await _notificationHistoryRepository.clearFromExcept(current, keepFireTimes);

    debugPrint(
      '[ScheduleCoreRemindersUseCase] registered today layer: '
      '${todaySlots.length} one-shots (cadence=${preset.todayCadenceMinutes}m)',
    );

    // ---- Layer B: weekly grid floor ----
    // (each weekday 1..7 EXCEPT today) x (each daily slot time). Each cell
    // repeats weekly via DateTimeComponents.dayOfWeekAndTime, so iOS fires the
    // correct weekday's quote even if the app is never reopened. Today's weekday
    // is skipped because Layer A already covers today densely. The slot times
    // (gridSlotMinutes) were computed above to size the today-layer budget.
    final skipWeekday = current.weekday;
    var gridFloorScheduled = 0;
    for (var weekdayIndex = 0; weekdayIndex < 7; weekdayIndex++) {
      // Dart DateTime.weekday is 1=Mon..7=Sun. weekdayIndex 0..6 maps to that.
      final weekday = weekdayIndex + 1;
      if (weekday == skipWeekday) continue; // today is covered by Layer A
      for (var slotIndex = 0; slotIndex < gridSlotMinutes.length; slotIndex++) {
        // Respect the quote slot budget — grid cells beyond it are dropped so
        // sacred reminders keep their slots under the 64-pending cap.
        if (gridFloorScheduled >= gridFloorCount) break;
        gridFloorScheduled++;
        final minutesOfDay = gridSlotMinutes[slotIndex];
        final fireAt = _nextOccurrenceOnWeekday(
          current,
          weekday,
          minutesOfDay ~/ 60,
          minutesOfDay % 60,
        );

        final quote = await fetchNonRepeatingQuote(
          language: settings.language,
          slot: fireAt,
        );

        final scheduledId = quoteScheduleIdBase +
            (weekdayIndex * kMaxQuoteSlotsPerWeekday) +
            slotIndex;

        await _scheduler.scheduleWithId(
          scheduledId,
          _buildQuoteEvent(
            id: scheduledId,
            fireAt: fireAt,
            quote: quote,
            repeatWeekly: true,
          ),
        );
      }
    }

    debugPrint(
      '[ScheduleCoreRemindersUseCase] registered weekly grid floor: '
      '${gridSlotMinutes.length} slots x 6 weekdays (skipped today=$skipWeekday)',
    );

    // Schedule the daily noon repeat (Angelus / Regina Caeli). It carries the
    // season-specific prayer name. This repeat cannot re-bake itself while the
    // app is closed, so if a season boundary falls within the next
    // [boundaryBridgeDays] it is baked for the season the boundary is ENTERING —
    // matching the season noon bridge, so the two never show contradictory
    // prayer names on a bridge day. Far from a boundary this is simply today's
    // season.
    if (settings.angelusEnabled) {
      final noon = PrayerScheduler.calculateNextNoon(current).nextTriggerTime;
      final repeatIsEasterSeason =
          isEasterSeason || _seasonForDailyRepeat(current);
      final noonTitle = repeatIsEasterSeason ? 'Regina Caeli' : 'Angelus';
      final noonBody = repeatIsEasterSeason
          ? 'Hora de rezar a Regina Caeli.'
          : 'Hora de rezar o Angelus.';
      final noonInQuietHours =
          settings.quietHoursEnabled &&
          QuietHoursChecker.isDuringQuietHours(
            noon,
            settings.quietHoursStart,
            settings.quietHoursEnd,
          );
      if (!noonInQuietHours) {
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

  /// Season to bake into the daily noon repeat. The repeat cannot re-bake itself
  /// while the app is closed, so it looks [_dailyRepeatLookaheadDays] ahead: if a
  /// boundary falls within that window it is baked for the season just past that
  /// horizon, matching the season noon bridge so the two never contradict each
  /// other on a bridge day. Far from any boundary the horizon lands in today's
  /// season, so this is simply the current season.
  bool _seasonForDailyRepeat(DateTime current) => _isDateWithinEasterSeason(
        current.add(const Duration(days: _dailyRepeatLookaheadDays)),
      );

  /// Matches the season noon bridge window so the daily repeat pre-switches in
  /// lockstep with the bridge.
  static const int _dailyRepeatLookaheadDays = 7;

  /// Next DateTime at the given weekday (1=Mon..7=Sun) and clock time, at or
  /// after [from]. Used as the first fire time for a weekly-repeating slot.
  DateTime _nextOccurrenceOnWeekday(
    DateTime from,
    int weekday,
    int hour,
    int minute,
  ) {
    var candidate = DateTime(from.year, from.month, from.day, hour, minute);
    final dayDelta = (weekday - candidate.weekday + 7) % 7;
    candidate = candidate.add(Duration(days: dayDelta));
    if (!candidate.isAfter(from)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    return candidate;
  }

  /// Builds a quote-interval [ReminderEvent] from a fetched quote. Shared by the
  /// immediate notification, the today layer, and the weekly grid floor so the
  /// 13 shared fields live in one place; [repeatWeekly] is the only behavioural
  /// difference (true for grid-floor cells, false for one-shots).
  ReminderEvent _buildQuoteEvent({
    required int id,
    required DateTime fireAt,
    required Quote quote,
    bool repeatWeekly = false,
  }) {
    return ReminderEvent(
      type: ReminderEventType.quoteInterval,
      title: 'Iacula',
      body: quote.text,
      scheduledAt: fireAt,
      withVibration: true,
      isAlarm: false,
      repeatWeekly: repeatWeekly,
      routeTarget: NotificationRouteTarget.home,
      scheduledId: id,
      quoteTheme: quote.theme,
      quoteSeason: quote.season.name,
      quoteFeastName: quote.feastName,
      quoteImagePath: quote.imagePath,
    );
  }
}
