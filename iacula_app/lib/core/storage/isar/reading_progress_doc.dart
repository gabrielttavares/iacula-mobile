import 'package:isar/isar.dart';

part 'reading_progress_doc.g.dart';

@collection
class ReadingProgressDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String documentId;

  late String blockId;
  int? startOffset;
  late DateTime updatedAt;
}
