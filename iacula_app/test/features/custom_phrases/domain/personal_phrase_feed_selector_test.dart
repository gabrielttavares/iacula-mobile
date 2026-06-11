import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/phrase_schedule.dart';
import 'package:iacula_app/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart';

CustomPhrase _makePhrase({
  String id = 'id',
  bool isActive = true,
  bool displayOnHero = true,
  bool displayAsNotification = true,
  bool useFixedSchedule = false,
}) {
  return CustomPhrase(
    id: id,
    text: 'phrase $id',
    isActive: isActive,
    displayOnHero: displayOnHero,
    displayAsNotification: displayAsNotification,
    useFixedSchedule: useFixedSchedule,
    schedule: const PhraseSchedule(type: PhraseScheduleType.daily),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

void main() {
  group('PersonalPhraseFeedSelector.isPersonalSlot', () {
    test('shareStride is 4', () {
      expect(PersonalPhraseFeedSelector.shareStride, 4);
    });

    test('indices 0, 1, 2 are not personal slots', () {
      expect(PersonalPhraseFeedSelector.isPersonalSlot(0), isFalse);
      expect(PersonalPhraseFeedSelector.isPersonalSlot(1), isFalse);
      expect(PersonalPhraseFeedSelector.isPersonalSlot(2), isFalse);
    });

    test('indices 3, 7, 11 are personal slots', () {
      expect(PersonalPhraseFeedSelector.isPersonalSlot(3), isTrue);
      expect(PersonalPhraseFeedSelector.isPersonalSlot(7), isTrue);
      expect(PersonalPhraseFeedSelector.isPersonalSlot(11), isTrue);
    });

    test('is deterministic across repeated calls', () {
      for (var i = 0; i < 3; i++) {
        expect(PersonalPhraseFeedSelector.isPersonalSlot(3), isTrue);
        expect(PersonalPhraseFeedSelector.isPersonalSlot(4), isFalse);
      }
    });
  });

  group('PersonalPhraseFeedSelector eligibility filters', () {
    // Each phrase below opts in to hero AND notifications, then breaks exactly
    // one rule, so only the fully-eligible phrase survives either filter.
    final eligible = _makePhrase(id: 'eligible');
    final inactive = _makePhrase(id: 'inactive', isActive: false);
    final heroOff = _makePhrase(id: 'hero-off', displayOnHero: false);
    final notifOff =
        _makePhrase(id: 'notif-off', displayAsNotification: false);
    final fixedSchedule =
        _makePhrase(id: 'fixed', useFixedSchedule: true);

    final pool = [eligible, inactive, heroOff, notifOff, fixedSchedule];

    test('eligibleForHero keeps only active, hero-on, rotation phrases', () {
      final result = PersonalPhraseFeedSelector.eligibleForHero(pool);
      expect(result.map((p) => p.id), ['eligible', 'notif-off']);
    });

    test(
        'eligibleForNotifications keeps only active, notif-on, rotation phrases',
        () {
      final result = PersonalPhraseFeedSelector.eligibleForNotifications(pool);
      expect(result.map((p) => p.id), ['eligible', 'hero-off']);
    });
  });

  group('PersonalPhraseFeedSelector.phraseForSlot', () {
    final phraseA = _makePhrase(id: 'a');
    final phraseB = _makePhrase(id: 'b');

    test('returns null when the eligible pool is empty', () {
      final picked = PersonalPhraseFeedSelector.phraseForSlot(
        slotIndex: 3,
        eligible: const [],
      );
      expect(picked, isNull);
    });

    test('returns null for a non-personal slot even with phrases', () {
      final picked = PersonalPhraseFeedSelector.phraseForSlot(
        slotIndex: 0,
        eligible: [phraseA, phraseB],
      );
      expect(picked, isNull);
    });

    test('cycles a two-phrase pool across personal slots a, b, a, b', () {
      final ids = [3, 7, 11, 15]
          .map((slotIndex) => PersonalPhraseFeedSelector.phraseForSlot(
                slotIndex: slotIndex,
                eligible: [phraseA, phraseB],
              )?.id)
          .toList();
      expect(ids, ['a', 'b', 'a', 'b']);
    });

    test('is deterministic for slot 7', () {
      final first = PersonalPhraseFeedSelector.phraseForSlot(
        slotIndex: 7,
        eligible: [phraseA, phraseB],
      );
      final second = PersonalPhraseFeedSelector.phraseForSlot(
        slotIndex: 7,
        eligible: [phraseA, phraseB],
      );
      expect(first?.id, second?.id);
      expect(first?.id, 'b');
    });
  });

  group('PersonalPhraseFeedSelector.phraseForExclusiveSlot', () {
    final phraseA = _makePhrase(id: 'a');
    final phraseB = _makePhrase(id: 'b');

    test('returns null when the eligible pool is empty', () {
      final picked = PersonalPhraseFeedSelector.phraseForExclusiveSlot(
        slotIndex: 3,
        eligible: const [],
      );
      expect(picked, isNull);
    });

    test('a single phrase is returned for every slot (only-mine, 1 phrase)', () {
      final ids = [0, 1, 2, 3, 4, 5]
          .map((slotIndex) =>
              PersonalPhraseFeedSelector.phraseForExclusiveSlot(
                slotIndex: slotIndex,
                eligible: [phraseA],
              )?.id)
          .toList();
      expect(ids, ['a', 'a', 'a', 'a', 'a', 'a']);
    });

    test('cycles the pool on EVERY slot, not just personal ones', () {
      final ids = [0, 1, 2, 3, 4]
          .map((slotIndex) =>
              PersonalPhraseFeedSelector.phraseForExclusiveSlot(
                slotIndex: slotIndex,
                eligible: [phraseA, phraseB],
              )?.id)
          .toList();
      expect(ids, ['a', 'b', 'a', 'b', 'a']);
    });

    test('is deterministic for slot 5', () {
      final first = PersonalPhraseFeedSelector.phraseForExclusiveSlot(
        slotIndex: 5,
        eligible: [phraseA, phraseB],
      );
      final second = PersonalPhraseFeedSelector.phraseForExclusiveSlot(
        slotIndex: 5,
        eligible: [phraseA, phraseB],
      );
      expect(first?.id, second?.id);
      expect(first?.id, 'b');
    });
  });

  group('PersonalPhraseFeedSelector.slotIndexForFireTime', () {
    test('07:00 maps to slot index 28', () {
      expect(
        PersonalPhraseFeedSelector.slotIndexForFireTime(DateTime(2026, 1, 1, 7)),
        28,
      );
    });

    test('07:15 maps to slot index 29', () {
      expect(
        PersonalPhraseFeedSelector.slotIndexForFireTime(
            DateTime(2026, 1, 1, 7, 15)),
        29,
      );
    });

    test('is deterministic for 09:30', () {
      final fireAt = DateTime(2026, 1, 1, 9, 30);
      expect(
        PersonalPhraseFeedSelector.slotIndexForFireTime(fireAt),
        PersonalPhraseFeedSelector.slotIndexForFireTime(fireAt),
      );
    });
  });
}
