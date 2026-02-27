import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/infrastructure/repositories/asset_prayer_catalog_repository.dart';

void main() {
  test('listCatalog parses accents, keeps empty tags, and skips malformed entries', () async {
    final repository = AssetPrayerCatalogRepository(
      loadAsset: (_) async => '''
[
  {
    "id": "pai-nosso",
    "title": "Pai Nosso",
    "content": "Pai nosso que estais nos céus.",
    "theme": ["oracoes-comuns", "confianca"],
    "saints": []
  },
  {
    "id": "oracao-curta",
    "title": "Oração Curta",
    "content": "Texto válido com acentuação.",
    "theme": [],
    "saints": []
  },
  {
    "id": "sem-titulo",
    "content": "Conteudo invalido",
    "theme": ["invalid"],
    "saints": []
  },
  {
    "id": "sao-jose-trabalho",
    "title": "Para o trabalho",
    "content": "São José, protegei meu trabalho.",
    "theme": ["trabalho", "intercessao"],
    "saints": ["sao-jose", "sagrada-familia"]
  },
  {
    "id": "tema-invalido",
    "title": "Tema invalido",
    "content": "Conteudo",
    "theme": "nao-e-lista",
    "saints": []
  }
]
''',
      loadAvailableAssets: () async => {
        'assets/seed/prayers/pt-br/oracoes_catalog.json',
      },
    );

    final result = await repository.listCatalog(language: 'pt_br');

    expect(result.map((entry) => entry.slug), [
      'pai-nosso',
      'oracao-curta',
      'sao-jose-trabalho',
    ]);
    expect(result.first.content, 'Pai nosso que estais nos céus.');
    expect(result.first.themes, ['oracoes-comuns', 'confianca']);
    expect(result[1].themes, isEmpty);
    expect(result[1].saints, isEmpty);
    expect(result.last.saints, ['sao-jose', 'sagrada-familia']);
  });

  test('listCatalog falls back to pt-br catalog when requested language is missing', () async {
    final requestedPaths = <String>[];
    final repository = AssetPrayerCatalogRepository(
      loadAsset: (path) async {
        requestedPaths.add(path);
        return '''
[
  {
    "id": "stabat-mater",
    "title": "Stabat Mater",
    "content": "De pe a Mae dolorosa.",
    "theme": ["mariano"],
    "saints": ["virgem-maria"]
  }
]
''';
      },
      loadAvailableAssets: () async => {
        'assets/seed/prayers/pt-br/oracoes_catalog.json',
      },
    );

    final result = await repository.listCatalog(language: 'fr');

    expect(requestedPaths, ['assets/seed/prayers/pt-br/oracoes_catalog.json']);
    expect(result.single.slug, 'stabat-mater');
  });

  test('listCatalog returns empty list when catalog payload is invalid', () async {
    final repository = AssetPrayerCatalogRepository(
      loadAsset: (_) async => '{"not":"a-list"}',
      loadAvailableAssets: () async => {
        'assets/seed/prayers/pt-br/oracoes_catalog.json',
      },
    );

    final result = await repository.listCatalog(language: 'pt-br');

    expect(result, isEmpty);
  });
}
