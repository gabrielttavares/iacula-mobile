import 'dart:convert';

import '../../../../features/notifications/domain/entities/reminder_event.dart';
import '../../../../features/notifications/domain/repositories/notification_scheduler_repository.dart';
import '../../../../features/notifications/domain/services/notification_budget.dart';
import '../../domain/entities/intention_schedule.dart';
import '../../../spiritual_data/domain/entities/spiritual_entry.dart';
import '../../../spiritual_data/domain/repositories/spiritual_entry_repository.dart';

class ScheduleIntentionNotificationsUseCase {
  ScheduleIntentionNotificationsUseCase(this._scheduler, this._repository);

  final NotificationSchedulerRepository _scheduler;
  final SpiritualEntryRepository _repository;

  Future<void> call({String? intentionId, NotificationBudget? budget}) async {
    if (intentionId != null) {
      final entry = await _getEntry(intentionId);
      if (entry != null) {
        await _scheduleForEntry(entry, budget: budget);
      }
    } else {
      final entries = await _repository.listLocal();
      for (final entry in entries) {
        await _scheduleForEntry(entry, budget: budget);
      }
    }
  }

  Future<void> _scheduleForEntry(
    SpiritualEntry entry, {
    NotificationBudget? budget,
  }) async {
    if (entry.respondedAt != null) return;

    final schedule = _parseSchedule(entry.scheduleJson);
    if (schedule == null || schedule.times.isEmpty) return;

    for (var i = 0; i < schedule.times.length && i < 10; i++) {
      final id = _deriveId(entry.id, i);
      await _scheduler.cancelById(id);
    }

    final now = DateTime.now();
    for (var i = 0; i < schedule.times.length && i < 10; i++) {
      final timeStr = schedule.times[i];
      final timeParts = timeStr.split(':');
      if (timeParts.length < 2) continue;

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      final nextOccurrence = _calculateNextOccurrence(
        schedule,
        hour,
        minute,
        now,
      );
      if (nextOccurrence == null) continue;

      // Stop once the shared notification budget is spent — prayer intentions
      // are user-set promises and rank above quotes, but still must not push the
      // app past the iOS 64-pending cap (where excess is silently dropped).
      if (budget != null && !budget.tryConsume()) return;

      final id = _deriveId(entry.id, i);
      await _scheduler.scheduleWithId(
        id,
        ReminderEvent(
          type: ReminderEventType.prayerIntentionReminder,
          title: entry.title ?? 'Intenção de oração',
          body: entry.body.isNotEmpty ? entry.body : 'Reze por esta intenção.',
          scheduledAt: nextOccurrence,
          withVibration: true,
          isAlarm: false,
          repeatDaily: schedule.type == IntentionScheduleType.daily,
          routeTarget: NotificationRouteTarget.prayerIntention,
          scheduledId: id,
          intentionId: entry.id,
        ),
      );
    }
  }

  Future<SpiritualEntry?> _getEntry(String id) async {
    final entries = await _repository.listLocal(includeDeleted: true);
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  IntentionSchedule? _parseSchedule(String? scheduleJson) {
    if (scheduleJson == null || scheduleJson.isEmpty) return null;
    try {
      final map = jsonDecode(scheduleJson) as Map<String, dynamic>;

      if (map.containsKey('reminderTime') && !map.containsKey('type')) {
        return IntentionSchedule(
          type: IntentionScheduleType.daily,
          times: [map['reminderTime'] as String],
        );
      }
      return IntentionSchedule.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  int _deriveId(String intentionId, int timeIndex) {
    final baseId = intentionId.hashCode.abs();
    return 500000 + (baseId % 499000) + timeIndex;
  }

  DateTime? _calculateNextOccurrence(
    IntentionSchedule schedule,
    int hour,
    int minute,
    DateTime now,
  ) {
    switch (schedule.type) {
      case IntentionScheduleType.daily:
        var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
        return scheduled;

      case IntentionScheduleType.weekly:
        if (schedule.daysOfWeek.isEmpty) return null;
        var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
        while (!schedule.daysOfWeek.contains(scheduled.weekday) ||
            scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
        return scheduled;

      case IntentionScheduleType.specificDates:
        final dates = schedule.specificDates
            .map((d) => DateTime.tryParse(d))
            .whereType<DateTime>()
            .map((d) => DateTime(d.year, d.month, d.day, hour, minute))
            .where((d) => d.isAfter(now))
            .toList();
        if (dates.isEmpty) return null;
        dates.sort();
        return dates.first;
    }
  }
}
