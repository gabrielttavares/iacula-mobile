import '../entities/challenge.dart';

abstract interface class ChallengeRepository {
  Future<List<Challenge>> listAll();
  Future<Challenge?> getById(String id);
}
