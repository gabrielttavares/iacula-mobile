// lib/features/prayer_intentions/application/use_cases/schedule_prayer_intention_reminder_use_case.dart

import 'dart:convert';

import '../../../notifications/domain/entities/reminder_event.dart';
import '../../../notifications/domain/repositories/notification_scheduler_repository.dart';
import '../../domain/entities/intention_schedule.dart';
import '../prayer_intention_notification_id.dart';
import '../services/intention_next_occurrence_calculator.dart';
import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';

final class SchedulePrayerIntentionReminderUseCase {
  const SchedulePrayerIntentionReminderUseCase(
    this._repository,
    this._scheduler,
  );

  final SpiritualEntryRepository _repository;
  final NotificationSchedulerRepository _scheduler;

  Future<void> call(String intentionId, IntentionSchedule schedule) async {
    final entries = await _repository.listLocal(includeDeleted: true);
    SpiritualEntry? entry;
    for (final e in entries) {
      if (e.id == intentionId) {
        entry = e;
        break;
      }
    }
    if (entry == null) return;

    final now = DateTime.now();
    final occurrences = IntentionNextOccurrenceCalculator.nextOccurrences(
      schedule: schedule,
      now: now,
    );

    for (final (index, scheduledAt) in occurrences.indexed) {
      final notificationId = _notificationIdForIndex(intentionId, index);
      final event = ReminderEvent(
        type: ReminderEventType.prayerIntentionReminder,
        title: entry.title ?? 'Intenção de oração',
        body: entry.body.isNotEmpty ? entry.body : 'Reze por esta intenção.',
        scheduledAt: scheduledAt,
        withVibration: true,
        isAlarm: false,
        repeatDaily: schedule.type == IntentionScheduleType.daily,
        repeatWeekly: schedule.type == IntentionScheduleType.weekly,
        routeTarget: NotificationRouteTarget.prayerIntention,
        scheduledId: notificationId,
        intentionId: intentionId,
      );
      await _scheduler.scheduleWithId(notificationId, event);
    }

    await _repository.saveLocal(
      entry.copyWith(
        scheduleJson: jsonEncode(schedule.toJson()),
        isDirty: true,
      ),
    );
  }

  static int _notificationIdForIndex(String intentionId, int index) {
    final baseId = intentionId.hashCode.abs();
    return 500000 + (baseId % 499000) + index;
  }
}
