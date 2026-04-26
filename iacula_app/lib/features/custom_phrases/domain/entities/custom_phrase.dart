import 'phrase_schedule.dart';

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

  bool get isRotationMode => !useFixedSchedule;

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
    );
  }
}
