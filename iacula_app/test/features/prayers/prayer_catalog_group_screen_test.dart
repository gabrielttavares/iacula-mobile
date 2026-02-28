import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/home/presentation/home_prayer_groups.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_catalog_detail_screen.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_catalog_group_screen.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

final class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Settings> load() async => Settings.defaults;

  @override
  Future<void> save(Settings settings) async {}
}

final class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  final requestedLanguages = <String>[];

  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    requestedLanguages.add(language);
    return const <PrayerCatalogEntry>[
      PrayerCatalogEntry(
        slug: 'pai-nosso',
        title: 'Pai Nosso',
        content: 'Texto',
        themes: ['familia'],
        saints: [],
        sectionId: 'oracoes-comuns',
        sectionTitle: 'Orações Comuns',
      ),
      PrayerCatalogEntry(
        slug: 'salve-rainha',
        title: 'Salve Rainha',
        content: 'Texto',
        themes: ['mariano', 'familia'],
        saints: ['virgem-maria'],
        sectionId: 'oracoes-comuns',
        sectionTitle: 'Orações Comuns',
      ),
      PrayerCatalogEntry(
        slug: 'anjo-da-guarda',
        title: 'Anjo da Guarda',
        content: 'Texto',
        themes: ['protecao'],
        saints: ['anjos'],
        sectionId: 'outras',
        sectionTitle: 'Outras',
      ),
    ];
  }
}

void main() {
  testWidgets('theme group screen lists only matching prayers', (tester) async {
    final repository = _FakePrayerCatalogRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
          prayerCatalogRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(
          home: PrayerCatalogGroupScreen(
            type: HomePrayerGroupType.theme,
            groupKey: 'familia',
            title: 'Família',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pai Nosso'), findsOneWidget);
    expect(find.text('Salve Rainha'), findsOneWidget);
    expect(find.text('Anjo da Guarda'), findsNothing);
  });

  testWidgets('saint group screen opens prayer details on tap', (tester) async {
    final repository = _FakePrayerCatalogRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
          prayerCatalogRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(
          home: PrayerCatalogGroupScreen(
            type: HomePrayerGroupType.saint,
            groupKey: 'virgem-maria',
            title: 'Virgem Maria',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Salve Rainha'), findsOneWidget);
    await tester.tap(find.text('Salve Rainha'));
    await tester.pumpAndSettle();

    expect(find.byType(PrayerCatalogDetailScreen), findsOneWidget);
  });

  testWidgets('section group screen lists only matching prayers', (tester) async {
    final repository = _FakePrayerCatalogRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
          prayerCatalogRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(
          home: PrayerCatalogGroupScreen(
            type: HomePrayerGroupType.section,
            groupKey: 'oracoes-comuns',
            title: 'Orações Comuns',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pai Nosso'), findsOneWidget);
    expect(find.text('Salve Rainha'), findsOneWidget);
    expect(find.text('Anjo da Guarda'), findsNothing);
  });
}
