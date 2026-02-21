import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/services/quote_selector.dart';

void main() {
  test('selector wraps index', () {
    final step = QuoteSelector.getNextIndex(3, 2);
    expect(step.currentIndex, 2);
    expect(step.nextIndex, 0);
  });

  test('selector returns null when day is missing', () {
    final quote = QuoteSelector.selectQuote(collection: const {}, dayOfWeek: 3, index: 0);
    expect(quote, isNull);
  });

  test('selector reads day quote by key', () {
    final map = {
      '1': const DayQuotes(day: 'Domingo', theme: 'Tema', quotes: ['A', 'B']),
    };
    final quote = QuoteSelector.selectQuote(collection: map, dayOfWeek: 1, index: 1);
    expect(quote, 'B');
  });
}
