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

    // Show an immediate notification if requested
    if (showImmediate) {
      final quote = immediateQuote ??
          await _quoteFetcher(language: settings.language, now: current);

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
    const reservedSlots = 6;
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

    await _notificationHistoryRepository.clearFrom(current);

    // Fetch one quote per slot, schedule, and write history
    for (var i = 0; i < scheduledTimes.length; i++) {
      final quoteAt = scheduledTimes[i];
      final quote = await _quoteFetcher(
        language: settings.language,
        now: quoteAt,
      );
      final scheduledId = quoteScheduleIdBase + i;

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

    debugPrint(
      '[ScheduleCoreRemindersUseCase] queued ${scheduledTimes.length} quote reminders',
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
