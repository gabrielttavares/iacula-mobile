import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_collections_screen.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Settings> load() async => Settings.defaults;

  @override
  Future<void> save(Settings settings) async {}
}

class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    return const <PrayerCatalogEntry>[
      PrayerCatalogEntry(
        slug: 'pai-nosso',
        title: 'Pai Nosso',
        content: 'Pai nosso que estais nos céus.',
        themes: ['oracoes-comuns'],
        saints: [],
        sectionId: 'oracoes-comuns',
        sectionTitle: 'Orações Comuns',
        availableLanguages: ['pt-br', 'la'],
      ),
      PrayerCatalogEntry(
        slug: 'lembrai-vos',
        title: 'Lembrai-vos',
        content: 'Lembrai-vos, ó piíssima Virgem Maria.',
        themes: ['mariano'],
        saints: ['virgem-maria'],
        sectionId: 'mariano',
        sectionTitle: 'Orações Marianas',
        availableLanguages: ['pt-br', 'la'],
      ),
    ];
  }
}

void main() {
  testWidgets('renders group cards from catalog entries', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
          prayerCatalogRepositoryProvider.overrideWithValue(
            _FakePrayerCatalogRepository(),
          ),
        ],
        child: const CupertinoApp(home: PrayerCollectionsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Orações Comuns'), findsOneWidget);
    expect(find.text('Orações Marianas'), findsOneWidget);
    expect(find.text('Pai Nosso'), findsNothing);
    expect(find.text('Lembrai-vos'), findsNothing);
  });
}
