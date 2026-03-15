import '../../../prayers/domain/services/prayer_scheduler.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../domain/entities/last_delivered_card.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

typedef QuoteFetcher =
    Future<Quote> Function({required String language, required DateTime now});

final class ScheduleCoreRemindersUseCase {
  static const int quoteScheduleIdBase = 9000;
  static const int maxQueuedQuoteReminders = 64;

  const ScheduleCoreRemindersUseCase(
    this._scheduler, {
    required QuoteFetcher quoteFetcher,
    required LastDeliveredCardRepository lastDeliveredCardRepository,
  }) : _quoteFetcher = quoteFetcher,
       _lastDeliveredCardRepository = lastDeliveredCardRepository;

  final NotificationSchedulerRepository _scheduler;
  final QuoteFetcher _quoteFetcher;
  final LastDeliveredCardRepository _lastDeliveredCardRepository;

  Future<void> call(Settings settings, {DateTime? now}) async {
    final current = now ?? DateTime.now();
    Quote? firstQuote;
    DateTime? firstQuoteAt;

    for (var i = 0; i < maxQueuedQuoteReminders; i++) {
      final quoteAt = current.add(
        Duration(minutes: settings.intervalMinutes * (i + 1)),
      );
      final quote = await _quoteFetcher(
        language: settings.language,
        now: quoteAt,
      );
      firstQuote ??= quote;
      firstQuoteAt ??= quoteAt;

      await _scheduler.scheduleWithId(
        quoteScheduleIdBase + i,
        ReminderEvent(
          type: ReminderEventType.quoteInterval,
          title: 'Iacula',
          body: quote.text,
          scheduledAt: quoteAt,
          withVibration: true,
          isAlarm: false,
          routeTarget: NotificationRouteTarget.home,
          scheduledId: quoteScheduleIdBase + i,
        ),
      );
    }

    if (firstQuote != null && firstQuoteAt != null) {
      await _lastDeliveredCardRepository.save(
        LastDeliveredCard.fromQuote(firstQuote, deliveredAt: firstQuoteAt),
      );
    }

    final noon = PrayerScheduler.calculateNextNoon(current).nextTriggerTime;
    await _scheduler.schedule(
      ReminderEvent(
        type: ReminderEventType.angelusNoon,
        title: 'Angelus',
        body: '',
        scheduledAt: noon,
        withVibration: true,
        isAlarm: true,
        repeatDaily: true,
        routeTarget: NotificationRouteTarget.prayer,
      ),
    );
  }
}
