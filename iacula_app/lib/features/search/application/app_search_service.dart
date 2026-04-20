import '../../liturgical/domain/liturgical_season.dart';
import '../../prayers/domain/entities/prayer_catalog_entry.dart';
import '../../prayers/domain/repositories/prayer_catalog_repository.dart';
import '../../quotes/domain/repositories/quote_content_repository.dart';

String _normalizeSearchValue(String value) {
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

enum AppSearchResultType { prayer, quote }

final class AppSearchResult {
  const AppSearchResult._({
    required this.type,
    required this.sectionTitle,
    required this.score,
    required this.title,
    required this.subtitle,
    required this.snippet,
    this.prayerEntry,
    this.quoteText,
  });

  final AppSearchResultType type;
  final String sectionTitle;
  final int score;
  final String title;
  final String subtitle;
  final String snippet;
  final PrayerCatalogEntry? prayerEntry;
  final String? quoteText;

  factory AppSearchResult.prayer({
    required PrayerCatalogEntry entry,
    required int score,
    required String query,
  }) {
    return AppSearchResult._(
      type: AppSearchResultType.prayer,
      sectionTitle: 'Orações',
      score: score,
      title: entry.title,
      subtitle: 'Oração',
      snippet: _buildSnippet(
        primary: entry.content,
        query: query,
        fallbacks: [...entry.themes, ...entry.saints],
      ),
      prayerEntry: entry,
    );
  }

  factory AppSearchResult.quote({
    required String theme,
    required String text,
    required int score,
    required String query,
  }) {
    return AppSearchResult._(
      type: AppSearchResultType.quote,
      sectionTitle: 'Citações',
      score: score,
      title: 'Citação · $theme',
      subtitle: 'Citação',
      snippet: _buildSnippet(primary: text, query: query, fallbacks: [theme]),
      quoteText: text,
    );
  }

  static String _buildSnippet({
    required String primary,
    required String query,
    List<String> fallbacks = const [],
  }) {
    final trimmedPrimary = primary.trim();
    if (trimmedPrimary.isEmpty) {
      return fallbacks.isEmpty ? '' : fallbacks.first;
    }

    final normalizedPrimary = _normalizeSearchValue(trimmedPrimary);
    final normalizedQuery = _normalizeSearchValue(query);
    final matchIndex = normalizedPrimary.indexOf(normalizedQuery);

    if (matchIndex == -1) {
      if (trimmedPrimary.length <= 88) {
        return trimmedPrimary;
      }
      return '${trimmedPrimary.substring(0, 85).trimRight()}...';
    }

    final start = (matchIndex - 26).clamp(0, trimmedPrimary.length);
    final end = (matchIndex + normalizedQuery.length + 34).clamp(
      0,
      trimmedPrimary.length,
    );
    final prefix = start > 0 ? '...' : '';
    final suffix = end < trimmedPrimary.length ? '...' : '';
    return '$prefix${trimmedPrimary.substring(start, end).trim()}$suffix';
  }
}

final class AppSearchService {
  static const int _maxResultsPerSection = 4;
  static const Map<AppSearchResultType, int> _typeOrder = {
    AppSearchResultType.prayer: 0,
    AppSearchResultType.quote: 1,
  };

  AppSearchService({
    required this.prayerCatalogRepository,
    required this.quoteContentRepository,
  });

  final PrayerCatalogRepository prayerCatalogRepository;
  final QuoteContentRepository quoteContentRepository;

  Future<List<AppSearchResult>> search({
    required String query,
    required String language,
  }) async {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.length < 2) {
      return const <AppSearchResult>[];
    }

    final prayers = await prayerCatalogRepository.listCatalog(
      language: language,
    );

    final results = <AppSearchResult>[
      ...prayers
          .map(
            (entry) =>
                (entry: entry, score: _scorePrayer(entry, normalizedQuery)),
          )
          .where((candidate) => candidate.score > 0)
          .map(
            (candidate) => AppSearchResult.prayer(
              entry: candidate.entry,
              score: candidate.score,
              query: normalizedQuery,
            ),
          ),
      ...await _searchQuotes(
        normalizedQuery: normalizedQuery,
        language: language,
      ),
    ];

    results.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      if (byScore != 0) return byScore;
      final byType = _typeOrder[left.type]!.compareTo(_typeOrder[right.type]!);
      if (byType != 0) return byType;
      return left.title.compareTo(right.title);
    });

    final sectionCounts = <String, int>{};
    final limitedResults = <AppSearchResult>[];
    for (final result in results) {
      final count = sectionCounts[result.sectionTitle] ?? 0;
      if (count >= _maxResultsPerSection) {
        continue;
      }
      sectionCounts[result.sectionTitle] = count + 1;
      limitedResults.add(result);
    }

    return limitedResults.take(60).toList(growable: false);
  }

  int _scorePrayer(PrayerCatalogEntry entry, String query) {
    return _scoreFields(
      query: query,
      title: entry.title,
      secondary: [entry.content, ...entry.themes, ...entry.saints],
    );
  }

  Future<List<AppSearchResult>> _searchQuotes({
    required String normalizedQuery,
    required String language,
  }) async {
    final results = <AppSearchResult>[];
    final quotes = await quoteContentRepository.loadQuotes(
      language: language,
      season: LiturgicalSeason.ordinary,
    );
    for (final entry in quotes.entries) {
      for (final text in entry.value.quotes) {
        if (_contains(text, normalizedQuery) ||
            _contains(entry.value.theme, normalizedQuery)) {
          final score = _scoreFields(
            query: normalizedQuery,
            title: entry.value.theme,
            secondary: [text],
          );
          if (score > 0) {
            results.add(
              AppSearchResult.quote(
                theme: entry.value.theme,
                text: text,
                score: score,
                query: normalizedQuery,
              ),
            );
          }
        }
      }
    }
    return results;
  }

  bool _contains(String source, String query) {
    return _normalize(source).contains(query);
  }

  int _scoreFields({
    required String query,
    required String title,
    required List<String> secondary,
  }) {
    final normalizedTitle = _normalize(title);
    if (normalizedTitle == query) return 120;
    if (normalizedTitle.startsWith(query)) return 100;
    if (normalizedTitle.contains(query)) return 80;

    for (final field in secondary) {
      final normalizedField = _normalize(field);
      if (normalizedField == query) return 60;
      if (normalizedField.startsWith(query)) return 48;
      if (normalizedField.contains(query)) return 32;
    }

    return 0;
  }

  String _normalize(String value) {
    return _normalizeSearchValue(value);
  }
}
