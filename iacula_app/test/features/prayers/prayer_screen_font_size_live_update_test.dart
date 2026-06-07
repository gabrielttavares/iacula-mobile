import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_screen.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

final class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._value);

  Settings _value;

  @override
  Future<Settings> load() async => _value;

  @override
  Future<void> save(Settings settings) async {
    _value = settings;
  }
}

const _testPrayer = Prayer(
  title: 'Ave Maria',
  verses: [
    PrayerVerse(
      verse: 'Ave, cheia de graca, o Senhor e convosco.',
      response: 'Santa Maria, Mae de Deus.',
    ),
  ],
  prayer: 'Rogai por nos, pecadores.',
  type: 'marian',
  imagePath: null,
);

void main() {
  testWidgets(
    'font size updates live in PrayerScreen without navigating away',
    (tester) async {
      final repo = _FakeSettingsRepository(
        Settings.defaults.copyWith(prayerFontSize: 15.0),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const CupertinoApp(
            home: PrayerScreen(prayer: _testPrayer),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Confirm the verse text is rendered at the initial font size.
      final verseTextFinder = find.text('Ave, cheia de graca, o Senhor e convosco.');
      expect(verseTextFinder, findsOneWidget);

      final initialTextWidget = tester.widget<Text>(verseTextFinder);
      expect(
        initialTextWidget.style?.fontSize,
        15.0,
        reason: 'initial font size should be 15',
      );

      // Tap the A+ (increase) button.
      await tester.tap(find.text('A+'));
      await tester.pumpAndSettle();

      // The verse text should now reflect 16.0 without any navigation.
      final updatedTextWidget = tester.widget<Text>(verseTextFinder);
      expect(
        updatedTextWidget.style?.fontSize,
        16.0,
        reason:
            'font size should update live to 16 after tapping A+ once, '
            'without leaving and re-entering the screen',
      );

      // Verify the size counter badge also shows the new value.
      expect(find.text('16'), findsOneWidget);
    },
  );

  testWidgets(
    'font size decreases live in PrayerScreen when A- is tapped',
    (tester) async {
      final repo = _FakeSettingsRepository(
        Settings.defaults.copyWith(prayerFontSize: 18.0),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const CupertinoApp(
            home: PrayerScreen(prayer: _testPrayer),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('A-'));
      await tester.pumpAndSettle();

      final verseTextFinder = find.text('Ave, cheia de graca, o Senhor e convosco.');
      final updatedTextWidget = tester.widget<Text>(verseTextFinder);
      expect(
        updatedTextWidget.style?.fontSize,
        17.0,
        reason: 'font size should decrease live from 18 to 17 after tapping A-',
      );
    },
  );
}
