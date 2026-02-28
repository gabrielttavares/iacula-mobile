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
}
