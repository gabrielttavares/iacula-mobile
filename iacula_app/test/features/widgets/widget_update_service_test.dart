import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/widgets/widget_data_provider.dart';
import 'package:iacula_app/features/widgets/widget_update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  test('refresh stores default widget color', () async {
    SharedPreferences.setMockInitialValues({});

    final service = WidgetUpdateService(
      widgetDataProvider: WidgetDataProvider(),
      quoteContentRepository: _UnusedQuoteContentRepository(),
    );

    await service.refresh(
      streakCount: 4,
      dailyReflection: 'Permanecei em mim.',
    );

    final data = await WidgetDataProvider().readWidgetData();

    expect(data['dailyReflection'], 'Permanecei em mim.');
    expect(data['liturgicalColor'], 'green');
  });
}
