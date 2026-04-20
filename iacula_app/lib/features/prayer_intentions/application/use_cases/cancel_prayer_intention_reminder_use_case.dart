// lib/features/prayer_intentions/application/use_cases/cancel_prayer_intention_reminder_use_case.dart

import 'dart:convert';

import '../../../notifications/domain/repositories/notification_scheduler_repository.dart';
import '../../domain/entities/intention_schedule.dart';
import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class CancelPrayerIntentionReminderUseCase {
  const CancelPrayerIntentionReminderUseCase(this._repository, this._scheduler);

  final SpiritualEntryRepository _repository;
  final NotificationSchedulerRepository _scheduler;

  Future<void> call(String intentionId) async {
    final entries = await _repository.listLocal(includeDeleted: true);
    SpiritualEntry? entry;
    for (final e in entries) {
      if (e.id == intentionId) {
        entry = e;
        break;
      }
    }

    IntentionSchedule? schedule;
    if (entry?.scheduleJson != null) {
      try {
        final map = jsonDecode(entry!.scheduleJson!) as Map<String, dynamic>;

        if (map.containsKey('reminderTime') && !map.containsKey('type')) {
          schedule = IntentionSchedule(
            type: IntentionScheduleType.daily,
            times: [map['reminderTime'] as String],
          );
        } else {
          schedule = IntentionSchedule.fromJson(map);
        }
      } catch (_) {}
    }

    final timeCount = schedule?.times.length ?? 1;
    for (int i = 0; i < timeCount; i++) {
      final notificationId = _notificationIdForIndex(intentionId, i);
      await _scheduler.cancelById(notificationId);
    }

    if (entry != null && entry.scheduleJson != null) {
      await _repository.saveLocal(
        entry.copyWith(scheduleJson: null, isDirty: true),
      );
    }
  }

  static int _notificationIdForIndex(String intentionId, int index) {
    final baseId = intentionId.hashCode.abs();
    return 500000 + (baseId % 499000) + index;
  }
}
