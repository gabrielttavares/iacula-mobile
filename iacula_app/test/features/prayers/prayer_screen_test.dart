import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_screen.dart';

void main() {
  const prayer = Prayer(
    title: 'Angelus',
    verses: [
      PrayerVerse(
        verse: 'O anjo do Senhor anunciou a Maria.',
        response: 'E ela concebeu do Espirito Santo.',
      ),
    ],
    prayer: 'Infundi, Senhor, vos pedimos, a vossa graca em nossas almas.',
    type: 'angelus',
    imagePath: 'assets/seed/images/angelus/J.jpg',
  );

  testWidgets('renders prayer content in cupertino layout', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CupertinoApp(home: PrayerScreen(prayer: prayer))),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoPageScaffold), findsOneWidget);
    expect(find.text('Angelus'), findsOneWidget);
    expect(find.text('Orações'), findsOneWidget);
    expect(find.text('O anjo do Senhor anunciou a Maria.'), findsOneWidget);
    expect(find.text('E ela concebeu do Espirito Santo.'), findsOneWidget);
    expect(
      find.text('Infundi, Senhor, vos pedimos, a vossa graca em nossas almas.'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('back button pops the prayer screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: CupertinoApp(
          home: Builder(
            builder: (context) => CupertinoPageScaffold(
              child: Center(
                child: CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const PrayerScreen(prayer: prayer),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Orações'));
    await tester.pumpAndSettle();

    expect(find.byType(PrayerScreen), findsNothing);
  });
}
