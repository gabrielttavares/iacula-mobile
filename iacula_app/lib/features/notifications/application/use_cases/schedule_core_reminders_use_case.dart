import '../../../prayers/domain/services/prayer_scheduler.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

typedef QuoteFetcher =
    Future<Quote> Function({required String language, required DateTime now});

final class ScheduleCoreRemindersUseCase {
  static const int quoteScheduleIdBase = 9000;
  static const int maxQueuedQuoteReminders = 64;

  const ScheduleCoreRemindersUseCase(
    this._scheduler, {
    required QuoteFetcher quoteFetcher,
  }) : _quoteFetcher = quoteFetcher;

  final NotificationSchedulerRepository _scheduler;
  final QuoteFetcher _quoteFetcher;

  Future<void> call(
    Settings settings, {
    DateTime? now,
    bool isEasterSeason = false,
  }) async {
    final current = now ?? DateTime.now();
    for (var i = 0; i < maxQueuedQuoteReminders; i++) {
      final quoteAt = current.add(
        Duration(minutes: settings.intervalMinutes * (i + 1)),
      );
      final quote = await _quoteFetcher(
        language: settings.language,
        now: quoteAt,
      );

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
          quoteTheme: quote.theme,
          quoteSeason: quote.season.name,
          quoteFeastName: quote.feastName,
        ),
      );
    }

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
