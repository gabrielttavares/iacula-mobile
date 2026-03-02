final class StreakInfo {
  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.todayMinutes,
    required this.hasPrayedToday,
  });

  static const empty = StreakInfo(
    currentStreak: 0,
    longestStreak: 0,
    todayMinutes: 0,
    hasPrayedToday: false,
  );

  final int currentStreak;
  final int longestStreak;
  final int todayMinutes;
  final bool hasPrayedToday;
}
