import '../liturgical_context.dart';
import '../liturgical_season.dart';

abstract interface class LiturgicalSeasonService {
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date});
  Future<LiturgicalContext> getCurrentContext({DateTime? date});
}
