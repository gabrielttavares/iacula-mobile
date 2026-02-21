final class ScheduleResult {
  const ScheduleResult({required this.nextTriggerTime, required this.delay});

  final DateTime nextTriggerTime;
  final Duration delay;
}

final class PrayerScheduler {
  const PrayerScheduler._();

  static ScheduleResult calculateNextNoon(DateTime now) {
    var next = DateTime(now.year, now.month, now.day, 12);
    if (!now.isBefore(next)) {
      next = next.add(const Duration(days: 1));
    }

    return ScheduleResult(nextTriggerTime: next, delay: next.difference(now));
  }

  static bool isNoonWindow(DateTime now) {
    return now.hour == 12 && now.minute <= 1;
  }

  static const Duration dailyInterval = Duration(days: 1);
}
