final class PrayerCatalogEntry {
  const PrayerCatalogEntry({
    required this.slug,
    required this.title,
    required this.content,
    required this.themes,
    required this.saints,
  });

  final String slug;
  final String title;
  final String content;
  final List<String> themes;
  final List<String> saints;
}
