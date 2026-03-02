import 'package:isar/isar.dart';

part 'custom_phrase_doc.g.dart';

@collection
class CustomPhraseDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String phraseId;

  late String text;
  late bool isActive;
  late bool displayOnHero;
  late bool displayAsNotification;
  late String scheduleJson;
  late DateTime createdAt;
  late DateTime updatedAt;
}
