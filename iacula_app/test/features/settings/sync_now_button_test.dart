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
  testWidgets('settings does not show legacy sync CTA', (tester) async {
    final settingsRepo = _FakeSettingsRepository(Settings.defaults);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(settingsRepo)],
        child: const CupertinoApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sincronizar agora'), findsNothing);
    expect(
      find.textContaining('sincronizados entre dispositivos'),
      findsNothing,
    );
  });
}
