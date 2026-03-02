// lib/features/prayer_intentions/application/use_cases/cancel_prayer_intention_reminder_use_case.dart

import '../../../notifications/domain/repositories/notification_scheduler_repository.dart';
import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../prayer_intention_notification_id.dart';

final class CancelPrayerIntentionReminderUseCase {
  const CancelPrayerIntentionReminderUseCase(
    this._repository,
    this._scheduler,
  );

  final SpiritualEntryRepository _repository;
  final NotificationSchedulerRepository _scheduler;

  Future<void> call(String intentionId) async {
    final notificationId = prayerIntentionNotificationId(intentionId);
    await _scheduler.cancelById(notificationId);

    final entries = await _repository.listLocal(includeDeleted: true);
    SpiritualEntry? entry;
    for (final e in entries) {
      if (e.id == intentionId) {
        entry = e;
        break;
      }
    }
    if (entry != null && entry.scheduleJson != null) {
      await _repository.saveLocal(
        entry.copyWith(scheduleJson: null, isDirty: true),
      );
    }
  }
}
