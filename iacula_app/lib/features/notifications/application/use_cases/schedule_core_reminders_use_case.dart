import '../../../prayers/domain/services/prayer_scheduler.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/repositories/notification_scheduler_repository.dart';

final class ScheduleCoreRemindersUseCase {
  const ScheduleCoreRemindersUseCase(this._scheduler);

  final NotificationSchedulerRepository _scheduler;

  Future<void> call(Settings settings, {DateTime? now}) async {
    final current = now ?? DateTime.now();

    final quoteAt = current.add(Duration(minutes: settings.intervalMinutes));
    await _scheduler.schedule(
      ReminderEvent(
        type: ReminderEventType.quoteInterval,
        title: 'Iacula',
        body: 'Momento de jaculatoria',
        scheduledAt: quoteAt,
        withVibration: true,
        isAlarm: false,
      ),
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
