import 'package:isar/isar.dart';

part 'reading_bookmark_doc.g.dart';

@collection
class ReadingBookmarkDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String documentId;

  late String blockId;
  int? startOffset;
  String? label;
  late DateTime updatedAt;
}
