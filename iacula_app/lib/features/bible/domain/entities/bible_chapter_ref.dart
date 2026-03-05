final class BibleChapterRef {
  const BibleChapterRef({
    required this.bookAbbrev,
    required this.chapterNumber,
  });

  final String bookAbbrev;
  final int chapterNumber;

  @override
  bool operator ==(Object other) {
    return other is BibleChapterRef &&
        other.bookAbbrev == bookAbbrev &&
        other.chapterNumber == chapterNumber;
  }

  @override
  int get hashCode => Object.hash(bookAbbrev, chapterNumber);
}
