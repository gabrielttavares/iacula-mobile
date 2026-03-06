import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/home/presentation/home_prayer_groups.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';

void main() {
  const entries = <PrayerCatalogEntry>[
    PrayerCatalogEntry(
      slug: 'pai-nosso',
      title: 'Pai Nosso',
      content: 'Texto',
      themes: ['oracoes-comuns', 'familia'],
      saints: [],
    ),
    PrayerCatalogEntry(
      slug: 'salve-rainha',
      title: 'Salve Rainha',
      content: 'Texto',
      themes: ['mariano', 'familia'],
      saints: ['virgem-maria'],
    ),
    PrayerCatalogEntry(
      slug: 'anjo-da-guarda',
      title: 'Anjo da Guarda',
      content: 'Texto',
      themes: ['protecao'],
      saints: ['anjos'],
    ),
    PrayerCatalogEntry(
      slug: 'santo-desconhecido',
      title: 'Santo Desconhecido',
      content: 'Texto',
      themes: ['devocoes'],
      saints: ['santo-desconhecido'],
    ),
  ];

  test('buildThemePrayerGroups deduplicates keys and aggregates counts', () {
    final groups = buildThemePrayerGroups(entries);

    final familia = groups.firstWhere((group) => group.key == 'familia');
    expect(familia.itemCount, 2);
  });

  test('buildSaintPrayerGroups keeps curated order before alphabetical', () {
    final groups = buildSaintPrayerGroups(entries);
    expect(groups.map((group) => group.key), [
      'virgem-maria',
      'anjos',
      'santo-desconhecido',
    ]);
  });

  test('buildThemePrayerGroups orders non-curated keys alphabetically', () {
    final groups = buildThemePrayerGroups(entries);
    final nonCurated = groups
        .where((group) => !kCuratedThemeOrder.contains(group.key))
        .map((group) => group.label)
        .toList(growable: false);
    expect(nonCurated, orderedEquals([...nonCurated]..sort()));
  });

  test('buildSaintPrayerGroups humanizes unknown keys', () {
    final groups = buildSaintPrayerGroups(entries);
    final unknown = groups.firstWhere(
      (group) => group.key == 'santo-desconhecido',
    );
    expect(unknown.label, 'Santo Desconhecido');
  });

  test('buildHomeThematicGroups follows fixed kHomeThematicOrder', () {
    final groups = buildHomeThematicGroups(
      const <PrayerCatalogEntry>[
        PrayerCatalogEntry(
          slug: 'familia-1',
          title: 'Família 1',
          content: 'Texto',
          themes: ['familia'],
          saints: [],
        ),
        PrayerCatalogEntry(
          slug: 'igreja-1',
          title: 'Igreja',
          content: 'Texto',
          themes: ['igreja'],
          saints: [],
        ),
        PrayerCatalogEntry(
          slug: 'trabalho-1',
          title: 'Trabalho',
          content: 'Texto',
          themes: ['trabalho'],
          saints: [],
        ),
        PrayerCatalogEntry(
          slug: 'eucaristica-1',
          title: 'Eucarística',
          content: 'Texto',
          themes: ['eucaristica'],
          saints: [],
        ),
      ],
    );

    expect(groups.map((g) => g.key).toList(), [
      'trabalho',
      'familia',
      'igreja',
      'eucaristica',
    ]);
  });

  test('buildHomeThematicGroups only includes themes in kHomeThematicOrder', () {
    final groups = buildHomeThematicGroups(
      const <PrayerCatalogEntry>[
        PrayerCatalogEntry(
          slug: 'trabalho-1',
          title: 'Trabalho',
          content: 'Texto',
          themes: ['trabalho'],
          saints: [],
        ),
        PrayerCatalogEntry(
          slug: 'mariano-1',
          title: 'Mariano',
          content: 'Texto',
          themes: ['mariano'],
          saints: [],
        ),
      ],
    );

    expect(groups.map((g) => g.key), ['trabalho']);
  });

  test('buildHomeThematicGroups uses correct labels', () {
    final groups = buildHomeThematicGroups(
      const <PrayerCatalogEntry>[
        PrayerCatalogEntry(
          slug: 'eucaristica-1',
          title: 'Eucarística',
          content: 'Texto',
          themes: ['eucaristica'],
          saints: [],
        ),
        PrayerCatalogEntry(
          slug: 'anjos-1',
          title: 'Anjos',
          content: 'Texto',
          themes: [],
          saints: ['anjos'],
        ),
      ],
    );

    final eucaristica = groups.firstWhere((g) => g.key == 'eucaristica');
    final anjos = groups.firstWhere((g) => g.key == 'anjos');
    expect(eucaristica.label, 'Divina Eucaristia');
    expect(anjos.label, 'Santos Anjos');
  });

  test('buildHomeThematicGroups returns empty for empty catalog', () {
    final groups = buildHomeThematicGroups(const <PrayerCatalogEntry>[]);
    expect(groups, isEmpty);
  });

  test('buildHomeThematicGroups includes saints in kHomeThematicOrder', () {
    final groups = buildHomeThematicGroups(
      const <PrayerCatalogEntry>[
        PrayerCatalogEntry(
          slug: 'anjo-da-guarda',
          title: 'Anjo da Guarda',
          content: 'Texto',
          themes: [],
          saints: ['anjos'],
        ),
      ],
    );

    expect(groups, hasLength(1));
    expect(groups.first.type, HomePrayerGroupType.saint);
    expect(groups.first.key, 'anjos');
    expect(groups.first.label, 'Santos Anjos');
  });
}
