import '../../../../features/notifications/domain/entities/reminder_event.dart';
import '../../../../features/notifications/domain/repositories/notification_scheduler_repository.dart';
import '../../../../features/notifications/domain/services/active_window.dart';
import '../../../../features/notifications/domain/services/notification_budget.dart';
import '../../../../features/settings/domain/entities/settings.dart';
import '../../domain/entities/custom_phrase.dart';
import '../../domain/entities/phrase_schedule.dart';
import '../../domain/repositories/custom_phrase_repository.dart';

class SchedulePhraseNotificationsUseCase {
  SchedulePhraseNotificationsUseCase(this._scheduler, this._repository);

  final NotificationSchedulerRepository _scheduler;
  final CustomPhraseRepository _repository;

  Future<void> call({
    String? phraseId,
    Settings? settings,
    NotificationBudget? budget,
  }) async {
    if (phraseId != null) {
      final phrase = await _repository.getById(phraseId);
      if (phrase != null) {
        await _scheduleForPhrase(phrase, settings: settings, budget: budget);
      }
    } else {
      final phrases = await _repository.listAll();
      for (final phrase in phrases) {
        await _scheduleForPhrase(phrase, settings: settings, budget: budget);
      }
    }
  }

  Future<void> _scheduleForPhrase(
    CustomPhrase phrase, {
    Settings? settings,
    NotificationBudget? budget,
  }) async {
    // 1. Cancel existing notifications for this phrase (IDs 1000-1999)
    for (var i = 0; i < 10; i++) {
      final id = _deriveId(phrase.id, i);
      await _scheduler.cancelById(id);
    }

    if (!phrase.isActive || !phrase.displayAsNotification || !phrase.useFixedSchedule) return;

    // 2. Schedule new notifications
    final now = DateTime.now();
    for (var i = 0; i < phrase.schedule.times.length && i < 10; i++) {
      final timeStr = phrase.schedule.times[i];
      final timeParts = timeStr.split(':');
      if (timeParts.length < 2) continue;

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      final nextOccurrence = _calculateNextOccurrence(
        phrase.schedule,
        hour,
        minute,
        now,
      );
      if (nextOccurrence == null) continue;
      // Personal phrases honor the same active window as quotes: a fire time
      // outside the window is skipped. Prayer alarms are exact user-set times
      // and are never suppressed (a promise is kept regardless of the window).
      if (settings != null && !phrase.isPrayerAlarm) {
        final effectiveWindow = ActiveWindow.fromQuietHours(
          quietStart: settings.quietHoursStart,
          quietEnd: settings.quietHoursEnd,
        );
        if (!effectiveWindow.allows(nextOccurrence)) continue;
      }

      // Stop once the shared notification budget is spent — do not push the app
      // past the iOS 64-pending cap (where excess is silently dropped).
      if (budget != null && !budget.tryConsume()) return;

      final id = _deriveId(phrase.id, i);
      final isPrayerAlarm = phrase.isPrayerAlarm;
      await _scheduler.scheduleWithId(
        id,
        ReminderEvent(
          type: ReminderEventType.customPhrase,
          title: isPrayerAlarm ? (phrase.prayerTitle ?? phrase.text) : 'Frase Pessoal',
          body: isPrayerAlarm ? 'Hora de rezar' : phrase.text,
          scheduledAt: nextOccurrence,
          withVibration: true,
          isAlarm: isPrayerAlarm,
          repeatDaily: phrase.schedule.type != PhraseScheduleType.specificDates,
          routeTarget: isPrayerAlarm
              ? NotificationRouteTarget.prayer
              : NotificationRouteTarget.home,
          prayerSlug: isPrayerAlarm ? phrase.prayerSlug : null,
        ),
      );
    }
  }

  int _deriveId(String phraseId, int timeIndex) {
    // ID space: 1000-1999 (1000 slots). With 10 time slots per phrase,
    // we support up to 100 unique phrases: phraseHash % 100 * 10 + timeIndex.
    return 1000 + (phraseId.hashCode.abs() % 100) * 10 + timeIndex;
  }

  DateTime? _calculateNextOccurrence(
    PhraseSchedule schedule,
    int hour,
    int minute,
    DateTime now,
  ) {
    switch (schedule.type) {
      case PhraseScheduleType.daily:
        var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
        return scheduled;

      case PhraseScheduleType.weekly:
        if (schedule.daysOfWeek.isEmpty) return null;
        var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
        while (!schedule.daysOfWeek.contains(scheduled.weekday) ||
            scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
        return scheduled;

      case PhraseScheduleType.specificDates:
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
