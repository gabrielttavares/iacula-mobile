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

  Future<List<PrayerCatalogEntry>> bySection({
    required String language,
    required String sectionId,
  }) async {
    final catalog = await listAll(language: language);
    return catalog
        .where((entry) => entry.sectionId == sectionId)
        .toList(growable: false);
  }

  Future<PrayerCatalogEntry?> suggestionOfDay({
    required String language,
    required DateTime date,
  }) async {
    final catalog = await listAll(language: language);
    if (catalog.isEmpty) return null;

    final slug = _suggestionSlugForDate(date);
    try {
      return catalog.firstWhere((e) => e.slug == slug);
    } on StateError {
      return null;
    }
  }

  static String _suggestionSlugForDate(DateTime date) {
    // 3rd Sunday of the month takes priority
    if (date.weekday == DateTime.sunday) {
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final firstSunday = firstDayOfMonth.add(
        Duration(days: (DateTime.sunday - firstDayOfMonth.weekday + 7) % 7),
      );
      final sundayIndex = ((date.day - firstSunday.day) ~/ 7) + 1;
      if (sundayIndex == 3) {
        return 'simbolo-atanasiano';
      }
    }

    return switch (date.weekday) {
      DateTime.tuesday => 'salmo-2',
      DateTime.thursday => 'adoro-te-devote',
      _ => 'cântico-dos-três-jovens',
    };
  }

  Future<PrayerCatalogEntry?> getBySlug({
    required String language,
    required String slug,
  }) async {
    final catalog = await listAll(language: language);
    try {
      return catalog.firstWhere((e) => e.slug == slug);
    } on StateError {
      return null;
    }
  }
}
