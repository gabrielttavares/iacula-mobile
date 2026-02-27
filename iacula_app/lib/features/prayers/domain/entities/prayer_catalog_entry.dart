final class PrayerCatalogEntry {
  const PrayerCatalogEntry({
    required this.slug,
    required this.title,
    required this.theme,
    required this.saint,
  });

  final String slug;
  final String title;
  final String theme;
  final String? saint;
}
