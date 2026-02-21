import '../entities/prayer_collection.dart';

abstract interface class PrayerContentRepository {
  Future<PrayerCollection> loadPrayers({required String language});
  Future<String?> getAngelusImagePath();
  Future<String?> getReginaCaeliImagePath();
}
