import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart';

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
}
