import '../quotes/domain/repositories/quote_content_repository.dart';
import 'widget_data_provider.dart';

/// Service that refreshes native home screen widget data.
/// Called on app open and via background workmanager task.
final class WidgetUpdateService {
  WidgetUpdateService({
    required this.widgetDataProvider,
    required this.quoteContentRepository,
  });

  final WidgetDataProvider widgetDataProvider;
  final QuoteContentRepository quoteContentRepository;

  Future<void> refresh({
    int streakCount = 0,
    String? dailyReflection,
  }) async {
    await widgetDataProvider.updateWidgetData(
      dailyReflection: dailyReflection ?? 'O Senhor é o meu pastor, nada me faltará.',
      liturgicalColor: 'green', // TODO: from liturgical season service
      streakCount: streakCount,
      saintOfDay: '', // TODO: implement saint of day
      saintDescription: '',
    );
  }
}
