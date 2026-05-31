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
}
