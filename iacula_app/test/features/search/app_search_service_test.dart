import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/search/application/app_search_service.dart';

final class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  @override
  Future<List<PrayerCatalogEntry>> listCatalog({required String language}) async {
    return const [
      PrayerCatalogEntry(
        slug: 'oracao-no-silencio',
        title: 'Oração no silêncio',
        content: 'No silencio do coração, entregue tudo a Deus com confiança.',
        themes: ['silencio'],
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
        slug: 'oracao-pela-familia',
        title: 'Oração pela família',
        content: 'Peça unidade e caridade para a sua casa.',
        themes: ['familia'],
        saints: ['sagrada-familia'],
      ),
      PrayerCatalogEntry(
        slug: 'oracao-antes-do-trabalho',
        title: 'Oração antes do trabalho',
        content: 'Ofereça o trabalho de hoje a Deus.',
        themes: ['trabalho'],
        saints: ['sao-josemaria'],
      ),
      PrayerCatalogEntry(
        slug: 'oracao-da-entrega',
        title: 'Oração da entrega',
        content: 'Entregue o dia ao Senhor com paz.',
        themes: ['confianca'],
        saints: ['sao-jose'],
      ),
    ];
  }
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

void main() {
  AppSearchService buildService() {
    return AppSearchService(
      prayerCatalogRepository: _FakePrayerCatalogRepository(),
      quoteContentRepository: _FakeQuoteContentRepository(),
    );
  }

  test('searches across prayers and quotes', () async {
    final results = await buildService().search(query: 'ora', language: 'pt-br');

    expect(
      results.map((result) => result.type).toSet(),
      containsAll({AppSearchResultType.prayer, AppSearchResultType.quote}),
    );
  });

  test('ranks title matches ahead of secondary field matches', () async {
    final results = await buildService().search(
      query: 'silencio',
      language: 'pt-br',
    );

    expect(results, isNotEmpty);
    expect(results.first.title, 'Oração no silêncio');
    expect(results.first.type, AppSearchResultType.prayer);
  });

  test('groups results with section metadata for presentation', () async {
    final results = await buildService().search(query: 'or', language: 'pt-br');

    expect(results.any((result) => result.sectionTitle == 'Orações'), isTrue);
    expect(results.any((result) => result.sectionTitle == 'Citações'), isTrue);
  });

  test('builds a contextual snippet around the matched term', () async {
    final results = await buildService().search(
      query: 'silencio',
      language: 'pt-br',
    );
    final prayer = results.firstWhere(
      (result) => result.type == AppSearchResultType.prayer,
    );

    expect(prayer.snippet.toLowerCase(), contains('silencio'));
    expect(prayer.snippet.length, lessThan(prayer.prayerEntry!.content.length));
  });

  test('limits each section to keep search results scannable', () async {
    final results = await buildService().search(
      query: 'oracao',
      language: 'pt-br',
    );
    final prayerResults = results
        .where((result) => result.sectionTitle == 'Orações')
        .toList(growable: false);

    expect(prayerResults.length, 4);
  });
}
