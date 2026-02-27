import '../entities/prayer_collection.dart';
import '../entities/prayer_detail.dart';

abstract interface class PrayerContentRepository {
  Future<PrayerCollection> loadPrayers({required String language});
  Future<PrayerDetail> loadPrayerDetail({required String slug});
  Future<String?> getAngelusImagePath();
  Future<String?> getReginaCaeliImagePath();
}
