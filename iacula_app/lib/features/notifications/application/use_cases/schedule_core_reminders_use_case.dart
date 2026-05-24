import 'dart:io' show Platform;
import 'dart:math' show min;

import 'package:flutter/foundation.dart';

import '../../../home_widget/home_widget_service.dart';
import '../../../prayers/domain/services/prayer_scheduler.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../domain/entities/last_delivered_card.dart';
import '../../domain/entities/notification_history_entry.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';
import '../../domain/repositories/notification_history_repository.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';
import '../../domain/services/quiet_hours_checker.dart';

typedef QuoteFetcher =
    Future<Quote> Function({required String language, required DateTime now});

final class ScheduleCoreRemindersUseCase {
  static const int quoteScheduleIdBase = 9000;
  static const int maxQueuedQuoteReminders = 64;
  static const int angelusScheduleIdBase = 200;
  static const int angelusScheduleDays = 7;

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
        ReminderEvent(
          type: ReminderEventType.quoteInterval,
          title: 'Iacula',
          body: quote.text,
          scheduledAt: current,
          withVibration: true,
          isAlarm: false,
          routeTarget: NotificationRouteTarget.home,
          scheduledId: immediateId,
          quoteTheme: quote.theme,
          quoteSeason: quote.season.name,
          quoteFeastName: quote.feastName,
          quoteImagePath: quote.imagePath,
        ),
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

    // iOS allows at most 64 pending notifications total.
    // Reserve slots for non-quote notifications.
    const iosScheduledLimit = 64;
    const reservedSlots = 12;
    final quoteCount = Platform.isIOS
        ? min(maxQueuedQuoteReminders, iosScheduledLimit - reservedSlots)
        : maxQueuedQuoteReminders;

    // Compute future time slots respecting quiet hours
    final scheduledTimes = <DateTime>[];
    var cursor = current;
    for (var i = 0; i < quoteCount; i++) {
      cursor = cursor.add(Duration(minutes: settings.intervalMinutes));
      if (settings.quietHoursEnabled) {
        while (QuietHoursChecker.isDuringQuietHours(
          cursor,
          settings.quietHoursStart,
          settings.quietHoursEnd,
        )) {
          cursor = QuietHoursChecker.nextActiveTime(
            cursor,
            settings.quietHoursEnd,
          );
        }
      }
      scheduledTimes.add(cursor);
    }

    // Reuse existing history entries so rebuilds don't replace quotes that
    // the OS already delivered (or will deliver) to the notification center.
    final existingFutureEntries =
        await _notificationHistoryRepository.listFromUntilEndOfDay(current);
    final existingByTime = <String, NotificationHistoryEntry>{};
    for (final entry in existingFutureEntries) {
      existingByTime[entry.deliveredAt.toIso8601String()] = entry;
    }

    for (var i = 0; i < scheduledTimes.length; i++) {
      final quoteAt = scheduledTimes[i];
      final scheduledId = quoteScheduleIdBase + i;
      final existingEntry = existingByTime[quoteAt.toIso8601String()];

      if (existingEntry != null) {
        recentQuoteTexts.add(existingEntry.quoteText);
        if (recentQuoteTexts.length > recentLookbackSize) {
          recentQuoteTexts.removeAt(0);
        }
        await _scheduler.scheduleWithId(
          scheduledId,
          ReminderEvent(
            type: ReminderEventType.quoteInterval,
            title: 'Iacula',
            body: existingEntry.quoteText,
            scheduledAt: quoteAt,
            withVibration: true,
            isAlarm: false,
            routeTarget: NotificationRouteTarget.home,
            scheduledId: scheduledId,
            quoteTheme: existingEntry.theme,
            quoteSeason: existingEntry.season,
            quoteFeastName: existingEntry.feastName,
            quoteImagePath: existingEntry.imagePath,
          ),
        );
      } else {
        final quote = await fetchNonRepeatingQuote(
          language: settings.language,
          slot: quoteAt,
        );

        await _scheduler.scheduleWithId(
          scheduledId,
          ReminderEvent(
            type: ReminderEventType.quoteInterval,
            title: 'Iacula',
            body: quote.text,
            scheduledAt: quoteAt,
            withVibration: true,
            isAlarm: false,
            routeTarget: NotificationRouteTarget.home,
            scheduledId: scheduledId,
            quoteTheme: quote.theme,
            quoteSeason: quote.season.name,
            quoteFeastName: quote.feastName,
            quoteImagePath: quote.imagePath,
          ),
        );

        await _notificationHistoryRepository.add(
          NotificationHistoryEntry(
            quoteText: quote.text,
            theme: quote.theme,
            season: quote.season.name,
            deliveredAt: quoteAt,
            imagePath: quote.imagePath,
            feastName: quote.feastName,
            source: quote.resolvedSource.name,
            referenceLabel: quote.referenceLabel,
          ),
        );
      }
    }

    // Remove orphaned future entries that no longer match any scheduled slot
    // (e.g. after an interval change shifted all time slots).
    final scheduledTimestamps =
        scheduledTimes.map((dt) => dt.toIso8601String()).toSet();
    await _notificationHistoryRepository.clearFromExcept(
      current,
      scheduledTimestamps,
    );

    debugPrint(
      '[ScheduleCoreRemindersUseCase] queued ${scheduledTimes.length} quote reminders',
    );

    // Schedule Angelus/Regina Caeli — one non-repeating notification per day so
    // the title and prayer slug stay correct across Easter season boundaries.
    if (settings.angelusEnabled) {
      for (var dayOffset = 0; dayOffset < angelusScheduleDays; dayOffset++) {
        final noonDate = current.add(Duration(days: dayOffset));
        final noon = DateTime(noonDate.year, noonDate.month, noonDate.day, 12);
        if (!noon.isAfter(current) && dayOffset == 0) continue;

        final noonInQuietHours =
            settings.quietHoursEnabled &&
            QuietHoursChecker.isDuringQuietHours(
              noon,
              settings.quietHoursStart,
              settings.quietHoursEnd,
            );
        if (noonInQuietHours) continue;

        final isEasterDay = _isDateWithinEasterSeason(noon);
        final noonTitle = isEasterDay ? 'Regina Caeli' : 'Angelus';
        final noonBody = isEasterDay
            ? 'Hora de rezar a Regina Caeli.'
            : 'Hora de rezar o Angelus.';
        final prayerSlug = isEasterDay ? 'regina-coeli' : 'angelus';

        await _scheduler.scheduleWithId(
          angelusScheduleIdBase + dayOffset,
          ReminderEvent(
            type: ReminderEventType.angelusNoon,
            title: noonTitle,
            body: noonBody,
            scheduledAt: noon,
            withVibration: true,
            isAlarm: true,
            routeTarget: NotificationRouteTarget.prayer,
            prayerSlug: prayerSlug,
          ),
        );
      }
    }
  }

  bool _isDateWithinEasterSeason(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final easterSunday = _calculateGregorianEasterSunday(day.year);
    final pentecostSunday = easterSunday.add(const Duration(days: 49));
    return !day.isBefore(easterSunday) && !day.isAfter(pentecostSunday);
  }

  DateTime _calculateGregorianEasterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }
}
