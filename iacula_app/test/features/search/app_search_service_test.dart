import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:iacula_app/features/leituras/data/repositories/leitura_repository.dart';
import 'package:iacula_app/features/leituras/data/sources/leitura_local_source.dart';
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';
import 'package:iacula_app/features/meditation/domain/repositories/meditation_catalog_repository.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/search/application/app_search_service.dart';

final class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  @override
  Future<List<PrayerCatalogEntry>> listCatalog({required String language}) async {
    return const [
      PrayerCatalogEntry(
        slug: 'salve-rainha',
        title: 'Salve Rainha',
        content: 'Oração mariana: rogai por nós, Santa Mãe de Deus.',
        themes: ['mariano'],
        saints: ['virgem-maria'],
      ),
    ];
  }
}

final class _FakeMeditationCatalogRepository
    implements MeditationCatalogRepository {
  @override
  Future<MeditationItem?> getById(String id) async => null;

  @override
  Future<List<MeditationItem>> listAll() async {
    return const [
      MeditationItem(
        id: 'med-1',
        type: MeditationType.text,
        title: 'Silêncio diante de Deus',
        summary: 'Um roteiro breve para recolher o coração.',
        categoryTags: ['contemplacao'],
        sourceName: 'Hablar con Dios',
        availability: MeditationAvailability(
          kind: MeditationAvailabilityKind.daily,
        ),
        provenance: MeditationProvenance(
          providerId: 'hablar-con-dios',
          providerType: 'daily_text',
        ),
      ),
    ];
  }

  @override
  Future<List<MeditationItem>> listByCategory(String category) => listAll();

  @override
  Future<List<MeditationItem>> listByType(MeditationType type) => listAll();
}

final class _FakeQuoteContentRepository implements QuoteContentRepository {
  @override
  Future<String?> getFeastImagePath(String feastSlug) async => null;

  @override
  Future<List<String>> listDayImages({
    required int dayOfWeek,
    required LiturgicalSeason season,
  }) async => const [];

  @override
  Future<List<String>> loadFeastQuotes(String feastSlug) async => const [];

  @override
  Future<Map<String, DayQuotes>> loadQuotes({
    required String language,
    required LiturgicalSeason season,
  }) async {
    return const {
      'monday': DayQuotes(
        day: 'monday',
        theme: 'Confiança',
        quotes: ['Confiai no Senhor de todo o coração.'],
      ),
    };
  }
}

LeituraRepository _buildLeituraRepository() {
  final localSource = LeituraLocalSource(
    loadAsset: (path) async {
      if (path == 'assets/books/library/index.json') {
        return jsonEncode({
          'authors': [
            {
              'id': 'josemaria',
              'name': 'São Josemaria',
              'assetPath': 'assets/books/library/authors/sao-josemaria.json',
            },
          ],
        });
      }

      if (path == 'assets/books/library/authors/sao-josemaria.json') {
        return jsonEncode({
          'books': [
            {
              'id': 'caminho',
              'title': 'Caminho',
              'author': 'São Josemaria',
              'language': 'pt-br',
              'type': 'points',
              'assetPath': 'assets/books/escriva/caminho.json',
              'description': 'Pontos para a oração diária.',
              'available': true,
            },
          ],
        });
      }

      return jsonEncode(<String, dynamic>{});
    },
  );

  return LeituraRepository(localSource: localSource);
}

void main() {
  test('searches across prayers, meditations, readings and quotes', () async {
    final service = AppSearchService(
      prayerCatalogRepository: _FakePrayerCatalogRepository(),
      meditationCatalogRepository: _FakeMeditationCatalogRepository(),
      leituraRepository: _buildLeituraRepository(),
      quoteContentRepository: _FakeQuoteContentRepository(),
    );

    final results = await service.search(
      query: 'ora',
      language: 'pt-br',
    );

    expect(
      results.map((result) => result.type).toSet(),
      containsAll({
        AppSearchResultType.prayer,
        AppSearchResultType.meditation,
        AppSearchResultType.reading,
        AppSearchResultType.quote,
      }),
    );
  });
}
