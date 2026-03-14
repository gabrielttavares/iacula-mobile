import '../liturgical/domain/liturgical_season.dart';
import '../liturgical/domain/services/liturgical_season_service.dart';
import '../quotes/domain/repositories/quote_content_repository.dart';
import 'widget_data_provider.dart';

/// Service that refreshes native home screen widget data.
/// Called on app open and via background workmanager task.
final class WidgetUpdateService {
  WidgetUpdateService({
    required this.widgetDataProvider,
    required this.quoteContentRepository,
    required this.liturgicalSeasonService,
  });

  final WidgetDataProvider widgetDataProvider;
  final QuoteContentRepository quoteContentRepository;
  final LiturgicalSeasonService liturgicalSeasonService;

  Future<void> refresh({int streakCount = 0, String? dailyReflection}) async {
    final context = await liturgicalSeasonService.getCurrentContext();
    await widgetDataProvider.updateWidgetData(
      dailyReflection:
          dailyReflection ?? 'O Senhor é o meu pastor, nada me faltará.',
      liturgicalColor: _seasonColor(context.season),
      streakCount: streakCount,
    );
  }

  String _seasonColor(LiturgicalSeason season) {
    return switch (season) {
      LiturgicalSeason.ordinary => 'green',
      LiturgicalSeason.advent || LiturgicalSeason.lent => 'purple',
      LiturgicalSeason.easter || LiturgicalSeason.christmas => 'white',
    };
  }
}
