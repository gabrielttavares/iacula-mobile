import '../liturgical_season.dart';

abstract interface class LiturgicalSeasonCacheRepository {
  Future<LiturgicalSeason?> getByDateKey(String dateKey);
  Future<void> put(String dateKey, LiturgicalSeason season);
}
