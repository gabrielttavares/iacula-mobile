import '../domain/entities/prayer_activity_entry.dart';
import '../domain/entities/streak_info.dart';
import '../domain/entities/dashboard_stats.dart';

final class StreakCalculator {
  const StreakCalculator();

  StreakInfo computeStreak(List<PrayerActivityEntry> entries) {
    if (entries.isEmpty) return StreakInfo.empty;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Group by date
    final byDate = <String, int>{};
    for (final e in entries) {
      final key = _formatDate(e.date);
      byDate[key] = (byDate[key] ?? 0) + e.durationSeconds;
    }

    final todayKey = _formatDate(today);
    final todaySeconds = byDate[todayKey] ?? 0;
    final todayMinutes = (todaySeconds / 60).ceil();
    final hasPrayedToday = todaySeconds > 0;

    // Compute current streak
    int currentStreak = 0;
    var checkDate = hasPrayedToday ? today : today.subtract(const Duration(days: 1));

    while (byDate.containsKey(_formatDate(checkDate))) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Compute longest streak
    final sortedDates = byDate.keys.toList()..sort();
    int longestStreak = 0;
    int runLength = 0;
    DateTime? prevDate;

    for (final dateStr in sortedDates) {
      final date = DateTime.parse(dateStr);
      if (prevDate != null && date.difference(prevDate).inDays == 1) {
        runLength++;
      } else {
        runLength = 1;
      }
      if (runLength > longestStreak) longestStreak = runLength;
      prevDate = date;
    }

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      todayMinutes: todayMinutes,
      hasPrayedToday: hasPrayedToday,
    );
  }

  DashboardStats computeDashboard(
    List<PrayerActivityEntry> entries, {
    int dailyGoalMinutes = 10,
  }) {
    final streak = computeStreak(entries);

    int totalPrayers = 0;
    int totalMeditations = 0;
    int totalExaminations = 0;
    int totalRosaries = 0;
    int totalSeconds = 0;
    final activityByDate = <String, int>{};

    for (final e in entries) {
      switch (e.activityType) {
        case PrayerActivityType.prayer:
          totalPrayers++;
        case PrayerActivityType.meditation:
          totalMeditations++;
        case PrayerActivityType.examination:
          totalExaminations++;
        case PrayerActivityType.rosary:
          totalRosaries++;
        case PrayerActivityType.challenge:
        case PrayerActivityType.nightPrayer:
        case PrayerActivityType.liturgyOfHours:
        case PrayerActivityType.journal:
          totalPrayers++;
      }
      totalSeconds += e.durationSeconds;
      final key = _formatDate(e.date);
      activityByDate[key] =
          (activityByDate[key] ?? 0) + (e.durationSeconds / 60).ceil();
    }

    return DashboardStats(
      totalPrayers: totalPrayers,
      totalMeditations: totalMeditations,
      totalExaminations: totalExaminations,
      totalRosaries: totalRosaries,
      totalMinutes: (totalSeconds / 60).ceil(),
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      dailyGoalMinutes: dailyGoalMinutes,
      activityByDate: activityByDate,
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
