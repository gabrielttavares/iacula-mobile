final class QuoteIndices {
  const QuoteIndices({
    required this.quoteIndices,
    required this.imageIndices,
    this.quoteOrders = const {},
    this.imageOrders = const {},
    this.quotePoolKeys = const {},
    this.imagePoolKeys = const {},
  });

  final Map<int, int> quoteIndices;
  final Map<int, int> imageIndices;
  final Map<int, List<int>> quoteOrders;
  final Map<int, List<int>> imageOrders;
  final Map<int, String> quotePoolKeys;
  final Map<int, String> imagePoolKeys;

  factory QuoteIndices.empty([int? dayOfWeek]) {
    return const QuoteIndices(quoteIndices: const {}, imageIndices: const {});
  }

  QuoteIndices copyWith({
    Map<int, int>? quoteIndices,
    Map<int, int>? imageIndices,
    Map<int, List<int>>? quoteOrders,
    Map<int, List<int>>? imageOrders,
    Map<int, String>? quotePoolKeys,
    Map<int, String>? imagePoolKeys,
  }) {
    return QuoteIndices(
      quoteIndices: quoteIndices ?? this.quoteIndices,
      imageIndices: imageIndices ?? this.imageIndices,
      quoteOrders: quoteOrders ?? this.quoteOrders,
      imageOrders: imageOrders ?? this.imageOrders,
      quotePoolKeys: quotePoolKeys ?? this.quotePoolKeys,
      imagePoolKeys: imagePoolKeys ?? this.imagePoolKeys,
    );
  }
}
