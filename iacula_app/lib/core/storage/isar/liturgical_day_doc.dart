import 'package:isar/isar.dart';

part 'liturgical_day_doc.g.dart';

@collection
class LiturgicalDayDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String dateKey;

  late String season;
}
