// lib/features/prayer_intentions/domain/entities/prayer_intention.dart

import 'intention_schedule.dart';

final class PrayerIntention {
  const PrayerIntention({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description,
    this.respondedAt,
    this.schedule,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final IntentionSchedule? schedule;

  @Deprecated('Use schedule instead. Kept for migration.')
  String? get reminderTime =>
      schedule?.times.isNotEmpty == true ? schedule!.times.first : null;

  bool get isResponded => respondedAt != null;
  bool get hasReminder => schedule != null && schedule!.times.isNotEmpty;

  PrayerIntention copyWith({
    String? title,
    String? description,
    DateTime? respondedAt,
    IntentionSchedule? schedule,
    bool clearRespondedAt = false,
    bool clearSchedule = false,
  }) {
    return PrayerIntention(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      respondedAt: clearRespondedAt ? null : (respondedAt ?? this.respondedAt),
      schedule: clearSchedule ? null : (schedule ?? this.schedule),
    );
  }
}
