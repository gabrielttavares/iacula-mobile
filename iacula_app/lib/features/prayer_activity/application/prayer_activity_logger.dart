import 'package:uuid/uuid.dart';

import '../domain/entities/prayer_activity_entry.dart';
import '../domain/repositories/prayer_activity_repository.dart';

final class PrayerActivityLogger {
  PrayerActivityLogger({required this.repository});

  final PrayerActivityRepository repository;

  Future<void> logActivity({
    required PrayerActivityType type,
    required int durationSeconds,
    String? featureSlug,
  }) async {
    final now = DateTime.now();
    final entry = PrayerActivityEntry(
      id: const Uuid().v4(),
      date: DateTime(now.year, now.month, now.day),
      durationSeconds: durationSeconds,
      activityType: type,
      featureSlug: featureSlug,
      createdAt: now,
    );
    await repository.save(entry);
  }
}
