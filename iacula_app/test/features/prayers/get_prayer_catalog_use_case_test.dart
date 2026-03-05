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

  const suggestionEntries = <PrayerCatalogEntry>[
    PrayerCatalogEntry(
      slug: 'cântico-dos-três-jovens',
      title: 'Cântico dos Três Jovens',
      content: 'Bendizei...',
      themes: ['missa-acao-de-gracas'],
      saints: [],
      sectionId: 'acao-de-gracas-santa-missa',
      sectionTitle: 'Ação de Graças depois da Santa Missa',
    ),
    PrayerCatalogEntry(
      slug: 'salmo-2',
      title: 'Salmo 2',
      content: 'Por que se amotinam...',
      themes: ['missa-acao-de-gracas'],
      saints: [],
      sectionId: 'acao-de-gracas-santa-missa',
      sectionTitle: 'Ação de Graças depois da Santa Missa',
    ),
    PrayerCatalogEntry(
      slug: 'adoro-te-devote',
      title: 'Adoro Te Devote',
      content: 'Adoro-Vos...',
      themes: ['missa-acao-de-gracas'],
      saints: [],
      sectionId: 'acao-de-gracas-santa-missa',
      sectionTitle: 'Ação de Graças depois da Santa Missa',
    ),
    PrayerCatalogEntry(
      slug: 'simbolo-atanasiano',
      title: 'Símbolo Atanasiano',
      content: 'Quicumque...',
      themes: ['missa-acao-de-gracas'],
      saints: [],
      sectionId: 'acao-de-gracas-santa-missa',
      sectionTitle: 'Ação de Graças depois da Santa Missa',
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

  test('suggestionOfDay returns salmo-2 on Tuesday', () async {
    final repository = _FakePrayerCatalogRepository(suggestionEntries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);
    // 2026-03-03 is a Tuesday
    final result = await useCase.suggestionOfDay(
      language: 'pt-br',
      date: DateTime(2026, 3, 3),
    );

    expect(result, isNotNull);
    expect(result!.slug, 'salmo-2');
  });

  test('suggestionOfDay returns adoro-te-devote on Thursday', () async {
    final repository = _FakePrayerCatalogRepository(suggestionEntries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);
    // 2026-03-05 is a Thursday
    final result = await useCase.suggestionOfDay(
      language: 'pt-br',
      date: DateTime(2026, 3, 5),
    );

    expect(result, isNotNull);
    expect(result!.slug, 'adoro-te-devote');
  });

  test('suggestionOfDay returns simbolo-atanasiano on 3rd Sunday', () async {
    final repository = _FakePrayerCatalogRepository(suggestionEntries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);
    // 2026-03-15 is the 3rd Sunday of March 2026
    final result = await useCase.suggestionOfDay(
      language: 'pt-br',
      date: DateTime(2026, 3, 15),
    );

    expect(result, isNotNull);
    expect(result!.slug, 'simbolo-atanasiano');
  });

  test('suggestionOfDay returns cântico on non-3rd Sunday', () async {
    final repository = _FakePrayerCatalogRepository(suggestionEntries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);
    // 2026-03-08 is the 2nd Sunday of March 2026
    final result = await useCase.suggestionOfDay(
      language: 'pt-br',
      date: DateTime(2026, 3, 8),
    );

    expect(result, isNotNull);
    expect(result!.slug, 'cântico-dos-três-jovens');
  });

  test('suggestionOfDay returns cântico on other weekdays', () async {
    final repository = _FakePrayerCatalogRepository(suggestionEntries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);
    // 2026-03-04 is a Wednesday
    final result = await useCase.suggestionOfDay(
      language: 'pt-br',
      date: DateTime(2026, 3, 4),
    );

    expect(result, isNotNull);
    expect(result!.slug, 'cântico-dos-três-jovens');
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

  test('suggestionOfDay returns null when slug not found in catalog', () async {
    // Catalog without the suggestion entries
    final repository = _FakePrayerCatalogRepository(entries);
    final useCase = GetPrayerCatalogUseCase(repository: repository);

    final result = await useCase.suggestionOfDay(
      language: 'pt-br',
      date: DateTime(2026, 3, 3),
    );

    expect(result, isNull);
  });
}
