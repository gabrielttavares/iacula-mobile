import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_screen.dart';

const _prayer = Prayer(
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

void main() {
  testWidgets('renders prayer title verses response and final prayer',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrayerScreen(prayer: _prayer),
      ),
    );

    expect(find.text('Angelus'), findsOneWidget);
    expect(
        find.text('O anjo do Senhor anunciou a Maria.'), findsOneWidget);
    expect(
        find.text('E ela concebeu do Espirito Santo.'), findsOneWidget);
    expect(
      find.text(
          'Infundi, Senhor, vos pedimos, a vossa graca em nossas almas.'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('renders Join Course button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrayerScreen(prayer: _prayer),
      ),
    );

    expect(find.text('Join Course'), findsOneWidget);
  });

  testWidgets('applies theme-driven colors to content', (tester) async {
    final testTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFEFEFEF),
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF111111),
        onSurfaceVariant: Color(0xFF222222),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: testTheme,
        home: const PrayerScreen(prayer: _prayer),
      ),
    );

    // Title should use headlineSmall (inherits theme)
    final titleText = tester.widget<Text>(find.text('Angelus'));
    expect(titleText.style, isNotNull);

    // Verse should use onSurface
    final verseText = tester.widget<Text>(
        find.text('O anjo do Senhor anunciou a Maria.'));
    expect(verseText.style?.color?.a, 1.0);
    expect(verseText.style?.color?.r, 0.06666666666666667);

    // Response should use onSurfaceVariant
    final responseText = tester.widget<Text>(
        find.text('E ela concebeu do Espirito Santo.'));
    expect(responseText.style?.color?.a, 1.0);
    expect(responseText.style?.color?.r, 0.13333333333333333);

    // Final prayer should use onSurfaceVariant
    final finalPrayerText = tester.widget<Text>(find.text(
        'Infundi, Senhor, vos pedimos, a vossa graca em nossas almas.'));
    expect(finalPrayerText.style?.color?.a, 1.0);
    expect(finalPrayerText.style?.color?.r, 0.13333333333333333);
  });
}
