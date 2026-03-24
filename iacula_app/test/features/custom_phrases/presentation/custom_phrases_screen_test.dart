import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/custom_phrases/presentation/custom_phrases_screen.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

final class _FakeSettingsRepository implements SettingsRepository {
  Settings value;

  _FakeSettingsRepository(this.value);

  @override
  Future<Settings> load() async => value;

  @override
  Future<void> save(Settings settings) async {
    value = settings;
  }
}

final class _FakeCustomPhraseRepository implements CustomPhraseRepository {
  @override
  Future<void> delete(String id) async {}

  @override
  Future<CustomPhrase?> getById(String id) async => null;

  @override
  Future<List<CustomPhrase>> listAll() async => const <CustomPhrase>[];

  @override
  Future<void> save(CustomPhrase phrase) async {}

  @override
  Stream<List<CustomPhrase>> watchAll() => const Stream.empty();
}

void main() {
  testWidgets('shows Caminho/Sulco/Forja feed toggle', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(
              Settings.defaults.copyWith(escrivaPointsFeedOptionVisible: true),
            ),
          ),
          customPhraseRepositoryProvider.overrideWithValue(
            _FakeCustomPhraseRepository(),
          ),
        ],
        child: const CupertinoApp(home: CustomPhrasesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pontos de Caminho/Sulco/Forja'), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsWidgets);
  });
}
