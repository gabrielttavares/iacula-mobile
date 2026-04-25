final class FavoriteItem {
  const FavoriteItem({
    required this.id,
    required this.quoteText,
    required this.theme,
    required this.season,
    required this.savedAt,
    this.imagePath,
    this.feastName,
    this.prayerSlug,
    this.referenceLabel,
  });

  final String id;
  final String quoteText;
  final String theme;
  final String season;
  final DateTime savedAt;
  final String? imagePath;
  final String? feastName;
  final String? prayerSlug;
  final String? referenceLabel;

  /// Deduplication key based on content.
  String get contentKey => quoteText.hashCode.toRadixString(36);
}
