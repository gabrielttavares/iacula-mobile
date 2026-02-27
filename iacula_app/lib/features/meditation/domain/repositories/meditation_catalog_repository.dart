import '../entities/meditation_item.dart';

abstract interface class MeditationCatalogRepository {
  Future<List<MeditationItem>> listAll();

  Future<List<MeditationItem>> listByCategory(String category);

  Future<List<MeditationItem>> listByType(MeditationType type);

  Future<MeditationItem?> getById(String id);
}
