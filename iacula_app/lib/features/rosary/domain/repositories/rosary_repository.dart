import '../entities/rosary_mystery_set.dart';
import '../entities/rosary_final_prayers.dart';
import '../entities/rosary_initial_prayers.dart';

abstract interface class RosaryRepository {
  Future<List<RosaryMysterySet>> listAll();
  Future<RosaryMysterySet?> getMysterySet(RosaryMysteryType type);
  Future<RosaryCompletionPrayers> getCompletionPrayers({
    required String language,
  });
  Future<RosaryInitialPrayers> getInitialPrayers({
    required String language,
  });
}
