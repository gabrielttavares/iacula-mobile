import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/rosary/domain/entities/rosary_mystery_set.dart';

void main() {
  test('RosaryMysterySet.fromJson reads set image path', () {
    final set = RosaryMysterySet.fromJson({
      'type': 'joyful',
      'setImagePath': 'assets/seed/rosary/images/joyful_set_cover.jpg',
      'mysteries': [
        {
          'name': 'A Anunciacao',
          'fruit': 'Humildade',
          'scriptureRef': 'Lc 1,26-38',
          'scriptureText': 'Texto',
          'meditationText': 'Meditacao',
          'imagePath': 'assets/seed/rosary/images/joyful_1_annunciation.jpg',
        },
      ],
    });

    expect(set.setImagePath, 'assets/seed/rosary/images/joyful_set_cover.jpg');
    expect(
      set.mysteries.first.imagePath,
      'assets/seed/rosary/images/joyful_1_annunciation.jpg',
    );
  });

  test('RosaryMysteryTypeX.forDay returns joyful on Monday', () {
    final type = RosaryMysteryTypeX.forDay(DateTime(2026, 3, 2));

    expect(type, RosaryMysteryType.joyful);
  });
}
