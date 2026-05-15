import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/phrase_schedule.dart';

Map<String, dynamic> _toScheduleJson(CustomPhrase phrase) {
  return {
    ...phrase.schedule.toJson(),
    'useFixedSchedule': phrase.useFixedSchedule,
    if (phrase.prayerSlug != null) 'prayerSlug': phrase.prayerSlug,
    if (phrase.prayerTitle != null) 'prayerTitle': phrase.prayerTitle,
  };
}

CustomPhrase _fromScheduleJson(Map<String, dynamic> json, {
  required String id,
  required String text,
}) {
  return CustomPhrase(
    id: id,
    text: text,
    isActive: true,
    displayOnHero: true,
    displayAsNotification: true,
    useFixedSchedule: json['useFixedSchedule'] as bool? ?? false,
    schedule: PhraseSchedule.fromJson(json),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    prayerSlug: json['prayerSlug'] as String?,
    prayerTitle: json['prayerTitle'] as String?,
  );
}

void main() {
  group('Prayer alarm serialization round-trip', () {
    test('prayer alarm survives JSON round-trip', () {
      final original = CustomPhrase(
        id: 'test-id',
        text: 'Ave Maria',
        isActive: true,
        displayOnHero: false,
        displayAsNotification: true,
        useFixedSchedule: true,
        prayerSlug: 'ave-maria',
        prayerTitle: 'Ave Maria',
        schedule: const PhraseSchedule(
          type: PhraseScheduleType.daily,
          times: ['09:00', '18:00'],
        ),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final jsonStr = jsonEncode(_toScheduleJson(original));
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = _fromScheduleJson(
        decoded,
        id: original.id,
        text: original.text,
      );

      expect(restored.prayerSlug, 'ave-maria');
      expect(restored.prayerTitle, 'Ave Maria');
      expect(restored.isPrayerAlarm, isTrue);
      expect(restored.useFixedSchedule, isTrue);
      expect(restored.schedule.type, PhraseScheduleType.daily);
      expect(restored.schedule.times, ['09:00', '18:00']);
    });

    test('free-text phrase survives JSON round-trip without prayer fields', () {
      final original = CustomPhrase(
        id: 'test-id',
        text: 'Lembrai-Vos',
        schedule: const PhraseSchedule(
          type: PhraseScheduleType.weekly,
          daysOfWeek: [1, 3, 5],
          times: ['10:40'],
        ),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final jsonStr = jsonEncode(_toScheduleJson(original));
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = _fromScheduleJson(
        decoded,
        id: original.id,
        text: original.text,
      );

      expect(restored.prayerSlug, isNull);
      expect(restored.prayerTitle, isNull);
      expect(restored.isPrayerAlarm, isFalse);
      expect(restored.schedule.daysOfWeek, [1, 3, 5]);
    });

    test('JSON without prayer fields deserializes with null slugs', () {
      final legacyJson = {
        'type': 'daily',
        'daysOfWeek': <int>[],
        'specificDates': <String>[],
        'times': ['08:00'],
        'useFixedSchedule': true,
      };

      final restored = _fromScheduleJson(
        legacyJson,
        id: 'legacy-id',
        text: 'Old phrase',
      );

      expect(restored.prayerSlug, isNull);
      expect(restored.prayerTitle, isNull);
      expect(restored.isPrayerAlarm, isFalse);
    });
  });
}
