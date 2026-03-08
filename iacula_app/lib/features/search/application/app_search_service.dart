import '../../leituras/data/models/book_model.dart';
import '../../leituras/data/repositories/leitura_repository.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../meditation/domain/entities/meditation_item.dart';
import '../../meditation/domain/repositories/meditation_catalog_repository.dart';
import '../../prayers/domain/entities/prayer_catalog_entry.dart';
import '../../prayers/domain/repositories/prayer_catalog_repository.dart';
import '../../quotes/domain/repositories/quote_content_repository.dart';

enum AppSearchResultType { prayer, meditation, reading, quote }

final class AppSearchResult {
  const AppSearchResult._({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.snippet,
    this.prayerEntry,
    this.meditationItem,
    this.readingBook,
    this.quoteText,
  });

  final AppSearchResultType type;
  final String title;
  final String subtitle;
  final String snippet;
  final PrayerCatalogEntry? prayerEntry;
  final MeditationItem? meditationItem;
  final BookModel? readingBook;
  final String? quoteText;

  factory AppSearchResult.prayer(PrayerCatalogEntry entry) {
    return AppSearchResult._(
      type: AppSearchResultType.prayer,
      title: entry.title,
      subtitle: 'Oração',
      snippet: entry.content,
      prayerEntry: entry,
    );
  }

  factory AppSearchResult.meditation(MeditationItem item) {
    return AppSearchResult._(
      type: AppSearchResultType.meditation,
      title: item.title,
      subtitle: 'Meditação · ${item.sourceName}',
      snippet: item.summary,
      meditationItem: item,
    );
  }

  factory AppSearchResult.reading(BookModel book) {
    return AppSearchResult._(
      type: AppSearchResultType.reading,
      title: book.title,
      subtitle: 'Leitura · ${book.author}',
      snippet: book.description,
      readingBook: book,
    );
  }

  factory AppSearchResult.quote({
    required String theme,
    required String text,
  }) {
    return AppSearchResult._(
      type: AppSearchResultType.quote,
      title: 'Citação · $theme',
      subtitle: 'Citação',
      snippet: text,
      quoteText: text,
    );
  }
}

final class AppSearchService {
  AppSearchService({
    required this.prayerCatalogRepository,
    required this.meditationCatalogRepository,
    required this.leituraRepository,
    required this.quoteContentRepository,
  });

  final PrayerCatalogRepository prayerCatalogRepository;
  final MeditationCatalogRepository meditationCatalogRepository;
  final LeituraRepository leituraRepository;
  final QuoteContentRepository quoteContentRepository;

  Future<List<AppSearchResult>> search({
    required String query,
    required String language,
  }) async {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.length < 2) {
      return const <AppSearchResult>[];
    }

    final prayers = await prayerCatalogRepository.listCatalog(language: language);
    final meditations = await meditationCatalogRepository.listAll();
    final books = await leituraRepository.listBooks();

    final results = <AppSearchResult>[
      ...prayers
          .where((entry) => _matchesPrayer(entry, normalizedQuery))
          .map(AppSearchResult.prayer),
      ...meditations
          .where((item) => _matchesMeditation(item, normalizedQuery))
          .map(AppSearchResult.meditation),
      ...books
          .where((book) => _matchesBook(book, normalizedQuery))
          .map(AppSearchResult.reading),
      ...await _searchQuotes(
        normalizedQuery: normalizedQuery,
        language: language,
      ),
    ];

    return results.take(60).toList(growable: false);
  }

  bool _matchesPrayer(PrayerCatalogEntry entry, String query) {
    return _contains(entry.title, query) ||
        _contains(entry.content, query) ||
        entry.themes.any((theme) => _contains(theme, query)) ||
        entry.saints.any((saint) => _contains(saint, query));
  }

  bool _matchesMeditation(MeditationItem item, String query) {
    return _contains(item.title, query) ||
        _contains(item.summary, query) ||
        _contains(item.sourceName, query) ||
        item.categoryTags.any((tag) => _contains(tag, query));
  }

  bool _matchesBook(BookModel book, String query) {
    return _contains(book.title, query) ||
        _contains(book.author, query) ||
        _contains(book.description, query);
  }

  Future<List<AppSearchResult>> _searchQuotes({
    required String normalizedQuery,
    required String language,
  }) async {
    final results = <AppSearchResult>[];
    for (final season in LiturgicalSeason.values) {
      try {
        final quotes = await quoteContentRepository.loadQuotes(
          language: language,
          season: season,
        );
        for (final entry in quotes.entries) {
          for (final text in entry.value.quotes) {
            if (_contains(text, normalizedQuery) ||
                _contains(entry.value.theme, normalizedQuery)) {
              results.add(
                AppSearchResult.quote(
                  theme: entry.value.theme,
                  text: text,
                ),
              );
            }
          }
        }
      } catch (_) {
        // Missing seasonal data should not block mixed search.
      }
    }
    return results;
  }

  bool _contains(String source, String query) {
    return _normalize(source).contains(query);
  }

  String _normalize(String value) {
    final lower = value.trim().toLowerCase();
    return lower
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}
