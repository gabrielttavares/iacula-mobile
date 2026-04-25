final class DisabledQuoteKey {
  const DisabledQuoteKey({
    required this.dayOfWeek,
    required this.quoteIndex,
    this.season = 'ordinary',
  });

  final int dayOfWeek;
  final int quoteIndex;
  final String season;
}
