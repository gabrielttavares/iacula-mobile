import '../entities/prayer_catalog_entry.dart';

abstract interface class PrayerCatalogRepository {
  Future<List<PrayerCatalogEntry>> listCatalog({required String language});
}
