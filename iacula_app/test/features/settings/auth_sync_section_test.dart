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
  testWidgets('settings screen shows optional auth sync section', (
    tester,
  ) async {
    final repo = _FakeSettingsRepository(Settings.defaults);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const CupertinoApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    Future<void> expectVisible(String text) async {
      final finder = find.text(text);
      for (var i = 0; i < 24 && finder.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
      }
      expect(finder, findsOneWidget);
    }

    await expectVisible('Sincronização entre dispositivos');
    await expectVisible('Continuar com Google');
    await expectVisible('Continuar com Microsoft');
  });
}
