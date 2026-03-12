import 'package:isar/isar.dart';

part 'examination_reflection_doc.g.dart';

@collection
class ExaminationReflectionDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String reflectionId;

  late String sectionTitle;
  late String text;
  late int sortOrder;
  late DateTime createdAt;
  late DateTime updatedAt;
}
