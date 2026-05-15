import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/phrase_schedule.dart';

CustomPhrase _makePhrase({
  String? prayerSlug,
  String? prayerTitle,
}) {
  return CustomPhrase(
    id: 'test-id',
    text: prayerTitle ?? 'Test phrase text',
    schedule: const PhraseSchedule(type: PhraseScheduleType.daily),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    prayerSlug: prayerSlug,
    prayerTitle: prayerTitle,
  );
}

void main() {
  group('CustomPhrase.isPrayerAlarm', () {
    test('returns true when prayerSlug is set', () {
      final phrase = _makePhrase(
        prayerSlug: 'ave-maria',
        prayerTitle: 'Ave Maria',
      );
      expect(phrase.isPrayerAlarm, isTrue);
    });

    test('returns false when prayerSlug is null', () {
      final phrase = _makePhrase();
      expect(phrase.isPrayerAlarm, isFalse);
    });
  });

  group('CustomPhrase.copyWith nullable fields', () {
    test('preserves prayerSlug when not specified', () {
      final original = _makePhrase(prayerSlug: 'angelus');
      final copied = original.copyWith(text: 'changed');
      expect(copied.prayerSlug, 'angelus');
    });

    test('can set prayerSlug to a new value', () {
      final original = _makePhrase();
      final copied = original.copyWith(prayerSlug: 'ave-maria');
      expect(copied.prayerSlug, 'ave-maria');
    });

    test('can set prayerSlug to null explicitly', () {
      final original = _makePhrase(prayerSlug: 'angelus');
      final copied = original.copyWith(prayerSlug: null);
      expect(copied.prayerSlug, isNull);
    });

    test('can set prayerTitle to null explicitly', () {
      final original = _makePhrase(
        prayerSlug: 'angelus',
        prayerTitle: 'Angelus',
      );
      final copied = original.copyWith(prayerTitle: null);
      expect(copied.prayerTitle, isNull);
    });

    test('preserves prayerTitle when not specified', () {
      final original = _makePhrase(prayerTitle: 'Ave Maria');
      final copied = original.copyWith(text: 'changed');
      expect(copied.prayerTitle, 'Ave Maria');
    });
  });
}
