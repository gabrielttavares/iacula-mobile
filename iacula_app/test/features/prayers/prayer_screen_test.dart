import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_screen.dart';

void main() {
  testWidgets('renders prayer title verses response and final prayer', (tester) async {
    const prayer = Prayer(
      title: 'Angelus',
      verses: [
        PrayerVerse(verse: 'O anjo do Senhor anunciou a Maria.', response: 'E ela concebeu do Espirito Santo.'),
      ],
      prayer: 'Infundi, Senhor, vos pedimos, a vossa graca em nossas almas.',
      type: 'angelus',
      imagePath: 'assets/seed/images/angelus/J.jpg',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PrayerScreen(prayer: prayer),
      ),
    );

    expect(find.text('Angelus'), findsNWidgets(2));
    expect(find.text('O anjo do Senhor anunciou a Maria.'), findsOneWidget);
    expect(find.text('E ela concebeu do Espirito Santo.'), findsOneWidget);
    expect(find.text('Infundi, Senhor, vos pedimos, a vossa graca em nossas almas.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
