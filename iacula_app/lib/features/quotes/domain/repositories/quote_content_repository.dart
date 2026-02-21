import '../../../liturgical/domain/liturgical_season.dart';
import '../entities/day_quotes.dart';

abstract interface class QuoteContentRepository {
  Future<Map<String, DayQuotes>> loadQuotes({
    required String language,
    required LiturgicalSeason season,
  });

  Future<List<String>> listDayImages({
    required int dayOfWeek,
    required LiturgicalSeason season,
  });

  Future<List<String>> loadFeastQuotes(String feastSlug);

  Future<String?> getFeastImagePath(String feastSlug);
}
