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
    await _notificationHistoryRepository.clearFrom(current);

    final resolvedImmediate =
        immediateQuote ??
        await _quoteFetcher(language: settings.language, now: current);

    if (showImmediate) {
      const immediateId = quoteScheduleIdBase - 1;
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

    // Use batch fetcher if available (1 DB read + 1 DB write instead of 64+64)
    final List<Quote> scheduledQuotes;
    if (_batchFetcher != null) {
      scheduledQuotes = await _batchFetcher(
        language: settings.language,
        count: maxQueuedQuoteReminders,
        startTime: current,
        intervalMinutes: settings.intervalMinutes,
      );
    } else {
      scheduledQuotes = <Quote>[];
      for (var i = 0; i < maxQueuedQuoteReminders; i++) {
        final quoteAt = current.add(
          Duration(minutes: settings.intervalMinutes * (i + 1)),
        );
        scheduledQuotes.add(
          await _quoteFetcher(language: settings.language, now: quoteAt),
        );
      }
    }

    for (var i = 0; i < scheduledQuotes.length; i++) {
      final quoteAt = current.add(
        Duration(minutes: settings.intervalMinutes * (i + 1)),
      );
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

    if (settings.angelusEnabled) {
      final noonTitle = isEasterSeason ? 'Regina Caeli' : 'Angelus';
      final noonBody = isEasterSeason
          ? 'Hora de rezar a Regina Caeli.'
          : 'Hora de rezar o Angelus.';

      final noon = PrayerScheduler.calculateNextNoon(current).nextTriggerTime;
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
    }
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
