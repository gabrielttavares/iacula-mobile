import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_screen.dart';

void main() {
  testWidgets('applies theme-driven colors and removes hardcoded dark palette', (tester) async {
    const prayer = Prayer(
      title: 'Angelus',
      verses: [
        PrayerVerse(verse: 'O anjo do Senhor anunciou a Maria.', response: 'E ela concebeu do Espirito Santo.'),
      ],
      prayer: 'Infundi, Senhor, vos pedimos, a vossa graca em nossas almas.',
      type: 'angelus',
      imagePath: 'assets/seed/images/angelus/J.jpg',
    );

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
        home: const PrayerScreen(prayer: prayer),
      ),
    );

    // Scaffold background should not be forced
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, null); // uses theme default

    // Title should use onSurface
    final titleTextElements = tester.widgetList<Text>(find.text('Angelus')).toList();
    for (var i = 0; i < titleTextElements.length; i++) {
      print('Element $i style: ${titleTextElements[i].style}');
    }
    
    // Find the one that actually has the headlineSmall styling (it's the body one)
    final titleText = titleTextElements.firstWhere((t) => t.style != null);
    
    expect(titleText.style?.color?.a, 1.0);
    expect(titleText.style?.color?.r, 0.06666666666666667); // 0x11 / 255
    expect(titleText.style?.color?.g, 0.06666666666666667);
    expect(titleText.style?.color?.b, 0.06666666666666667);

    // Verse should use onSurface
    final verseText = tester.widget<Text>(find.text('O anjo do Senhor anunciou a Maria.'));
    expect(verseText.style?.color?.a, 1.0);
    expect(verseText.style?.color?.r, 0.06666666666666667); // 0x11 / 255
    expect(verseText.style?.color?.g, 0.06666666666666667);
    expect(verseText.style?.color?.b, 0.06666666666666667);

    // Response should use onSurfaceVariant
    final responseText = tester.widget<Text>(find.text('E ela concebeu do Espirito Santo.'));
    expect(responseText.style?.color?.a, 1.0);
    expect(responseText.style?.color?.r, 0.13333333333333333); // 0x22 / 255
    expect(responseText.style?.color?.g, 0.13333333333333333);
    expect(responseText.style?.color?.b, 0.13333333333333333);

    // Final prayer should use onSurfaceVariant
    final finalPrayerText = tester.widget<Text>(find.text('Infundi, Senhor, vos pedimos, a vossa graca em nossas almas.'));
    expect(finalPrayerText.style?.color?.a, 1.0);
    expect(finalPrayerText.style?.color?.r, 0.13333333333333333); // 0x22 / 255
    expect(finalPrayerText.style?.color?.g, 0.13333333333333333);
    expect(finalPrayerText.style?.color?.b, 0.13333333333333333);

    // Gradient overlay should use theme surface color with opacity, not hardcoded black
    final decoratedBox = tester.widget<DecoratedBox>(
      find.byWidgetPredicate(
        (widget) => widget is DecoratedBox && widget.decoration is BoxDecoration && (widget.decoration as BoxDecoration).gradient is LinearGradient
      ),
    );
    final gradient = (decoratedBox.decoration as BoxDecoration).gradient as LinearGradient;
    
    expect(gradient.colors[0].a, 0.65);
    expect(gradient.colors[0].r, 1.0);
    expect(gradient.colors[0].g, 1.0);
    expect(gradient.colors[0].b, 1.0);
    
    expect(gradient.colors[1].a, 0.95);
    expect(gradient.colors[1].r, 1.0);
    expect(gradient.colors[1].g, 1.0);
    expect(gradient.colors[1].b, 1.0);
  });

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
