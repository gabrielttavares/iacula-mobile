import 'package:isar/isar.dart';

part 'examination_entry_doc.g.dart';

@collection
class ExaminationEntryDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String entryId;

  @Index()
  String? userId;

  String? title;
  late String body;
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  late bool isDirty;
  DateTime? lastSyncedAt;
}
