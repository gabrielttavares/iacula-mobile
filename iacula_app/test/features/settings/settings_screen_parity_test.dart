import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:iacula_app/features/settings/presentation/settings_screen.dart';

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

void main() {
  testWidgets('settings screen shows current mobile sections', (tester) async {
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
      for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();
      }
      expect(finder, findsOneWidget);
    }

    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Aparência'), findsOneWidget);
    expect(find.text('Notificações ativas'), findsOneWidget);
    expect(find.text('Intervalo entre jaculatórias'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Tamanho da fonte'), findsOneWidget);
    await expectVisible('Personalização');
    await expectVisible('Minhas frases');
    await expectVisible('Pontos de Caminho/Sulco/Forja');
    await expectVisible('Salvar');
  });

  testWidgets('settings no longer shows deprecated sync and interval inputs', (
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

    expect(find.text('Intervalo das jaculatórias (minutos)'), findsNothing);
    expect(find.text('Sincronização entre dispositivos'), findsNothing);
    expect(find.text('Continuar com Google'), findsNothing);
    expect(find.text('Sincronizar agora'), findsNothing);
  });
}
