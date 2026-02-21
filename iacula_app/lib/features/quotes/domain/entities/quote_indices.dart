final class QuoteIndices {
  const QuoteIndices({
    required this.quoteIndices,
    required this.imageIndices,
    required this.lastDay,
  });

  final Map<int, int> quoteIndices;
  final Map<int, int> imageIndices;
  final int lastDay;

  factory QuoteIndices.empty(int dayOfWeek) {
    return QuoteIndices(
      quoteIndices: const {},
      imageIndices: const {},
      lastDay: dayOfWeek,
    );
  }

  QuoteIndices copyWith({
    Map<int, int>? quoteIndices,
    Map<int, int>? imageIndices,
    int? lastDay,
  }) {
    return QuoteIndices(
      quoteIndices: quoteIndices ?? this.quoteIndices,
      imageIndices: imageIndices ?? this.imageIndices,
      lastDay: lastDay ?? this.lastDay,
    );
  }
}
