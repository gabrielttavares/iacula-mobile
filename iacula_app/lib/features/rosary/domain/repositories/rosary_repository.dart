import '../entities/rosary_mystery_set.dart';

abstract interface class RosaryRepository {
  Future<List<RosaryMysterySet>> listAll();
  Future<RosaryMysterySet?> getMysterySet(RosaryMysteryType type);
}
