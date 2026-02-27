import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/application/use_cases/get_prayer_catalog_use_case.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';

class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  _FakePrayerCatalogRepository(this.entries);

  final List<PrayerCatalogEntry> entries;

  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    return entries;
  }
}

void main() {
  const entries = <PrayerCatalogEntry>[
    PrayerCatalogEntry(
      slug: 'novena-sao-jose',
      title: 'Novena de Sao Jose',
      theme: 'familia',
      saint: 'sao-jose',
    ),
    PrayerCatalogEntry(
      slug: 'consagracao-sagrado-coracao',
      title: 'Consagracao ao Sagrado Coracao',
      theme: 'consagracao',
      saint: null,
    ),
    PrayerCatalogEntry(
      slug: 'ladainha-santa-teresinha',
      title: 'Ladainha de Santa Teresinha',
      theme: 'intercessao',
      saint: 'santa-teresinha',
    ),
  ];

  test('listAll returns all entries', () async {
    final useCase = GetPrayerCatalogUseCase(
      repository: _FakePrayerCatalogRepository(entries),
    );

    final result = await useCase.listAll(language: 'pt-br');
    expect(result, entries);
  });

  test('byTheme returns only matching theme entries', () async {
    final useCase = GetPrayerCatalogUseCase(
      repository: _FakePrayerCatalogRepository(entries),
    );

    final result = await useCase.byTheme(
      language: 'pt-br',
      theme: 'intercessao',
    );
    expect(result.map((e) => e.slug), ['ladainha-santa-teresinha']);
  });

  test('bySaint ignores entries without saint', () async {
    final useCase = GetPrayerCatalogUseCase(
      repository: _FakePrayerCatalogRepository(entries),
    );

    final result = await useCase.bySaint(language: 'pt-br', saint: 'sao-jose');
    expect(result.map((e) => e.slug), ['novena-sao-jose']);
  });
}
