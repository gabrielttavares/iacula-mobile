import 'package:isar/isar.dart';

part 'favorite_item_doc.g.dart';

@collection
class FavoriteItemDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String favoriteId;

  @Index()
  String? userId;

  late String quoteText;
  late String theme;
  late String season;
  late DateTime savedAt;
  String? imagePath;
  String? feastName;
  String? prayerSlug;
  String? referenceLabel;

  // Sync-ready fields
  late bool isDirty;
  DateTime? lastSyncedAt;
  DateTime? deletedAt;
}
