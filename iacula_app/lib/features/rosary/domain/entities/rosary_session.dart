import 'rosary_mystery_set.dart';

final class RosarySession {
  RosarySession({
    required this.mysterySetType,
    this.currentDecade = 0,
    this.currentBead = 0,
    DateTime? startedAt,
    this.completedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  final RosaryMysteryType mysterySetType;
  final int currentDecade;
  final int currentBead;
  final DateTime startedAt;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;
  int get totalBeads => 5 * 10; // 5 decades x 10 Hail Marys

  RosarySession copyWith({
    int? currentDecade,
    int? currentBead,
    DateTime? completedAt,
  }) {
    return RosarySession(
      mysterySetType: mysterySetType,
      currentDecade: currentDecade ?? this.currentDecade,
      currentBead: currentBead ?? this.currentBead,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
