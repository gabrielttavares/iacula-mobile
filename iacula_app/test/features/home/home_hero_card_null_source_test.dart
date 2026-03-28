import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/favorites/infrastructure/repositories/in_memory_favorite_repository.dart';
import 'package:iacula_app/features/home/presentation/widgets/home_hero_card.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';

void main() {
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
        child: CupertinoApp(
          home: HomeHeroCard(quote: quote),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home_hero_card')), findsOneWidget);
  });
}
