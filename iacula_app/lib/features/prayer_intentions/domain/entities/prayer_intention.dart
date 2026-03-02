// lib/features/prayer_intentions/domain/entities/prayer_intention.dart

final class PrayerIntention {
  const PrayerIntention({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description,
    this.respondedAt,
    this.reminderTime,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? respondedAt;
  /// Daily reminder time in "HH:mm" format, e.g. "09:00".
  final String? reminderTime;

  bool get isResponded => respondedAt != null;

  PrayerIntention copyWith({
    String? title,
    String? description,
    DateTime? respondedAt,
    String? reminderTime,
    bool clearRespondedAt = false,
  }) {
    return PrayerIntention(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      respondedAt: clearRespondedAt ? null : (respondedAt ?? this.respondedAt),
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
