import 'liturgical_season.dart';

enum LiturgicalRank {
  solemnity,
  feast,
  memorial,
  weekday,
}

final class LiturgicalContext {
  const LiturgicalContext({
    required this.season,
    required this.rank,
    required this.apiQuotes,
    this.feast,
    this.feastName,
  });

  final LiturgicalSeason season;
  final LiturgicalRank rank;
  final String? feast;
  final String? feastName;
  final List<String> apiQuotes;

  static const ordinaryFallback = LiturgicalContext(
    season: LiturgicalSeason.ordinary,
    rank: LiturgicalRank.weekday,
    apiQuotes: <String>[],
  );
}
