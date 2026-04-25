import '../entities/day_quotes.dart';
import '../entities/quote_indices.dart';

typedef QuoteCollection = Map<String, DayQuotes>;

final class QuoteSelector {
  const QuoteSelector._();

  static ({int currentIndex, int nextIndex}) getNextIndex(
    int total,
    int current,
  ) {
    final validCurrent = (current >= 0 && current < total) ? current : 0;
    final next = (validCurrent + 1) % total;
    return (currentIndex: validCurrent, nextIndex: next);
  }

  static bool shouldResetIndices(int lastDay, int currentDay) {
    return lastDay != currentDay;
  }

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

  static String? selectFromList(List<String> quotes, int index) {
    if (quotes.isEmpty) return null;
    final safeIndex = (index >= 0 && index < quotes.length) ? index : 0;
    return quotes[safeIndex];
  }

  static QuoteIndices ensureCurrentDay(QuoteIndices indices, int dayOfWeek) {
    if (shouldResetIndices(indices.lastDay, dayOfWeek)) {
      return QuoteIndices.empty(dayOfWeek);
    }
    return indices;
  }
}
