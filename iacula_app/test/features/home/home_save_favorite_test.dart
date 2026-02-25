import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/favorites/infrastructure/repositories/in_memory_favorite_repository.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';

/// Stub that returns a fixed quote for testing.
class _FakeLastDeliveredCardRepository implements LastDeliveredCardRepository {
  final Quote quote;
  _FakeLastDeliveredCardRepository(this.quote);

  @override
  Future<LastDeliveredCard?> load() async {
    return LastDeliveredCard.fromQuote(quote, deliveredAt: DateTime.now());
  }

  @override
  Future<void> save(LastDeliveredCard card) async {}
}

void main() {
  testWidgets('home screen has a bookmark button on quote banner', (tester) async {
    final quote = Quote(
      text: 'Test quote for bookmark.',
      dayOfWeek: 1,
      theme: 'Faith',
      season: LiturgicalSeason.ordinary,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(InMemoryFavoriteRepository()),
          lastDeliveredCardRepositoryProvider.overrideWithValue(
            _FakeLastDeliveredCardRepository(quote),
          ),
        ],
        child: const CupertinoApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(CupertinoIcons.bookmark), findsWidgets);
  });
}
