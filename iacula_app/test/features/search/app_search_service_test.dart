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
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    return const [
      PrayerCatalogEntry(
        slug: 'salve-rainha',
        title: 'Salve Rainha',
        content: 'Oração mariana: rogai por nós, Santa Mãe de Deus.',
        themes: ['mariano'],
        saints: ['virgem-maria'],
      ),
      PrayerCatalogEntry(
        slug: 'oracao-no-silencio',
        title: 'Oração no silêncio',
        content:
            'Antes de dormir, faça uma pausa longa e humilde. No silencio do coração, entregue tudo a Deus com confiança e recomece.',
        themes: ['silencio'],
        saints: ['sao-jose'],
      ),
      PrayerCatalogEntry(
        slug: 'oracao-da-entrega',
        title: 'Oração da entrega',
        content: 'Entregue o dia ao Senhor com paz.',
        themes: ['confianca'],
        saints: ['sao-jose'],
      ),
      PrayerCatalogEntry(
        slug: 'oracao-da-manha',
        title: 'Oração da manhã',
        content: 'Comece o dia com gratidão.',
        themes: ['manha'],
        saints: ['anjo-da-guarda'],
      ),
      PrayerCatalogEntry(
        slug: 'oracao-antes-do-trabalho',
        title: 'Oração antes do trabalho',
        content: 'Ofereça o trabalho de hoje a Deus.',
        themes: ['trabalho'],
        saints: ['sao-josemaria'],
      ),
      PrayerCatalogEntry(
        slug: 'oracao-pela-familia',
        title: 'Oração pela família',
        content: 'Peça unidade e caridade para a sua casa.',
        themes: ['familia'],
        saints: ['sagrada-familia'],
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
        title: 'Recolhimento diante de Deus',
        summary: 'Um roteiro breve de silêncio para recolher o coração.',
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
      MeditationItem(
        id: 'med-2',
        type: MeditationType.text,
        title: 'Exame ao fim do dia',
        summary: 'Termine o dia com gratidão e revisão serena.',
        categoryTags: ['exame'],
        sourceName: 'Opus Dei',
        availability: MeditationAvailability(
          kind: MeditationAvailabilityKind.daily,
        ),
        provenance: MeditationProvenance(
          providerId: 'opus-dei',
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

    final results = await service.search(query: 'ora', language: 'pt-br');

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

  test('ranks title matches ahead of secondary field matches', () async {
    final service = AppSearchService(
      prayerCatalogRepository: _FakePrayerCatalogRepository(),
      meditationCatalogRepository: _FakeMeditationCatalogRepository(),
      leituraRepository: _buildLeituraRepository(),
      quoteContentRepository: _FakeQuoteContentRepository(),
    );

    final results = await service.search(query: 'silencio', language: 'pt-br');

    expect(results, isNotEmpty);
    expect(results.first.title, 'Oração no silêncio');
    expect(results.first.type, AppSearchResultType.prayer);
    expect(
      results.firstWhere((result) => result.type == AppSearchResultType.prayer),
      isA<AppSearchResult>(),
    );
  });

  test('groups results with section metadata for presentation', () async {
    final service = AppSearchService(
      prayerCatalogRepository: _FakePrayerCatalogRepository(),
      meditationCatalogRepository: _FakeMeditationCatalogRepository(),
      leituraRepository: _buildLeituraRepository(),
      quoteContentRepository: _FakeQuoteContentRepository(),
    );

    final results = await service.search(query: 'or', language: 'pt-br');

    expect(results, isNotEmpty);
    expect(results.any((result) => result.sectionTitle == 'Orações'), isTrue);
    expect(
      results.any((result) => result.sectionTitle == 'Meditações'),
      isTrue,
    );
    expect(results.any((result) => result.sectionTitle == 'Leituras'), isTrue);
    expect(results.any((result) => result.sectionTitle == 'Citações'), isTrue);
  });

  test('builds a contextual snippet around the matched term', () async {
    final service = AppSearchService(
      prayerCatalogRepository: _FakePrayerCatalogRepository(),
      meditationCatalogRepository: _FakeMeditationCatalogRepository(),
      leituraRepository: _buildLeituraRepository(),
      quoteContentRepository: _FakeQuoteContentRepository(),
    );

    final results = await service.search(query: 'silencio', language: 'pt-br');
    final prayer = results.firstWhere(
      (result) => result.type == AppSearchResultType.prayer,
    );

    expect(prayer.snippet.toLowerCase(), contains('silencio'));
    expect(prayer.snippet.length, lessThan(prayer.prayerEntry!.content.length));
  });

  test('limits each section to keep search results scannable', () async {
    final service = AppSearchService(
      prayerCatalogRepository: _FakePrayerCatalogRepository(),
      meditationCatalogRepository: _FakeMeditationCatalogRepository(),
      leituraRepository: _buildLeituraRepository(),
      quoteContentRepository: _FakeQuoteContentRepository(),
    );

    final results = await service.search(query: 'oracao', language: 'pt-br');
    final prayerResults = results
        .where((result) => result.sectionTitle == 'Orações')
        .toList(growable: false);

    expect(prayerResults.length, 4);
  });
}
