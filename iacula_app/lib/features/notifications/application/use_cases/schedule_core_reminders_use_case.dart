import '../../../prayers/domain/services/prayer_scheduler.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../domain/entities/last_delivered_card.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

typedef QuoteFetcher = Future<Quote> Function({
  required String language,
  required DateTime now,
});

final class ScheduleCoreRemindersUseCase {
  const ScheduleCoreRemindersUseCase(
    this._scheduler, {
    required QuoteFetcher quoteFetcher,
    required LastDeliveredCardRepository lastDeliveredCardRepository,
  })  : _quoteFetcher = quoteFetcher,
        _lastDeliveredCardRepository = lastDeliveredCardRepository;

  final NotificationSchedulerRepository _scheduler;
  final QuoteFetcher _quoteFetcher;
  final LastDeliveredCardRepository _lastDeliveredCardRepository;

  Future<void> call(Settings settings, {DateTime? now}) async {
    final current = now ?? DateTime.now();
    final nextQuote = await _quoteFetcher(language: settings.language, now: current);

    final quoteAt = current.add(Duration(minutes: settings.intervalMinutes));
    await _scheduler.schedule(
      ReminderEvent(
        type: ReminderEventType.quoteInterval,
        title: 'Iacula',
        body: nextQuote.text,
        scheduledAt: quoteAt,
        withVibration: true,
        isAlarm: false,
      ),
    );
    await _lastDeliveredCardRepository.save(
      LastDeliveredCard.fromQuote(nextQuote, deliveredAt: quoteAt),
    );

    final noon = PrayerScheduler.calculateNextNoon(current).nextTriggerTime;
    await _scheduler.schedule(
      ReminderEvent(
        type: ReminderEventType.angelusNoon,
        title: 'Angelus',
        body: 'Rezar ao meio-dia',
        scheduledAt: noon,
        withVibration: true,
        isAlarm: true,
        repeatDaily: true,
      ),
    );
  }
}
