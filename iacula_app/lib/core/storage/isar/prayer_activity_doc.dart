import 'package:isar/isar.dart';

part 'prayer_activity_doc.g.dart';

@collection
class PrayerActivityDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String activityId;

  @Index()
  late String date; // "YYYY-MM-DD"

  late int durationSeconds;

  @Enumerated(EnumType.name)
  late PrayerActivityTypeDoc activityType;

  String? featureSlug;

  late DateTime createdAt;
}

enum PrayerActivityTypeDoc {
  prayer,
  meditation,
  examination,
  rosary,
  challenge,
  nightPrayer,
  liturgyOfHours,
  journal,
}
