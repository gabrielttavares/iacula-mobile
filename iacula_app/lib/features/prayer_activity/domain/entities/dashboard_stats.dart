final class DashboardStats {
  const DashboardStats({
    required this.totalPrayers,
    required this.totalMeditations,
    required this.totalExaminations,
    required this.totalRosaries,
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyGoalMinutes,
    required this.activityByDate,
  });

  static const empty = DashboardStats(
    totalPrayers: 0,
    totalMeditations: 0,
    totalExaminations: 0,
    totalRosaries: 0,
    totalMinutes: 0,
    currentStreak: 0,
    longestStreak: 0,
    dailyGoalMinutes: 10,
    activityByDate: {},
  );

  final int totalPrayers;
  final int totalMeditations;
  final int totalExaminations;
  final int totalRosaries;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final int dailyGoalMinutes;
  final Map<String, int> activityByDate; // "YYYY-MM-DD" -> minutes
}
