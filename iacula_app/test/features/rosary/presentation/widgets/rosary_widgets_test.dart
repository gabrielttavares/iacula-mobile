import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/rosary/presentation/widgets/bead_dots.dart';
import 'package:iacula_app/features/rosary/presentation/widgets/ken_burns_image.dart';
import 'package:iacula_app/features/rosary/presentation/widgets/mystery_progress_bar.dart';

void main() {
  testWidgets('KenBurnsImage shows fallback icon when image fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: KenBurnsImage(
            imagePath: 'assets/seed/rosary/images/not_found.jpg',
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);
  });

  testWidgets('MysteryProgressBar renders five segments and completed checks', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: MysteryProgressBar(currentIndex: 2, currentProgress: 0.4),
        ),
      ),
    );

    expect(find.byType(MysteryProgressSegment), findsNWidgets(5));
    expect(find.byIcon(CupertinoIcons.check_mark), findsNWidgets(2));
  });

  testWidgets('BeadDots exposes Ave Maria semantics labels', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(child: BeadDots(currentBeadIndex: 3)),
      ),
    );

    expect(find.bySemanticsLabel('Ave Maria 3 de 10'), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsNWidgets(13));
  });
}
