import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/design/iacula_input.dart';
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
  testWidgets('settings screen shows parity controls from desktop', (
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
      for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -180));
        await tester.pumpAndSettle();
      }
      expect(finder, findsOneWidget);
    }

    expect(find.text('Intervalo (minutos)'), findsOneWidget);
    expect(find.text('Duracao (desktop apenas)'), findsNothing);
    expect(
      find.text(
        'No mobile, o tempo do banner e controlado pelo sistema operacional.',
      ),
      findsNothing,
    );
    expect(find.text('Duracao (segundos)'), findsNothing);
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Autostart (mobile limitado)'), findsNothing);
    expect(find.text('Som no lembrete liturgico'), findsOneWidget);
    await expectVisible('Laudes');
    await expectVisible('Vesperas');
    await expectVisible('Completas');
    await expectVisible('Ora Media');
    await expectVisible('Salvar');
  });

  testWidgets('settings shows inline validation for invalid interval', (
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

    await tester.enterText(find.byType(IaculaTextInput).first, '0');
    final saveFinder = find.text('Salvar');
    for (var i = 0; i < 20 && saveFinder.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -180));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Use 1..60 no intervalo.'), findsOneWidget);
  });
}
