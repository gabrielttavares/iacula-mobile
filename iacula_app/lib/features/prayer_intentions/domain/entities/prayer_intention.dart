// lib/features/prayer_intentions/domain/entities/prayer_intention.dart

final class PrayerIntention {
  const PrayerIntention({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description,
    this.respondedAt,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? respondedAt;

  bool get isResponded => respondedAt != null;

  PrayerIntention copyWith({
    String? title,
    String? description,
    DateTime? respondedAt,
    bool clearRespondedAt = false,
  }) {
    return PrayerIntention(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      respondedAt: clearRespondedAt ? null : (respondedAt ?? this.respondedAt),
    );
  }
}
