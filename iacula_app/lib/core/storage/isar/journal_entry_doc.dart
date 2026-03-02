import 'package:isar/isar.dart';

part 'journal_entry_doc.g.dart';

@collection
class JournalEntryDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String entryId;

  String? userId;

  String? title;

  late String body;

  late String tagsJson; // JSON array of strings

  String? mood; // "consolation", "desolation", "neutral", or null

  String? liturgicalSeason;

  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;

  late bool isDirty;
  DateTime? lastSyncedAt;
}
