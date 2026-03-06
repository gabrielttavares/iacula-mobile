final class SaintOfDay {
  const SaintOfDay({
    required this.date,
    required this.name,
    required this.biographyParagraphs,
    this.remoteImageUrl,
    this.localImagePath,
    this.imageAssetPath,
  });

  final DateTime date;
  final String name;
  final List<String> biographyParagraphs;
  final String? remoteImageUrl;
  final String? localImagePath;
  final String? imageAssetPath;

  SaintOfDay copyWith({
    DateTime? date,
    String? name,
    List<String>? biographyParagraphs,
    String? remoteImageUrl,
    String? localImagePath,
    String? imageAssetPath,
  }) {
    return SaintOfDay(
      date: date ?? this.date,
      name: name ?? this.name,
      biographyParagraphs: biographyParagraphs ?? this.biographyParagraphs,
      remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
    );
  }
}
