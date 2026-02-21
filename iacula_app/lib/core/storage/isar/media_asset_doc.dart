import 'package:isar/isar.dart';

part 'media_asset_doc.g.dart';

@collection
class MediaAssetDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String assetPath;

  late String type;
  String? season;
  int? dayOfWeek;
  String? language;
}
