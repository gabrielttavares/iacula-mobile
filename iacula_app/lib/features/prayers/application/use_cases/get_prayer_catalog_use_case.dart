import '../../domain/entities/prayer_catalog_entry.dart';
import '../../domain/repositories/prayer_catalog_repository.dart';

final class GetPrayerCatalogUseCase {
  const GetPrayerCatalogUseCase({required PrayerCatalogRepository repository})
    : _repository = repository;

  final PrayerCatalogRepository _repository;

  Future<List<PrayerCatalogEntry>> listAll({required String language}) {
    return _repository.listCatalog(language: language);
  }

  Future<List<PrayerCatalogEntry>> byTheme({
    required String language,
    required String theme,
  }) async {
    final catalog = await listAll(language: language);
    return catalog
        .where((entry) => entry.themes.contains(theme))
        .toList(growable: false);
  }

  Future<List<PrayerCatalogEntry>> bySaint({
    required String language,
    required String saint,
  }) async {
    final catalog = await listAll(language: language);
    return catalog
        .where((entry) => entry.saints.contains(saint))
        .toList(growable: false);
  }
}
