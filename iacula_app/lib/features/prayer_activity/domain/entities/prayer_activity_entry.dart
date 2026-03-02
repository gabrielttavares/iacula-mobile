enum PrayerActivityType {
  prayer,
  meditation,
  examination,
  rosary,
  challenge,
  nightPrayer,
  liturgyOfHours,
  journal,
}

final class PrayerActivityEntry {
  const PrayerActivityEntry({
    required this.id,
    required this.date,
    required this.durationSeconds,
    required this.activityType,
    required this.createdAt,
    this.featureSlug,
  });

  final String id;
  final DateTime date;
  final int durationSeconds;
  final PrayerActivityType activityType;
  final String? featureSlug;
  final DateTime createdAt;
}
