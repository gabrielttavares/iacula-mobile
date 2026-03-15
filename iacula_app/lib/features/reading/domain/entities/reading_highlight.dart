final class ReadingHighlight {
  const ReadingHighlight({
    required this.id,
    required this.documentId,
    required this.blockId,
    required this.startOffset,
    required this.endOffset,
    required this.colorKey,
    required this.createdAt,
  });

  final String id;
  final String documentId;
  final String blockId;
  final int startOffset;
  final int endOffset;
  final String colorKey;
  final DateTime createdAt;
}
