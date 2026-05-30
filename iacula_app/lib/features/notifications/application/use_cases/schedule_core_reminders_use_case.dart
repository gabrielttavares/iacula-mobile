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
  static const int todayLayerIdBase = 9100;
  static const int maxTodayLayerSlots = 27;

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
  }) async {
    final current = now ?? DateTime.now();
    final effectiveIsEasterSeason =
        isEasterSeason || _isDateWithinEasterSeason(current);

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
        NotificationHistoryEntry(
          quoteText: quote.text,
          theme: quote.theme,
          season: quote.season.name,
          deliveredAt: current,
          imagePath: quote.imagePath,
          feastName: quote.feastName,
          source: quote.resolvedSource.name,
          referenceLabel: quote.referenceLabel,
        ),
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

    for (var slotIndex = 0;
        slotIndex < todaySlots.length && slotIndex < maxTodayLayerSlots;
        slotIndex++) {
      final fireAt = todaySlots[slotIndex];
      final quote = await fetchNonRepeatingQuote(
        language: settings.language,
        slot: fireAt,
      );
      final scheduledId = todayLayerIdBase + slotIndex;
      await _scheduler.scheduleWithId(
        scheduledId,
        _buildQuoteEvent(id: scheduledId, fireAt: fireAt, quote: quote),
      );
    }

    debugPrint(
      '[ScheduleCoreRemindersUseCase] registered today layer: '
      '${todaySlots.length} one-shots (cadence=${preset.todayCadenceMinutes}m)',
    );

    // ---- Layer B: weekly grid floor ----
    // (each weekday 1..7 EXCEPT today) x (each daily slot time). Each cell
    // repeats weekly via DateTimeComponents.dayOfWeekAndTime, so iOS fires the
    // correct weekday's quote even if the app is never reopened. Today's weekday
    // is skipped because Layer A already covers today densely.
    final slotMinutes = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: preset.todayCadenceMinutes,
      windowStartMinutes: kQuoteWindowStartMinutes,
      windowEndMinutes: kQuoteWindowEndMinutes,
      quietHoursEnabled: settings.quietHoursEnabled,
      quietHoursStart: settings.quietHoursStart,
      quietHoursEnd: settings.quietHoursEnd,
      maxSlots: preset.weeklyFloorSlotsPerWeekday,
    );

    final skipWeekday = current.weekday;
    for (var weekdayIndex = 0; weekdayIndex < 7; weekdayIndex++) {
      // Dart DateTime.weekday is 1=Mon..7=Sun. weekdayIndex 0..6 maps to that.
      final weekday = weekdayIndex + 1;
      if (weekday == skipWeekday) continue; // today is covered by Layer A
      for (var slotIndex = 0; slotIndex < slotMinutes.length; slotIndex++) {
        final minutesOfDay = slotMinutes[slotIndex];
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
      '${slotMinutes.length} slots x 6 weekdays (skipped today=$skipWeekday)',
    );

    // Schedule Angelus/Regina Caeli
    if (settings.angelusEnabled) {
      final noonTitle = effectiveIsEasterSeason ? 'Regina Caeli' : 'Angelus';
      final noonBody = effectiveIsEasterSeason
          ? 'Hora de rezar a Regina Caeli.'
          : 'Hora de rezar o Angelus.';

      final noon = PrayerScheduler.calculateNextNoon(current).nextTriggerTime;
      final noonInQuietHours =
          settings.quietHoursEnabled &&
          QuietHoursChecker.isDuringQuietHours(
            noon,
            settings.quietHoursStart,
            settings.quietHoursEnd,
          );
      if (!noonInQuietHours) {
        final prayerSlug = effectiveIsEasterSeason ? 'regina-coeli' : 'angelus';
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
