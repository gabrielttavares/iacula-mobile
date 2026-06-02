import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:iacula_app/features/settings/presentation/settings_screen.dart';

final class _FakeSettingsRepository implements SettingsRepository {
  Settings _value;
  _FakeSettingsRepository(this._value);
  @override
  Future<Settings> load() async => _value;
  @override
  Future<void> save(Settings settings) async {
    _value = settings;
  }
}

void main() {
  testWidgets('SettingsScreen shows font size preview', (tester) async {
    final repo = _FakeSettingsRepository(Settings.defaults.copyWith(prayerFontSize: 15.0));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const CupertinoApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final previewFinder = find.text(
      'Pelo sinal da santa cruz, livrai-nos, Deus, nosso Senhor, dos nossos inimigos.',
    );
    // The preview lives in the Aparência section, below the (now always-visible)
    // notification window block, so scroll it into view first.
    for (var i = 0; i < 20 && previewFinder.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
    }

    // Verify initial preview text
    expect(previewFinder, findsOneWidget);
    
    final textWidget = tester.widget<Text>(previewFinder);
    expect(textWidget.style?.fontSize, 15.0);
  });
}
