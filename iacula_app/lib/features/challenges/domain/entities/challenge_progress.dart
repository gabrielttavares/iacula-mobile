final class ChallengeProgress {
  const ChallengeProgress({
    required this.challengeId,
    required this.startDate,
    required this.completedDays,
    this.isCompleted = false,
    this.completedAt,
  });

  final String challengeId;
  final DateTime startDate;
  final List<int> completedDays;
  final bool isCompleted;
  final DateTime? completedAt;

  int get currentDay {
    final daysSinceStart =
        DateTime.now().difference(startDate).inDays + 1;
    return daysSinceStart;
  }

  bool isDayCompleted(int day) => completedDays.contains(day);

  ChallengeProgress copyWith({
    List<int>? completedDays,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ChallengeProgress(
      challengeId: challengeId,
      startDate: startDate,
      completedDays: completedDays ?? this.completedDays,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
