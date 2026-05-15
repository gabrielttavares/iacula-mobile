import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/phrase_schedule.dart';

CustomPhrase _makePhrase({
  bool useFixedSchedule = false,
  String? prayerSlug,
  String? prayerTitle,
  PhraseScheduleType scheduleType = PhraseScheduleType.daily,
  List<String> times = const [],
  List<int> daysOfWeek = const [],
}) {
  return CustomPhrase(
    id: 'test-id',
    text: prayerTitle ?? 'Test phrase text',
    useFixedSchedule: useFixedSchedule,
    prayerSlug: prayerSlug,
    prayerTitle: prayerTitle,
    schedule: PhraseSchedule(
      type: scheduleType,
      daysOfWeek: daysOfWeek,
      times: times,
    ),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

void main() {
  group('PhraseRow subtitle logic', () {
    test('prayer alarm shows isPrayerAlarm true', () {
      final phrase = _makePhrase(
        prayerSlug: 'ave-maria',
        prayerTitle: 'Ave Maria',
        useFixedSchedule: true,
        times: ['09:00'],
      );
      expect(phrase.isPrayerAlarm, isTrue);
      expect(phrase.isRotationMode, isFalse);
    });

    test('rotation mode phrase shows isRotationMode true', () {
      final phrase = _makePhrase();
      expect(phrase.isPrayerAlarm, isFalse);
      expect(phrase.isRotationMode, isTrue);
    });

    test('fixed schedule text phrase is not rotation mode', () {
      final phrase = _makePhrase(
        useFixedSchedule: true,
        scheduleType: PhraseScheduleType.weekly,
        daysOfWeek: [1, 3, 5],
        times: ['10:00'],
      );
      expect(phrase.isPrayerAlarm, isFalse);
      expect(phrase.isRotationMode, isFalse);
    });
  });

  group('EditTextPhraseScreen save defaults', () {
    test('text phrase saved with rotation defaults has correct flags', () {
      final original = CustomPhrase(
        id: 'existing-id',
        text: 'Old text',
        useFixedSchedule: true,
        displayOnHero: false,
        displayAsNotification: false,
        schedule: const PhraseSchedule(
          type: PhraseScheduleType.weekly,
          daysOfWeek: [1, 2],
          times: ['08:00'],
        ),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        text: 'Updated text',
        displayOnHero: true,
        displayAsNotification: true,
        useFixedSchedule: false,
        schedule: const PhraseSchedule(type: PhraseScheduleType.daily),
        prayerSlug: null,
        prayerTitle: null,
      );

      expect(updated.text, 'Updated text');
      expect(updated.displayOnHero, isTrue);
      expect(updated.displayAsNotification, isTrue);
      expect(updated.useFixedSchedule, isFalse);
      expect(updated.isRotationMode, isTrue);
      expect(updated.prayerSlug, isNull);
      expect(updated.prayerTitle, isNull);
      expect(updated.isPrayerAlarm, isFalse);
    });
  });

  group('EditPrayerAlarmScreen save defaults', () {
    test('prayer alarm saved with alarm defaults has correct flags', () {
      final phrase = CustomPhrase(
        id: 'alarm-id',
        text: 'Angelus',
        displayOnHero: false,
        displayAsNotification: true,
        useFixedSchedule: true,
        prayerSlug: 'angelus',
        prayerTitle: 'Angelus',
        schedule: const PhraseSchedule(
          type: PhraseScheduleType.daily,
          times: ['12:00'],
        ),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(phrase.isPrayerAlarm, isTrue);
      expect(phrase.displayOnHero, isFalse);
      expect(phrase.displayAsNotification, isTrue);
      expect(phrase.useFixedSchedule, isTrue);
      expect(phrase.isRotationMode, isFalse);
      expect(phrase.prayerSlug, 'angelus');
      expect(phrase.schedule.times, ['12:00']);
    });
  });

  group('Phrase partitioning for MinhasJaculatoriasScreen', () {
    test('phrases are correctly partitioned by isPrayerAlarm', () {
      final phrases = [
        _makePhrase(prayerSlug: 'ave-maria', prayerTitle: 'Ave Maria'),
        _makePhrase(),
        _makePhrase(prayerSlug: 'angelus', prayerTitle: 'Angelus'),
        _makePhrase(),
        _makePhrase(),
      ];

      final prayerAlarms = phrases.where((p) => p.isPrayerAlarm).toList();
      final textPhrases = phrases.where((p) => !p.isPrayerAlarm).toList();

      expect(prayerAlarms, hasLength(2));
      expect(textPhrases, hasLength(3));
      expect(prayerAlarms.every((p) => p.prayerSlug != null), isTrue);
      expect(textPhrases.every((p) => p.prayerSlug == null), isTrue);
    });

    test('empty phrase list produces empty partitions', () {
      final phrases = <CustomPhrase>[];

      final prayerAlarms = phrases.where((p) => p.isPrayerAlarm).toList();
      final textPhrases = phrases.where((p) => !p.isPrayerAlarm).toList();

      expect(prayerAlarms, isEmpty);
      expect(textPhrases, isEmpty);
    });
  });
}
