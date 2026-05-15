import 'phrase_schedule.dart';

const _absent = Object();

final class CustomPhrase {
  const CustomPhrase({
    required this.id,
    required this.text,
    this.isActive = true,
    this.displayOnHero = true,
    this.displayAsNotification = true,
    this.useFixedSchedule = false,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
    this.prayerSlug,
    this.prayerTitle,
  });

  final String id; // UUID
  final String text; // 5–300 chars
  final bool isActive;
  final bool displayOnHero;
  final bool displayAsNotification;
  final bool useFixedSchedule;
  final PhraseSchedule schedule;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? prayerSlug;
  final String? prayerTitle;

  bool get isRotationMode => !useFixedSchedule;
  bool get isPrayerAlarm => prayerSlug != null;

  CustomPhrase copyWith({
    String? id,
    String? text,
    bool? isActive,
    bool? displayOnHero,
    bool? displayAsNotification,
    bool? useFixedSchedule,
    PhraseSchedule? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? prayerSlug = _absent,
    Object? prayerTitle = _absent,
  }) {
    return CustomPhrase(
      id: id ?? this.id,
      text: text ?? this.text,
      isActive: isActive ?? this.isActive,
      displayOnHero: displayOnHero ?? this.displayOnHero,
      displayAsNotification: displayAsNotification ?? this.displayAsNotification,
      useFixedSchedule: useFixedSchedule ?? this.useFixedSchedule,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      prayerSlug: prayerSlug == _absent ? this.prayerSlug : prayerSlug as String?,
      prayerTitle: prayerTitle == _absent ? this.prayerTitle : prayerTitle as String?,
    );
  }
}
