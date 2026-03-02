// lib/features/prayer_intentions/application/use_cases/schedule_prayer_intention_reminder_use_case.dart

import '../../../notifications/domain/entities/reminder_event.dart';
import '../../../notifications/domain/repositories/notification_scheduler_repository.dart';
import '../../../notifications/domain/services/next_occurrence_calculator.dart';
import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../prayer_intention_notification_id.dart';

final class SchedulePrayerIntentionReminderUseCase {
  const SchedulePrayerIntentionReminderUseCase(
    this._repository,
    this._scheduler,
  );

  final SpiritualEntryRepository _repository;
  final NotificationSchedulerRepository _scheduler;

  Future<void> call(String intentionId, String hhmm) async {
    final entries = await _repository.listLocal(includeDeleted: true);
    SpiritualEntry? entry;
    for (final e in entries) {
      if (e.id == intentionId) {
        entry = e;
        break;
      }
    }
    if (entry == null) return;

    final scheduledAt = NextOccurrenceCalculator.forHourMinute(
      now: DateTime.now(),
      hhmm: hhmm,
    );
    final notificationId = prayerIntentionNotificationId(intentionId);
    final event = ReminderEvent(
      type: ReminderEventType.prayerIntentionReminder,
      title: entry.title ?? 'Intencao de oracao',
      body: entry.body.isNotEmpty ? entry.body : 'Reze por esta intencao.',
      scheduledAt: scheduledAt,
      withVibration: true,
      isAlarm: false,
      repeatDaily: true,
      routeTarget: NotificationRouteTarget.prayerIntention,
      scheduledId: notificationId,
      intentionId: intentionId,
    );
    await _scheduler.schedule(event);

    final scheduleJson = '{"reminderTime":"$hhmm"}';
    await _repository.saveLocal(
      entry.copyWith(scheduleJson: scheduleJson, isDirty: true),
    );
  }
}
