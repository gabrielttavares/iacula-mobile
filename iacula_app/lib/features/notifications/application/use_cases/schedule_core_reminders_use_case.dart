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

typedef QuoteBatchFetcher =
    Future<List<Quote>> Function({
      required String language,
      required int count,
      required DateTime startTime,
      required int intervalMinutes,
    });

final class ScheduleCoreRemindersUseCase {
  static const int quoteScheduleIdBase = 9000;
  static const int maxQueuedQuoteReminders = 64;

  const ScheduleCoreRemindersUseCase(
    this._scheduler, {
    required QuoteFetcher quoteFetcher,
    required NotificationHistoryRepository notificationHistoryRepository,
    required LastDeliveredCardRepository lastDeliveredCardRepository,
    QuoteBatchFetcher? batchFetcher,
  }) : _quoteFetcher = quoteFetcher,
       _notificationHistoryRepository = notificationHistoryRepository,
       _lastDeliveredCardRepository = lastDeliveredCardRepository,
       _batchFetcher = batchFetcher;

  final NotificationSchedulerRepository _scheduler;
  final QuoteFetcher _quoteFetcher;
  final QuoteBatchFetcher? _batchFetcher;
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
    debugPrint(
      '[ScheduleCoreRemindersUseCase] scheduling at ${current.toIso8601String()} '
      'interval=${settings.intervalMinutes}m lang=${settings.language} '
      'showImmediate=$showImmediate platform=${Platform.operatingSystem}',
    );
    await _notificationHistoryRepository.clearFrom(current);

    final resolvedImmediate =
        immediateQuote ??
        await _quoteFetcher(language: settings.language, now: current);

    var shouldShowImmediate = showImmediate;
    if (showImmediate) {
      final todayHistory = await _notificationHistoryRepository.listForDay(current);
      final hasRecentDueQuote = todayHistory.any((entry) {
        if (entry.deliveredAt.isAfter(current)) return false;
        final minutesAgo = current.difference(entry.deliveredAt).inMinutes;
        return minutesAgo >= 0 && minutesAgo < settings.intervalMinutes;
      });
      if (hasRecentDueQuote) {
        shouldShowImmediate = false;
        debugPrint(
          '[ScheduleCoreRemindersUseCase] skip immediate quote: recent due history exists within interval.',
        );
      }
    }

    if (shouldShowImmediate) {
      const immediateId = quoteScheduleIdBase - 1;
      debugPrint(
        '[ScheduleCoreRemindersUseCase] show immediate quote id=$immediateId textLen=${resolvedImmediate.text.length}',
      );
      await _scheduler.showNow(
        immediateId,
        ReminderEvent(
          type: ReminderEventType.quoteInterval,
          title: 'Iacula',
          body: resolvedImmediate.text,
          scheduledAt: current,
          withVibration: true,
          isAlarm: false,
          routeTarget: NotificationRouteTarget.home,
          scheduledId: immediateId,
          quoteTheme: resolvedImmediate.theme,
          quoteSeason: resolvedImmediate.season.name,
          quoteFeastName: resolvedImmediate.feastName,
        ),
      );
    }

    if (shouldShowImmediate) {
      final deliveredCard = LastDeliveredCard.fromQuote(
        resolvedImmediate,
        deliveredAt: current,
      );
      await _lastDeliveredCardRepository.save(deliveredCard);

      await HomeWidgetService.instance.updateWidget(
        deliveredCard,
        intervalMinutes: settings.intervalMinutes,
      );

      await _notificationHistoryRepository.add(
        NotificationHistoryEntry(
          quoteText: resolvedImmediate.text,
          theme: resolvedImmediate.theme,
          season: resolvedImmediate.season.name,
          deliveredAt: current,
          imagePath: resolvedImmediate.imagePath,
          feastName: resolvedImmediate.feastName,
        ),
      );
    }

    // iOS allows at most 64 pending notifications. Reserve slots for
    // non-quote notifications (Angelus, liturgy hours, custom phrases).
    const iosScheduledLimit = 64;
    const reservedSlots = 6; // 1 Angelus + 4 liturgy + 1 buffer
    final quoteCount = Platform.isIOS
        ? min(maxQueuedQuoteReminders, iosScheduledLimit - reservedSlots)
        : maxQueuedQuoteReminders;
    debugPrint(
      '[ScheduleCoreRemindersUseCase] quote queue size=$quoteCount (max=$maxQueuedQuoteReminders, '
      'iosReserved=$reservedSlots, isIOS=${Platform.isIOS})',
    );

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

    // Use batch fetcher only on linear schedule (no quiet-hours jumps).
    final List<Quote> scheduledQuotes;
    if (_batchFetcher != null && !settings.quietHoursEnabled) {
      scheduledQuotes = await _batchFetcher(
        language: settings.language,
        count: quoteCount,
        startTime: current,
        intervalMinutes: settings.intervalMinutes,
      );
    } else {
      scheduledQuotes = <Quote>[];
      for (final quoteAt in scheduledTimes) {
        scheduledQuotes.add(
          await _quoteFetcher(language: settings.language, now: quoteAt),
        );
      }
    }

    for (var i = 0; i < scheduledQuotes.length; i++) {
      final quoteAt = scheduledTimes[i];
      final quote = scheduledQuotes[i];
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
        ),
      );

      if (_isSameDay(quoteAt, current)) {
        await _notificationHistoryRepository.add(
          NotificationHistoryEntry(
            quoteText: quote.text,
            theme: quote.theme,
            season: quote.season.name,
            deliveredAt: quoteAt,
            imagePath: quote.imagePath,
            feastName: quote.feastName,
          ),
        );
      }
    }

    if (scheduledQuotes.isNotEmpty) {
      final firstAt = scheduledTimes.first;
      final lastAt = scheduledTimes.last;
      debugPrint(
        '[ScheduleCoreRemindersUseCase] queued ${scheduledQuotes.length} quote reminders from '
        '${firstAt.toIso8601String()} to ${lastAt.toIso8601String()}',
      );
    }

    if (settings.angelusEnabled) {
      final noonTitle = isEasterSeason ? 'Regina Caeli' : 'Angelus';
      final noonBody = isEasterSeason
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
        debugPrint(
          '[ScheduleCoreRemindersUseCase] scheduling Angelus/Regina id=200 at ${noon.toIso8601String()} '
          'title=$noonTitle repeatDaily=true',
        );
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
          ),
        );
      } else {
        debugPrint(
          '[ScheduleCoreRemindersUseCase] noon trigger falls inside quiet hours; skipping Angelus scheduling.',
        );
      }
    } else {
      debugPrint(
        '[ScheduleCoreRemindersUseCase] Angelus disabled; skipping noon alarm scheduling.',
      );
    }
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
