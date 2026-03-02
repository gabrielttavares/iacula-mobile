import 'package:isar/isar.dart';

import '../../../../core/storage/isar/isar_store.dart';
import '../../../../core/storage/isar/prayer_activity_doc.dart';
import '../../domain/entities/prayer_activity_entry.dart';
import '../../domain/repositories/prayer_activity_repository.dart';

final class IsarPrayerActivityRepository implements PrayerActivityRepository {
  IsarPrayerActivityRepository({required this.store});

  final IsarStore store;

  @override
  Future<void> save(PrayerActivityEntry entry) async {
    final isar = await store.isar;
    final doc = PrayerActivityDoc()
      ..activityId = entry.id
      ..date = _formatDate(entry.date)
      ..durationSeconds = entry.durationSeconds
      ..activityType = PrayerActivityTypeDoc.values.byName(entry.activityType.name)
      ..featureSlug = entry.featureSlug
      ..createdAt = entry.createdAt;

    await isar.writeTxn(() => isar.prayerActivityDocs.put(doc));
  }

  @override
  Future<List<PrayerActivityEntry>> listAll() async {
    final isar = await store.isar;
    final docs = await isar.prayerActivityDocs
        .where()
        .sortByCreatedAtDesc()
        .findAll();
    return docs.map(_toEntry).toList();
  }

  @override
  Future<List<PrayerActivityEntry>> listByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final isar = await store.isar;
    final startStr = _formatDate(start);
    final endStr = _formatDate(end);
    final docs = await isar.prayerActivityDocs
        .filter()
        .dateGreaterThan(startStr, include: true)
        .dateLessThan(endStr, include: true)
        .findAll();
    return docs.map(_toEntry).toList();
  }

  @override
  Future<int> totalMinutesForDate(DateTime date) async {
    final dateStr = _formatDate(date);
    final isar = await store.isar;
    final docs = await isar.prayerActivityDocs
        .where()
        .dateEqualTo(dateStr)
        .findAll();
    final totalSeconds = docs.fold<int>(0, (sum, d) => sum + d.durationSeconds);
    return (totalSeconds / 60).ceil();
  }

  @override
  Future<Map<String, int>> minutesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final entries = await listByDateRange(start, end);
    final result = <String, int>{};
    for (final entry in entries) {
      final key = _formatDate(entry.date);
      result[key] = (result[key] ?? 0) + (entry.durationSeconds / 60).ceil();
    }
    return result;
  }

  PrayerActivityEntry _toEntry(PrayerActivityDoc doc) {
    return PrayerActivityEntry(
      id: doc.activityId,
      date: DateTime.parse(doc.date),
      durationSeconds: doc.durationSeconds,
      activityType: PrayerActivityType.values.byName(doc.activityType.name),
      featureSlug: doc.featureSlug,
      createdAt: doc.createdAt,
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
