import '../entities/prayer_activity_entry.dart';

abstract interface class PrayerActivityRepository {
  Future<void> save(PrayerActivityEntry entry);
  Future<List<PrayerActivityEntry>> listAll();
  Future<List<PrayerActivityEntry>> listByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<int> totalMinutesForDate(DateTime date);
  Future<Map<String, int>> minutesByDateRange(DateTime start, DateTime end);
}
