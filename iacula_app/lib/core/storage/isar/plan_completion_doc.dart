import 'package:isar/isar.dart';

part 'plan_completion_doc.g.dart';

@collection
class PlanCompletionDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String completionId; // format: "itemId_YYYY-MM-DD"

  @Index()
  late String itemId;

  @Index()
  late String date; // format: "YYYY-MM-DD"

  late DateTime completedAt;
}
