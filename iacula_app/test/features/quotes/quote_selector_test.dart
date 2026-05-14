import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/services/quote_selector.dart';

void main() {
  test('shuffle bag returns different items before pool exhaustion', () {
    const poolKey = 'pool';
    final first = QuoteSelector.selectFromShuffleBag(
      const ['A', 'B', 'C'],
      cursor: 0,
      order: null,
      currentPoolKey: null,
      nextPoolKey: poolKey,
    );
    final second = QuoteSelector.selectFromShuffleBag(
      const ['A', 'B', 'C'],
      cursor: first.nextCursor,
      order: first.nextOrder,
      currentPoolKey: poolKey,
      nextPoolKey: poolKey,
    );

    expect(second.item, isNot(first.item));
  });

  test('selector returns null when day is missing', () {
    final quote = QuoteSelector.selectQuote(
      collection: const {},
      dayOfWeek: 3,
      index: 0,
    );
    expect(quote, isNull);
  });

  test('selector reads day quote by key', () {
    final map = {
      '1': const DayQuotes(day: 'Domingo', theme: 'Tema', quotes: ['A', 'B']),
    };
    final quote = QuoteSelector.selectQuote(
      collection: map,
      dayOfWeek: 1,
      index: 1,
    );
    expect(quote, 'B');
  });
}
