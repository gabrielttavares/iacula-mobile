final class ReadingBookmark {
  const ReadingBookmark({
    required this.documentId,
    required this.blockId,
    required this.updatedAt,
    this.startOffset,
    this.label,
  });

  final String documentId;
  final String blockId;
  final int? startOffset;
  final String? label;
  final DateTime updatedAt;
}
