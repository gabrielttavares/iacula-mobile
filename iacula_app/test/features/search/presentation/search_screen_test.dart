import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/leituras/data/repositories/leitura_repository.dart';
import 'package:iacula_app/features/leituras/data/sources/leitura_local_source.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';
import 'package:iacula_app/features/meditation/domain/repositories/meditation_catalog_repository.dart';
import 'package:iacula_app/features/meditation/presentation/meditation_reader_screen.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_catalog_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/search/application/app_search_service.dart';
import 'package:iacula_app/features/search/presentation/search_screen.dart';

final class _FakePrayerCatalogRepository implements PrayerCatalogRepository {
  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
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

final class _FakeMeditationCatalogRepository
    implements MeditationCatalogRepository {
  @override
  Future<MeditationItem?> getById(String id) async => null;

  @override
  Future<List<MeditationItem>> listAll() async {
    return const [
      MeditationItem(
        id: 'med-1',
        type: MeditationType.text,
        title: 'Meditação para recomeçar',
        summary: 'Retome a oração com silêncio e presença de Deus.',
        categoryTags: ['recomecar'],
        sourceName: 'Hablar con Dios',
        textContent: MeditationTextContent(
          body: 'Texto de meditação para recomeçar com serenidade.',
          format: 'plain',
          language: 'pt',
        ),
        availability: MeditationAvailability(
          kind: MeditationAvailabilityKind.daily,
        ),
        provenance: MeditationProvenance(
          providerId: 'hablar-con-dios',
          providerType: 'daily_text',
        ),
      ),
    ];
  }

  @override
  Future<List<MeditationItem>> listByCategory(String category) => listAll();

  @override
  Future<List<MeditationItem>> listByType(MeditationType type) => listAll();
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

LeituraRepository _buildLeituraRepository() {
  final localSource = LeituraLocalSource(
    loadAsset: (path) async {
      if (path == 'assets/books/library/index.json') {
        return jsonEncode({
          'authors': [
            {
              'id': 'josemaria',
              'name': 'São Josemaria',
              'assetPath': 'assets/books/library/authors/sao-josemaria.json',
            },
          ],
        });
      }

      if (path == 'assets/books/library/authors/sao-josemaria.json') {
        return jsonEncode({
          'books': [
            {
              'id': 'caminho',
              'title': 'Caminho',
              'author': 'São Josemaria',
              'language': 'pt-br',
              'type': 'points',
              'assetPath': 'assets/books/escriva/caminho.json',
              'description': 'Leitura breve para recomeçar o dia.',
              'available': true,
            },
          ],
        });
      }

      return jsonEncode(<String, dynamic>{});
    },
  );

  return LeituraRepository(localSource: localSource);
}

ProviderScope _buildApp() {
  return ProviderScope(
    overrides: [
      appSearchServiceProvider.overrideWithValue(
        AppSearchService(
          prayerCatalogRepository: _FakePrayerCatalogRepository(),
          meditationCatalogRepository: _FakeMeditationCatalogRepository(),
          leituraRepository: _buildLeituraRepository(),
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

  testWidgets('shows matching meditation search results', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoSearchTextField), 'meditação');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Meditação para recomeçar'), findsOneWidget);
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

  testWidgets('tapping a meditation search result opens the reader directly', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoSearchTextField), 'meditação');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meditação para recomeçar'));
    await tester.pumpAndSettle();

    expect(find.byType(MeditationReaderScreen), findsOneWidget);
    expect(find.text('A-'), findsOneWidget);
    expect(find.text('A+'), findsOneWidget);
  });
}
