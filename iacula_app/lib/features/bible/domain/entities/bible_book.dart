final class BibleBook {
  const BibleBook({
    required this.abbrev,
    required this.name,
    required this.chapterCount,
    required this.order,
  });

  final String abbrev;
  final String name;
  final int chapterCount;
  final int order;
}
