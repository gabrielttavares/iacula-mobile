import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/rosary/domain/entities/rosary_mystery_set.dart';
import 'package:iacula_app/features/rosary/presentation/rosary_completion_screen.dart';
import 'package:iacula_app/features/rosary/presentation/rosary_intro_screen.dart';
import 'package:iacula_app/features/rosary/presentation/rosary_mystery_set_screen.dart';

void main() {
  RosaryMysterySet buildSet(RosaryMysteryType type, String cover) {
    return RosaryMysterySet(
      type: type,
      setImagePath: cover,
      mysteries: List<RosaryMystery>.generate(
        5,
        (index) => RosaryMystery(
          name: 'Misterio ${index + 1}',
          fruit: 'Fruto ${index + 1}',
          scriptureRef: 'Lc 1,1',
          scriptureText: 'Texto',
          meditationText: 'Meditacao',
          imagePath: 'assets/seed/rosary/images/missing_${index + 1}.jpg',
        ),
      ),
    );
  }

  testWidgets('intro opens mystery set screen on tap', (tester) async {
    final joyful = buildSet(
      RosaryMysteryType.joyful,
      'assets/seed/rosary/images/joyful_set_cover.jpg',
    );
    final allSets = [
      joyful,
      buildSet(
        RosaryMysteryType.sorrowful,
        'assets/seed/rosary/images/sorrowful_set_cover.jpg',
      ),
      buildSet(
        RosaryMysteryType.glorious,
        'assets/seed/rosary/images/glorious_set_cover.jpg',
      ),
      buildSet(
        RosaryMysteryType.luminous,
        'assets/seed/rosary/images/luminous_set_cover.jpg',
      ),
    ];

    await tester.pumpWidget(
      CupertinoApp(
        home: RosaryIntroScreen(mysterySet: joyful, allMysterySets: allSets),
      ),
    );

    expect(find.text('Mistérios Gozosos'), findsOneWidget);

    await tester.tap(find.byKey(const Key('rosary-intro-tap-target')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(RosaryMysterySetScreen), findsOneWidget);
  });

  testWidgets('intro opens mystery set picker from menu', (tester) async {
    final joyful = buildSet(
      RosaryMysteryType.joyful,
      'assets/seed/rosary/images/joyful_set_cover.jpg',
    );
    final allSets = [
      joyful,
      buildSet(
        RosaryMysteryType.sorrowful,
        'assets/seed/rosary/images/sorrowful_set_cover.jpg',
      ),
      buildSet(
        RosaryMysteryType.glorious,
        'assets/seed/rosary/images/glorious_set_cover.jpg',
      ),
      buildSet(
        RosaryMysteryType.luminous,
        'assets/seed/rosary/images/luminous_set_cover.jpg',
      ),
    ];

    await tester.pumpWidget(
      CupertinoApp(
        home: RosaryIntroScreen(mysterySet: joyful, allMysterySets: allSets),
      ),
    );

    await tester.tap(find.byKey(const Key('rosary-intro-overflow')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Ver todos os mistérios'), findsOneWidget);
    expect(find.text('Mistérios Luminosos'), findsOneWidget);
  });

  testWidgets('completion can finish from the decision screen', (tester) async {
    var doneTapped = false;

    await tester.pumpWidget(
      ProviderScope(
        child: CupertinoApp(
          home: RosaryCompletionScreen(
            mysteryImagePath:
                'assets/seed/rosary/images/joyful_5_finding_temple.jpg',
            elapsed: const Duration(minutes: 18),
            streakCount: 7,
            onDone: () {
              doneTapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('5º mistério concluído'), findsOneWidget);

    await tester.tap(find.text('Encerrar rosário'));
    await tester.pump();
    expect(doneTapped, isTrue);
  });
}
