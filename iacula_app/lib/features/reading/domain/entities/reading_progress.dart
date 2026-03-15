final class ReadingProgress {
  const ReadingProgress({
    required this.documentId,
    required this.blockId,
    required this.updatedAt,
    this.startOffset,
  });

  final String documentId;
  final String blockId;
  final int? startOffset;
  final DateTime updatedAt;
}
