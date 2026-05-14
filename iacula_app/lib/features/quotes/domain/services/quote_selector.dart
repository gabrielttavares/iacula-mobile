import 'dart:math';

import '../entities/day_quotes.dart';

typedef QuoteCollection = Map<String, DayQuotes>;

final class QuoteSelector {
  const QuoteSelector._();

  static String? selectQuote({
    required QuoteCollection collection,
    required int dayOfWeek,
    required int index,
  }) {
    final day = collection[dayOfWeek.toString()];
    if (day == null || day.quotes.isEmpty) {
      return null;
    }

    final safeIndex = (index >= 0 && index < day.quotes.length) ? index : 0;
    return day.quotes[safeIndex];
  }

  static ({T? item, int nextCursor, List<int> nextOrder})
  selectFromShuffleBag<T>(
    List<T> items, {
    required int cursor,
    required List<int>? order,
    required String? currentPoolKey,
    required String nextPoolKey,
  }) {
    if (items.isEmpty) {
      return (item: null, nextCursor: 0, nextOrder: const <int>[]);
    }

    List<int> effectiveOrder;
    if (currentPoolKey != nextPoolKey || !_isValidOrder(order, items.length)) {
      effectiveOrder = _shuffleIndices(items.length);
      cursor = 0;
    } else {
      effectiveOrder = order!;
    }

    final validCursor = (cursor >= 0 && cursor < effectiveOrder.length)
        ? cursor
        : 0;
    final selectedIndex = effectiveOrder[validCursor];
    var nextCursor = validCursor + 1;
    var nextOrder = effectiveOrder;

    if (nextCursor >= effectiveOrder.length) {
      nextOrder = _shuffleIndices(
        items.length,
        avoidFirst: items.length > 1 ? selectedIndex : null,
      );
      nextCursor = 0;
    }

    return (
      item: items[selectedIndex],
      nextCursor: nextCursor,
      nextOrder: nextOrder,
    );
  }

  static bool _isValidOrder(List<int>? order, int total) {
    if (order == null || order.length != total) {
      return false;
    }

    final seen = <int>{};
    for (final value in order) {
      if (value < 0 || value >= total || !seen.add(value)) {
        return false;
      }
    }

    return true;
  }

  static List<int> _shuffleIndices(int total, {int? avoidFirst}) {
    final indices = List<int>.generate(total, (index) => index);
    indices.shuffle(Random());

    if (avoidFirst != null &&
        indices.length > 1 &&
        indices.first == avoidFirst) {
      final first = indices.removeAt(0);
      indices.add(first);
    }

    return indices;
  }
}
