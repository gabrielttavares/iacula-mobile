import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/application/use_cases/get_prayer_catalog_use_case.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';

class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  _FakePrayerCatalogRepository(this.entries);

  final List<PrayerCatalogEntry> entries;
  final List<String> requestedLanguages = <String>[];

  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    requestedLanguages.add(language);
    return entries;
  }
}

void main() {
  const entries = <PrayerCatalogEntry>[
    PrayerCatalogEntry(
      slug: 'novena-sao-jose',
      title: 'Novena de Sao Jose',
      content: 'Texto da novena',
      themes: ['familia', 'trabalho'],
      saints: ['sao-jose'],
      sectionId: 'oracoes-a-sao-jose',
      sectionTitle: 'Orações a São José',
    ),
    PrayerCatalogEntry(
      slug: 'consagracao-sagrado-coracao',
      title: 'Consagracao ao Sagrado Coracao',
      content: 'Texto da consagracao',
      themes: ['consagracao'],
      saints: [],
      sectionId: 'oracoes-diversas',
      sectionTitle: 'Orações Diversas',
    ),
    PrayerCatalogEntry(
      slug: 'ladainha-santa-teresinha',
      title: 'Ladainha de Santa Teresinha',
      content: 'Texto da ladainha',
      themes: ['intercessao', 'mariano'],
      saints: ['santa-teresinha', 'virgem-maria'],
      sectionId: 'oracoes-a-sao-jose',
      sectionTitle: 'Orações a São José',
    ),
  ];

  test('listAll returns all entries', () async {
    final repository = _FakePrayerCatalogRepository(entries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);

    final result = await useCase.listAll(language: 'en');
    expect(result, entries);
    expect(repository.requestedLanguages, ['en']);
  });

  test('byTheme matches any theme tag in entry', () async {
    final repository = _FakePrayerCatalogRepository(entries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);

    final result = await useCase.byTheme(language: 'es', theme: 'mariano');
    expect(result.map((e) => e.slug), ['ladainha-santa-teresinha']);
    expect(repository.requestedLanguages, ['es']);
  });

  test('bySaint matches any saint tag in entry', () async {
    final repository = _FakePrayerCatalogRepository(entries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);

    final result = await useCase.bySaint(language: 'it', saint: 'virgem-maria');
    expect(result.map((e) => e.slug), ['ladainha-santa-teresinha']);
    expect(repository.requestedLanguages, ['it']);
  });

  test('byTheme returns empty list when no entry matches', () async {
    final repository = _FakePrayerCatalogRepository(entries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);

    final result = await useCase.byTheme(language: 'pt-br', theme: 'pascal');
    expect(result, isEmpty);
  });

  test('bySaint returns empty list when no entry matches', () async {
    final repository = _FakePrayerCatalogRepository(entries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);

    final result = await useCase.bySaint(language: 'pt-br', saint: 'sao-pio');
    expect(result, isEmpty);
  });

  test('bySection returns only entries with matching sectionId', () async {
    final repository = _FakePrayerCatalogRepository(entries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);

    final result = await useCase.bySection(
      language: 'pt-br',
      sectionId: 'oracoes-a-sao-jose',
    );
    expect(result.map((e) => e.slug), ['novena-sao-jose', 'ladainha-santa-teresinha']);
  });

  test('bySection returns empty list when no entry matches', () async {
    final repository = _FakePrayerCatalogRepository(entries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);

    final result = await useCase.bySection(
      language: 'pt-br',
      sectionId: 'outras',
    );
    expect(result, isEmpty);
  });

  test('suggestionOfDay returns same entry for same date', () async {
    final repository = _FakePrayerCatalogRepository(entries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);
    final date = DateTime(2026, 2, 26);

    final first = await useCase.suggestionOfDay(language: 'pt-br', date: date);
    final second = await useCase.suggestionOfDay(language: 'pt-br', date: date);

    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(first, second);
  });

  test('suggestionOfDay returns null when catalog has no entries', () async {
    final repository = _FakePrayerCatalogRepository(const <PrayerCatalogEntry>[]);
    final useCase = GetPrayerCatalogUseCase(repository: repository);

    final result = await useCase.suggestionOfDay(
      language: 'pt-br',
      date: DateTime(2026, 2, 26),
    );

    expect(result, isNull);
  });
}
