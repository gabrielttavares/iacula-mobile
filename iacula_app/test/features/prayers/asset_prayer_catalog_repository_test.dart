import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/infrastructure/repositories/asset_prayer_catalog_repository.dart';

void main() {
  test('listCatalog parses valid entries and skips malformed ones', () async {
    final repository = AssetPrayerCatalogRepository(
      loadAsset: (_) async => '''
[
  {
    "id": "pai-nosso",
    "title": "Pai Nosso",
    "content": "Pai nosso que estais nos ceus.",
    "theme": ["oracoes-comuns", "confianca"],
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
    "content": "Sao Jose, protegei meu trabalho.",
    "theme": ["trabalho", "intercessao"],
    "saints": ["sao-jose"]
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

    expect(result.map((entry) => entry.slug), ['pai-nosso', 'sao-jose-trabalho']);
    expect(result.first.theme, 'oracoes-comuns');
    expect(result.last.saint, 'sao-jose');
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
