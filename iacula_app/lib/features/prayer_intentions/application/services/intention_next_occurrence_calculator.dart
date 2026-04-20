import '../../domain/entities/intention_schedule.dart';

final class IntentionNextOccurrenceCalculator {
  IntentionNextOccurrenceCalculator._();

  static List<DateTime> nextOccurrences({
    required IntentionSchedule schedule,
    required DateTime now,
    int maxOccurrences = 10,
  }) {
    if (schedule.times.isEmpty) return [];

    final results = <DateTime>[];

    switch (schedule.type) {
      case IntentionScheduleType.daily:
        for (final time in schedule.times) {
          final next = _nextDailyTime(now, time);
          _insertSorted(results, next);
        }
        break;

      case IntentionScheduleType.weekly:
        if (schedule.daysOfWeek.isEmpty) break;
        for (final day in schedule.daysOfWeek) {
          for (final time in schedule.times) {
            final next = _nextWeeklyDayTime(now, day, time);
            _insertSorted(results, next);
          }
        }
        break;

      case IntentionScheduleType.specificDates:
        if (schedule.specificDates.isEmpty) break;
        for (final date in schedule.specificDates) {
          for (final time in schedule.times) {
            final next = _nextSpecificDateTime(now, date, time);
            if (next != null) _insertSorted(results, next);
          }
        }
        break;
    }

    return results.take(maxOccurrences).toList();
  }

  static DateTime _nextDailyTime(DateTime now, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) {
      return now.add(const Duration(days: 1));
    }

    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;

    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    return next;
  }

  static DateTime _nextWeeklyDayTime(DateTime now, int dayOfWeek, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) {
      return now.add(const Duration(days: 7));
    }

    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;

    final currentDay = now.weekday;
    final daysUntil = (dayOfWeek - currentDay + 7) % 7;

    var next = DateTime(now.year, now.month, now.day + daysUntil, hour, minute);

    if (daysUntil == 0 && !next.isAfter(now)) {
      next = next.add(const Duration(days: 7));
    }

    return next;
  }

  static DateTime? _nextSpecificDateTime(
    DateTime now,
    String dateStr,
    String hhmm,
  ) {
    final dateParts = dateStr.split('-');
    if (dateParts.length < 3) return null;

    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    if (year == null || month == null || day == null) return null;

    final timeParts = hhmm.split(':');
    if (timeParts.length != 2) return null;

    final hour = int.tryParse(timeParts[0]) ?? 9;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    final next = DateTime(year, month, day, hour, minute);
    return next.isAfter(now) ? next : null;
  }

  static void _insertSorted(List<DateTime> list, DateTime value) {
    int index = list.length;
    for (int i = 0; i < list.length; i++) {
      if (value.isBefore(list[i])) {
        index = i;
        break;
      }
    }
    list.insert(index, value);
  }
}
