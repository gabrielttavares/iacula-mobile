final class PrayerDetail {
  const PrayerDetail({
    required this.slug,
    required this.titlesByLanguage,
    required this.blocksByLanguage,
    required this.defaultLanguage,
  });

  final String slug;
  final Map<String, String> titlesByLanguage;
  final Map<String, List<String>> blocksByLanguage;
  final String defaultLanguage;
}
