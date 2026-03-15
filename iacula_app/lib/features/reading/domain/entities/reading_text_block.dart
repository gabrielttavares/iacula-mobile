enum ReadingTextBlockType { title, heading, paragraph, summary }

final class ReadingTextBlock {
  const ReadingTextBlock({
    required this.id,
    required this.text,
    required this.type,
  });

  final String id;
  final String text;
  final ReadingTextBlockType type;
}
