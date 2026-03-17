enum BibleTestament { antigo, novo }

final class BibleBook {
  const BibleBook({
    required this.abbrev,
    required this.name,
    required this.chapterCount,
    required this.order,
    required this.testament,
  });

  final String abbrev;
  final String name;
  final int chapterCount;
  final int order;
  final BibleTestament testament;
}
