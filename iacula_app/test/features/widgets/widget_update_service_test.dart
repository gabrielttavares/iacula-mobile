import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/widgets/widget_data_provider.dart';
import 'package:iacula_app/features/widgets/widget_update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FakeLiturgicalSeasonService implements LiturgicalSeasonService {
  const _FakeLiturgicalSeasonService(this.context);

  final LiturgicalContext context;

  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async =>
      context;

  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async =>
      context.season;
}

final class _UnusedQuoteContentRepository implements QuoteContentRepository {
  @override
  Future<String?> getFeastImagePath(String feastSlug) async => null;

  @override
  Future<List<String>> listDayImages({
    required int dayOfWeek,
    required LiturgicalSeason season,
  }) async => const [];

  @override
  Future<List<String>> loadFeastQuotes(String feastSlug) async => const [];

  @override
  Future<Map<String, DayQuotes>> loadQuotes({
    required String language,
    required LiturgicalSeason season,
  }) async => const <String, DayQuotes>{};
}

void main() {
  test(
    'refresh stores liturgical color',
    () async {
      SharedPreferences.setMockInitialValues({});

      final service = WidgetUpdateService(
        widgetDataProvider: WidgetDataProvider(),
        quoteContentRepository: _UnusedQuoteContentRepository(),
        liturgicalSeasonService: const _FakeLiturgicalSeasonService(
          LiturgicalContext(
            season: LiturgicalSeason.lent,
            rank: LiturgicalRank.weekday,
            apiQuotes: <String>[],
          ),
        ),
      );

      await service.refresh(
        streakCount: 4,
        dailyReflection: 'Permanecei em mim.',
      );

      final data = await WidgetDataProvider().readWidgetData();

      expect(data['dailyReflection'], 'Permanecei em mim.');
      expect(data['liturgicalColor'], 'purple');
    },
  );
}
