import 'package:isar/isar.dart';

part 'plan_of_life_entry_doc.g.dart';

@collection
class PlanOfLifeEntryDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String entryId;

  @Index()
  String? userId;

  String? title;
  late String body;
  String? scheduleJson;
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  late bool isDirty;
  DateTime? lastSyncedAt;
}
