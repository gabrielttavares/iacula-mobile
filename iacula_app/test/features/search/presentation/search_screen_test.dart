import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/search/application/app_search_service.dart';
import 'package:iacula_app/features/search/presentation/search_screen.dart';

final class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  @override
  Future<List<PrayerCatalogEntry>> listCatalog({required String language}) async {
    return const [
      PrayerCatalogEntry(
        slug: 'salve-rainha',
        title: 'Salve Rainha',
        content: 'Oração mariana para os momentos de confiança.',
        themes: ['mariano'],
        saints: ['virgem-maria'],
      ),
      PrayerCatalogEntry(
        slug: 'exame-breve',
        title: 'Exame breve',
        content:
            'Faça uma pausa breve, agradeça pela fidelidade de Deus, releia o dia com calma e recomece com humildade diante do Senhor.',
        themes: ['exame'],
        saints: ['sao-josemaria'],
      ),
    ];
  }
}

final class _FakeQuoteContentRepository implements QuoteContentRepository {
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
  }) async {
    return const {
      'monday': DayQuotes(
        day: 'monday',
        theme: 'Recomeçar com confiança',
        quotes: ['Recomeçai com coragem e confiança no Senhor.'],
      ),
    };
  }
}

ProviderScope _buildApp() {
  return ProviderScope(
    overrides: [
      appSearchServiceProvider.overrideWithValue(
        AppSearchService(
          prayerCatalogRepository: _FakePrayerCatalogRepository(),
          quoteContentRepository: _FakeQuoteContentRepository(),
        ),
      ),
    ],
    child: const CupertinoApp(home: SearchScreen()),
  );
}

void main() {
  testWidgets('shows search field', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
  });

  testWidgets('shows discovery suggestions before searching', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Encontre algo para este momento'), findsOneWidget);
    expect(find.text('Sugestões para começar'), findsOneWidget);
    expect(find.text('exame'), findsOneWidget);
    expect(find.text('silêncio'), findsOneWidget);
  });

  testWidgets('shows matching prayer search results', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoSearchTextField), 'exame');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Exame breve'), findsOneWidget);
    expect(find.textContaining('resultado'), findsWidgets);
  });

  testWidgets('shows contextual snippets instead of full long content', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoSearchTextField), 're');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.textContaining('...'), findsWidgets);
  });

  testWidgets('tapping a suggestion starts a search and stores it as recent', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('recomeçar'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Resultados para "recomeçar"'), findsOneWidget);

    await tester.enterText(find.byType(CupertinoSearchTextField), '');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Buscas recentes'), findsOneWidget);
    expect(find.text('recomeçar'), findsWidgets);
  });

  testWidgets('tapping a reading search result opens the reader', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoSearchTextField), 'caminho');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Caminho'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Capítulos'), findsWidgets);
  });
}
