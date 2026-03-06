import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/home/presentation/home_prayer_groups.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
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

  test('buildHomeThematicGroups boosts penitential keys on friday in lent', () {
    final groups = buildHomeThematicGroups(
      const <PrayerCatalogEntry>[
        PrayerCatalogEntry(
          slug: 'ato-contricao',
          title: 'Ato de Contrição',
          content: 'Texto',
          themes: ['penitencia'],
          saints: [],
        ),
        PrayerCatalogEntry(
          slug: 'via-sacra',
          title: 'Via Sacra',
          content: 'Texto',
          themes: ['paixao-de-cristo'],
          saints: [],
        ),
        PrayerCatalogEntry(
          slug: 'familia-1',
          title: 'Família 1',
          content: 'Texto',
          themes: ['familia'],
          saints: [],
        ),
      ],
      season: LiturgicalSeason.lent,
      weekday: DateTime.friday,
    );

    expect(groups.first.key, 'penitencia');
  });

  test('buildHomeThematicGroups boosts festal keys on sunday in easter', () {
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
          slug: 'eucaristica-1',
          title: 'Eucarística',
          content: 'Texto',
          themes: ['eucaristica'],
          saints: [],
        ),
      ],
      season: LiturgicalSeason.easter,
      weekday: DateTime.sunday,
    );

    expect(groups.first.key, 'eucaristica');
  });

  test('buildHomeThematicGroups keeps useful-daily order for ordinary weekdays', () {
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
          slug: 'familia-1',
          title: 'Família',
          content: 'Texto',
          themes: ['familia'],
          saints: [],
        ),
      ],
      season: LiturgicalSeason.ordinary,
      weekday: DateTime.wednesday,
    );

    expect(groups.first.key, 'familia');
  });

  test('buildHomeThematicGroups returns empty for empty catalog', () {
    final groups = buildHomeThematicGroups(const <PrayerCatalogEntry>[]);
    expect(groups, isEmpty);
  });

  test('buildHomeThematicGroups handles saints-only entries', () {
    final groups = buildHomeThematicGroups(
      const <PrayerCatalogEntry>[
        PrayerCatalogEntry(
          slug: 'sao-jose',
          title: 'A São José',
          content: 'Texto',
          themes: [],
          saints: ['sao-jose'],
        ),
      ],
      season: LiturgicalSeason.ordinary,
      weekday: DateTime.monday,
    );

    expect(groups, hasLength(1));
    expect(groups.first.type, HomePrayerGroupType.saint);
    expect(groups.first.key, 'sao-jose');
  });
}
