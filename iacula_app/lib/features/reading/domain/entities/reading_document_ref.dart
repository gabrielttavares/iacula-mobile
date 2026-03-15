import 'reading_text_block.dart';

final class ReadingDocumentRef {
  const ReadingDocumentRef({
    required this.id,
    required this.blocks,
  });

  final String id;
  final List<ReadingTextBlock> blocks;
}
