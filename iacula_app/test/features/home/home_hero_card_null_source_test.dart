import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/favorites/infrastructure/repositories/in_memory_favorite_repository.dart';
import 'package:iacula_app/features/home/presentation/widgets/home_hero_card.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';

void main() {
  Quote escrivaQuote(String text) {
    return Quote(
      text: text,
      dayOfWeek: 1,
      theme: 'escriva',
      season: LiturgicalSeason.ordinary,
      source: QuoteSource.escrivaPoints,
      referenceLabel: 'Caminho, 1',
    );
  }

  Widget buildHero(Quote quote) {
    return ProviderScope(
      overrides: [
        favoriteRepositoryProvider.overrideWithValue(
          InMemoryFavoriteRepository(),
        ),
      ],
      child: CupertinoApp(
        home: Center(
          child: SizedBox(width: 320, child: HomeHeroCard(quote: quote)),
        ),
      ),
    );
  }

  testWidgets('home hero card tolerates legacy quote with null source', (
    tester,
  ) async {
    final quote = Quote(
      text: 'Teste',
      dayOfWeek: 1,
      theme: 'tema',
      season: LiturgicalSeason.ordinary,
      source: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(
            InMemoryFavoriteRepository(),
          ),
        ],
        child: CupertinoApp(home: HomeHeroCard(quote: quote)),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home_hero_card')), findsOneWidget);
  });

  testWidgets('long Escriva hero text is truncated with read-more affordance', (
    tester,
  ) async {
    final quote = escrivaQuote(
      List.filled(
        18,
        'Este ponto longo de Sao Josemaria precisa caber no card sem invadir os botoes.',
      ).join(' '),
    );

    await tester.pumpWidget(buildHero(quote));
    await tester.pumpAndSettle();

    expect(find.text('Continuar lendo'), findsOneWidget);
    expect(find.byKey(const Key('home_hero_text_fade')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short Escriva hero text does not show read-more affordance', (
    tester,
  ) async {
    await tester.pumpWidget(buildHero(escrivaQuote('Faze o que deves.')));
    await tester.pumpAndSettle();

    expect(find.text('Continuar lendo'), findsNothing);
    expect(find.byKey(const Key('home_hero_text_fade')), findsNothing);
  });

  testWidgets('tapping hero body opens full quote screen', (tester) async {
    final quote = escrivaQuote(
      List.filled(
        18,
        'Este ponto longo de Sao Josemaria precisa de leitura completa.',
      ).join(' '),
    );

    await tester.pumpWidget(buildHero(quote));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home_hero_card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quote_full_text_screen')), findsOneWidget);
    expect(find.text(quote.text), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_hero_card')), findsOneWidget);
  });

  testWidgets('tapping hero action does not open full quote screen', (
    tester,
  ) async {
    final quote = escrivaQuote(
      List.filled(
        18,
        'Este ponto longo de Sao Josemaria precisa de leitura completa.',
      ).join(' '),
    );

    await tester.pumpWidget(buildHero(quote));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('hero_bookmark_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quote_full_text_screen')), findsNothing);
    expect(find.byKey(const Key('home_hero_card')), findsOneWidget);
  });
}
