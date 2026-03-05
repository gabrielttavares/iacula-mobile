import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/rosary/application/rosary_session_notifier.dart';
import 'package:iacula_app/features/rosary/domain/entities/rosary_mystery_set.dart';

void main() {
  RosaryMysterySet buildSet() {
    RosaryMystery buildMystery(int index) {
      return RosaryMystery(
        name: 'Misterio $index',
        fruit: 'Fruto',
        scriptureRef: 'Lc 1,1',
        scriptureText: 'Texto',
        meditationText: 'Meditacao',
      );
    }

    return RosaryMysterySet(
      type: RosaryMysteryType.joyful,
      mysteries: List<RosaryMystery>.generate(5, buildMystery),
      setImagePath: 'assets/seed/rosary/images/joyful_set_cover.jpg',
    );
  }

  test('starts at first mystery and first bead', () {
    final notifier = RosarySessionNotifier(buildSet());

    expect(notifier.state.currentDecadeIndex, 0);
    expect(notifier.state.currentBeadIndex, 0);
    expect(notifier.state.completedDecades, isEmpty);
    expect(notifier.state.startTime, isNotNull);
  });

  test('advanceBead moves through beads in current decade', () {
    final notifier = RosarySessionNotifier(buildSet());

    notifier.advanceBead();

    expect(notifier.state.currentDecadeIndex, 0);
    expect(notifier.state.currentBeadIndex, 1);
    expect(notifier.state.completedDecades, isEmpty);
  });

  test('advanceBead marks decade complete and goes next decade', () {
    final notifier = RosarySessionNotifier(buildSet());

    for (int i = 0; i < 13; i++) {
      notifier.advanceBead();
    }

    expect(notifier.state.completedDecades, {0});
    expect(notifier.state.currentDecadeIndex, 1);
    expect(notifier.state.currentBeadIndex, 0);
  });

  test('last bead on last decade only marks completion', () {
    final notifier = RosarySessionNotifier(buildSet());
    notifier.selectMystery(4);

    for (int i = 0; i < 13; i++) {
      notifier.advanceBead();
    }

    expect(notifier.state.currentDecadeIndex, 4);
    expect(notifier.state.currentBeadIndex, 12);
    expect(notifier.state.completedDecades, {4});
    expect(notifier.state.isRosaryComplete, isFalse);
  });

  test('reset restores indices and clears completed decades', () {
    final notifier = RosarySessionNotifier(buildSet());

    notifier.selectMystery(2);
    notifier.advanceBead();
    notifier.reset();

    expect(notifier.state.currentDecadeIndex, 0);
    expect(notifier.state.currentBeadIndex, 0);
    expect(notifier.state.completedDecades, isEmpty);
  });
}
