final class PrayerCatalogEntry {
  const PrayerCatalogEntry({
    required this.slug,
    required this.title,
    required this.content,
    required this.themes,
    required this.saints,
    this.sectionId = '',
    this.sectionTitle = '',
    this.availableLanguages = const <String>['pt-br'],
  });

  final String slug;
  final String title;
  final String content;
  final List<String> themes;
  final List<String> saints;
  final String sectionId;
  final String sectionTitle;
  final List<String> availableLanguages;
}
