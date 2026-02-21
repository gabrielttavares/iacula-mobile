final class MediaAsset {
  const MediaAsset({
    required this.assetPath,
    required this.type,
    this.season,
    this.dayOfWeek,
    this.language,
  });

  final String assetPath;
  final String type;
  final String? season;
  final int? dayOfWeek;
  final String? language;
}
