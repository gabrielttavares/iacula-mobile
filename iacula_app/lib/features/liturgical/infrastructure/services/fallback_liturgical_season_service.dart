import '../../domain/liturgical_context.dart';
import '../../domain/liturgical_season.dart';
import '../../domain/services/liturgical_season_service.dart';

final class FallbackLiturgicalSeasonService implements LiturgicalSeasonService {
  const FallbackLiturgicalSeasonService();

  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async {
    return LiturgicalSeason.ordinary;
  }

  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async {
    return LiturgicalContext.ordinaryFallback;
  }
}
