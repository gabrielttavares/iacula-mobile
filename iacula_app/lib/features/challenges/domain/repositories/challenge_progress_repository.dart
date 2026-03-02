import '../entities/challenge_progress.dart';

abstract interface class ChallengeProgressRepository {
  Future<ChallengeProgress?> getProgress(String challengeId);
  Future<void> saveProgress(ChallengeProgress progress);
  Future<List<ChallengeProgress>> listActive();
  Future<void> deleteProgress(String challengeId);
}
