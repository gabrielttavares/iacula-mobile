import '../../domain/liturgical_season.dart';
import '../../domain/repositories/liturgical_season_cache_repository.dart';

final class InMemoryLiturgicalSeasonCacheRepository implements LiturgicalSeasonCacheRepository {
  final Map<String, LiturgicalSeason> _map = {};

  @override
  Future<LiturgicalSeason?> getByDateKey(String dateKey) async => _map[dateKey];

  @override
  Future<void> put(String dateKey, LiturgicalSeason season) async {
    _map[dateKey] = season;
  }
}
