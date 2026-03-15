import 'package:isar/isar.dart';

part 'reading_highlight_doc.g.dart';

@collection
class ReadingHighlightDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String highlightId;

  @Index()
  late String documentId;

  late String blockId;
  late int startOffset;
  late int endOffset;
  late String colorKey;
  late DateTime createdAt;
}
