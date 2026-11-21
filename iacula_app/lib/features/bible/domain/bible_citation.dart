/// Detection of Bible citations (e.g. "Lc 1, 38", "1Cor 12, 6", "II Pe 1, 4")
/// inside free reading text, resolved to the abbreviations used by the bundled
/// Bible (`assets/seed/bible/listalivros.json`).
///
/// The bundled Bible follows the Vulgate numbering for the Psalms (it is the
/// Matos Soares translation). Most books in the library cite the Psalms the same
/// way, but modern texts (e.g. the Compendium of the Catechism) use the Hebrew
/// numbering, so the parser takes a [PsalmNumbering] for the text it reads.
library;

enum PsalmNumbering { vulgate, hebrew }

final class BibleVerseRange {
  const BibleVerseRange(this.start, [int? end]) : end = end ?? start;

  final int start;
  final int end;

  bool contains(int verse) => verse >= start && verse <= end;

  @override
  bool operator ==(Object other) =>
      other is BibleVerseRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => start == end ? '$start' : '$start-$end';
}

/// A concrete location in the bundled Bible.
final class BibleReference {
  const BibleReference({
    required this.bookAbbrev,
    required this.chapter,
    required this.verses,
  });

  /// Abbreviation of the bundled Bible (e.g. `Lc`, `Ps`, `1Co`).
  final String bookAbbrev;

  /// Chapter in the bundled Bible's numbering.
  final int chapter;

  /// Verses in the bundled Bible's numbering, in citation order. Empty when
  /// the citation points at a whole chapter ("Sl 110").
  final List<BibleVerseRange> verses;

  bool get isWholeChapter => verses.isEmpty;

  int get firstVerse => verses.isEmpty ? 1 : verses.first.start;

  bool containsVerse(int verse) =>
      verses.isEmpty || verses.any((r) => r.contains(verse));

  @override
  String toString() => isWholeChapter
      ? '$bookAbbrev $chapter'
      : '$bookAbbrev $chapter, ${verses.join('.')}';
}

/// A citation found in a text. Old translations are inconsistent ("Ecl" may be
/// Eclesiastes or Eclesiástico, "Jo" may be João or Jó, Psalms may follow the
/// Hebrew or the Vulgate numbering), so a citation carries every plausible
/// reading, most likely first. [resolve] picks the first one that exists.
final class BibleCitation {
  const BibleCitation({
    required this.candidates,
    required this.start,
    required this.end,
    required this.label,
  });

  final List<BibleReference> candidates;

  /// Offsets of the citation inside the source text (`end` exclusive).
  final int start;
  final int end;

  /// The citation exactly as written in the source text.
  final String label;

  BibleReference get primary => candidates.first;

  /// First candidate whose chapter has the cited first verse, according to
  /// [verseCount] (verses in a chapter, 0 when the chapter does not exist).
  /// Falls back to the first candidate whose chapter exists, then [primary].
  BibleReference resolve(int Function(String bookAbbrev, int chapter) verseCount) {
    for (final c in candidates) {
      if (verseCount(c.bookAbbrev, c.chapter) >= c.firstVerse) return c;
    }
    for (final c in candidates) {
      if (verseCount(c.bookAbbrev, c.chapter) > 0) return c;
    }
    return primary;
  }
}

final class BibleCitationParser {
  const BibleCitationParser({
    this.psalmNumbering = PsalmNumbering.vulgate,
    this.allowWholeChapter = false,
  });

  final PsalmNumbering psalmNumbering;

  /// Also link chapter-only references ("Sl 110", "Salmo 134 (133)"). Off for
  /// free text, where "Os 3" or "Is 2" could be ordinary words; on for
  /// dedicated reference fields.
  final bool allowWholeChapter;

  static final RegExp _wholeChapter = RegExp(
    r'(?<![\p{L}\p{N}])'
    r'(?:(?<num>III|II|I|[1-3])\s?)?'
    r'(?<book>\p{Lu}\p{Ll}{0,5})\.?\s'
    r'(?<ch>\d{1,3})'
    r'(?![\p{L}\p{N}]|\s?[,:]\s?\d)',
    unicode: true,
  );

  static final RegExp _pattern = RegExp(
    r'(?<![\p{L}\p{N}])'
    r'(?:(?<num>III|II|I|[1-3])\s?)?'
    r'(?<book>\p{Lu}\p{Ll}{0,5})\.?\s'
    r'(?<ch>\d{1,3})\s?[,:]\s?'
    r'(?<v1>\d{1,3})[a-z]?(?:\s?[-–]\s?(?<v2>\d{1,3})[a-z]?)?'
    r'(?<more>(?:\s?\.\s?\d{1,3}[a-z]?(?:\s?[-–]\s?\d{1,3}[a-z]?)?)*)'
    r'(?![\p{L}\p{N}])',
    unicode: true,
  );

  static final RegExp _extraVerse = RegExp(
    r'(\d{1,3})[a-z]?(?:\s?[-–]\s?(\d{1,3}))?',
  );

  List<BibleCitation> parse(String text) {
    final citations = <BibleCitation>[];
    for (final match in _pattern.allMatches(text)) {
      final ordinal = _ordinal(match.namedGroup('num'));
      final chapter = int.parse(match.namedGroup('ch')!);
      final books = resolveBooks(
        ordinal: ordinal,
        book: match.namedGroup('book')!,
        chapter: chapter,
      );
      if (books.isEmpty || chapter == 0) continue;

      final v1 = int.parse(match.namedGroup('v1')!);
      final v2 = int.tryParse(match.namedGroup('v2') ?? '');
      final ranges = <BibleVerseRange>[
        if (v1 > 0) BibleVerseRange(v1, v2 != null && v2 >= v1 ? v2 : v1),
      ];
      for (final extra in _extraVerse.allMatches(match.namedGroup('more')!)) {
        final s = int.parse(extra.group(1)!);
        final e = int.tryParse(extra.group(2) ?? '');
        if (s > 0) ranges.add(BibleVerseRange(s, e != null && e >= s ? e : s));
      }
      if (ranges.isEmpty) continue;

      final candidates = <BibleReference>[];
      for (final abbrev in books) {
        if (abbrev == 'Ps') {
          final asWritten = BibleReference(
            bookAbbrev: 'Ps',
            chapter: chapter,
            verses: ranges,
          );
          final converted = _hebrewToVulgatePsalm(chapter, ranges);
          final fromHebrew = BibleReference(
            bookAbbrev: 'Ps',
            chapter: converted.chapter,
            verses: converted.verses,
          );
          candidates.addAll(
            psalmNumbering == PsalmNumbering.hebrew
                ? [fromHebrew, asWritten]
                : [asWritten, fromHebrew],
          );
        } else {
          candidates.add(
            BibleReference(bookAbbrev: abbrev, chapter: chapter, verses: ranges),
          );
        }
      }

      // Trim trailing punctuation captured by `more` (e.g. "Hb. 10, 5. 9.").
      var end = match.end;
      while (end > match.start && '. '.contains(text[end - 1])) {
        end--;
      }

      citations.add(
        BibleCitation(
          candidates: candidates,
          start: match.start,
          end: end,
          label: text.substring(match.start, end),
        ),
      );
    }
    if (allowWholeChapter) {
      for (final match in _wholeChapter.allMatches(text)) {
        if (citations.any((c) => match.start < c.end && c.start < match.end)) {
          continue;
        }
        final chapter = int.parse(match.namedGroup('ch')!);
        final books = resolveBooks(
          ordinal: _ordinal(match.namedGroup('num')),
          book: match.namedGroup('book')!,
          chapter: chapter,
        );
        if (books.isEmpty || chapter == 0) continue;
        final candidates = <BibleReference>[];
        for (final abbrev in books) {
          final hebrew = abbrev == 'Ps'
              ? _hebrewToVulgatePsalm(chapter, const [BibleVerseRange(1)])
                    .chapter
              : chapter;
          final options = abbrev == 'Ps' &&
                  psalmNumbering == PsalmNumbering.hebrew
              ? [hebrew, chapter]
              : [chapter, hebrew];
          for (final ch in options.toSet()) {
            candidates.add(
              BibleReference(bookAbbrev: abbrev, chapter: ch, verses: const []),
            );
          }
        }
        citations.add(
          BibleCitation(
            candidates: candidates,
            start: match.start,
            end: match.end,
            label: text.substring(match.start, match.end),
          ),
        );
      }
      citations.sort((a, b) => a.start.compareTo(b.start));
    }
    return citations;
  }

  /// Maps a written book abbreviation (with its ordinal, if any) to the
  /// bundled Bible's abbreviations, most likely first. Empty when it is not a
  /// Bible book.
  static List<String> resolveBooks({
    required int? ordinal,
    required String book,
    required int chapter,
  }) {
    final key = book.toLowerCase();
    if (ordinal != null) {
      final base = _numberedBooks[key];
      if (base == null) return const [];
      final abbrev = '$ordinal$base';
      return _validNumbered.contains(abbrev) ? [abbrev] : const [];
    }
    final primary = _books[key];
    if (primary == null) return const [];
    final alternative = _ambiguous[key];
    return alternative == null ? [primary] : [primary, alternative];
  }

  static int? _ordinal(String? raw) => switch (raw) {
    null => null,
    '1' || 'I' => 1,
    '2' || 'II' => 2,
    '3' || 'III' => 3,
    _ => null,
  };

  /// Converts a Hebrew-numbered psalm reference to the Vulgate numbering of
  /// the bundled Bible. Psalm 9/10 and 114/115 are merged in the Vulgate;
  /// 116 and 147 are split.
  static ({int chapter, List<BibleVerseRange> verses}) _hebrewToVulgatePsalm(
    int chapter,
    List<BibleVerseRange> verses,
  ) {
    List<BibleVerseRange> shift(int delta) => [
      for (final r in verses) BibleVerseRange(r.start + delta, r.end + delta),
    ];

    if (chapter <= 8 || chapter >= 148) {
      return (chapter: chapter, verses: verses);
    }
    if (chapter == 9) return (chapter: 9, verses: verses);
    // Hebrew 10 continues Vulgate 9 (which has 21 verses before it).
    if (chapter == 10) return (chapter: 9, verses: shift(21));
    if (chapter <= 113) return (chapter: chapter - 1, verses: verses);
    if (chapter == 114) return (chapter: 113, verses: verses);
    // Hebrew 115 continues Vulgate 113 (Hebrew 114 has 8 verses).
    if (chapter == 115) return (chapter: 113, verses: shift(8));
    if (chapter == 116) {
      return verses.first.start >= 10
          ? (chapter: 115, verses: shift(-9))
          : (chapter: 114, verses: verses);
    }
    if (chapter <= 146) return (chapter: chapter - 1, verses: verses);
    // chapter == 147
    return verses.first.start >= 12
        ? (chapter: 147, verses: shift(-11))
        : (chapter: 146, verses: verses);
  }
}

/// Unnumbered books: written forms (lower-case) → bundled abbreviation.
const Map<String, String> _books = {
  // Pentateuco e históricos
  'gn': 'Gn', 'gên': 'Gn', 'gen': 'Gn',
  'ex': 'Ex', 'êx': 'Ex',
  'lv': 'Lv', 'lev': 'Lv',
  'nm': 'Nm', 'num': 'Nm',
  'dt': 'Dt', 'deut': 'Dt',
  'js': 'Js', 'jos': 'Js',
  'jz': 'Ju', 'jd': 'Jda', 'jui': 'Ju', 'juí': 'Ju',
  'rt': 'Rt',
  'esd': 'Esd',
  'ne': 'Ne', 'ns': 'Ne',
  'tb': 'Tob', 'tob': 'Tob',
  'jt': 'Jdi', 'jdt': 'Jdi', 'jdi': 'Jdi',
  'est': 'Est', 'et': 'Est',
  // Sapienciais
  'jó': 'Job', 'job': 'Job',
  'sl': 'Ps', 'sal': 'Ps', 'ps': 'Ps', 'salmo': 'Ps',
  'pr': 'Pv', 'pv': 'Pv', 'prov': 'Pv',
  'ecl': 'Ees', 'ec': 'Ees', 'coh': 'Ees', 'qo': 'Ees',
  'ct': 'Cc', 'cant': 'Cc', 'cânt': 'Cc',
  'sb': 'Sa', 'sab': 'Sa',
  'eclo': 'Eus', 'sir': 'Eus',
  // Profetas
  'is': 'Is', 'isa': 'Is',
  'jr': 'Je', 'jer': 'Je', 'je': 'Je',
  'lm': 'Lm', 'lam': 'Lm',
  'br': 'Ba', 'bar': 'Ba',
  'ez': 'Ez',
  'dn': 'Dn', 'dan': 'Dn',
  'os': 'Os',
  'jl': 'Jl', 'joel': 'Jl',
  'am': 'Am',
  'ab': 'Ab', 'abd': 'Ab',
  'jn': 'Jn', 'jon': 'Jn',
  'mq': 'Mic', 'miq': 'Mic', 'mic': 'Mic',
  'na': 'Na', 'naum': 'Na',
  'hab': 'Hc', 'hc': 'Hc',
  'sf': 'So', 'sof': 'So',
  'ag': 'Ag',
  'zc': 'Zc', 'zac': 'Zc',
  'ml': 'Ml', 'mal': 'Ml',
  // Evangelhos e Atos
  'mt': 'Mt',
  'mc': 'Mc',
  'lc': 'Lc',
  'jo': 'Jo',
  'at': 'Act', 'act': 'Act', 'atos': 'Act',
  // Epístolas
  'rm': 'Rm', 'rom': 'Rm',
  'gl': 'Gl', 'gal': 'Gl',
  'ef': 'Ef', 'efés': 'Ef',
  'fl': 'Fp', 'fp': 'Fp', 'fil': 'Fp', 'filp': 'Fp', 'filip': 'Fp',
  'cl': 'Cl', 'col': 'Cl',
  'tt': 'Tt', 'tit': 'Tt',
  'fm': 'Fm', 'flm': 'Fm',
  'hb': 'Hb', 'heb': 'Hb',
  'tg': 'Tg',
  'ap': 'Ap',
};

/// Abbreviations that older translations use for two different books: the
/// alternative is tried when the primary reading does not exist.
const Map<String, String> _ambiguous = {
  'ecl': 'Eus', // Eclesiastes / Eclesiástico (Santo Afonso)
  'ec': 'Eus',
  'jo': 'Job', // João / Jó without the accent
  'jd': 'Ju', // Judas / Juízes
  'eclo': 'Ees',
};

/// Numbered books: written stem (lower-case) → bundled stem, prefixed by the
/// ordinal.
const Map<String, String> _numberedBooks = {
  'sm': 'Sm', 'sam': 'Sm',
  'rs': 'Rs', 're': 'Rs', 'reis': 'Rs',
  'cr': 'Pa', 'crôn': 'Pa', 'par': 'Pa',
  'mc': 'Ma', 'mac': 'Ma', 'ma': 'Ma',
  'cor': 'Co', 'co': 'Co',
  'ts': 'Ts', 'tes': 'Ts', 'tess': 'Ts',
  'tm': 'Tm', 'tim': 'Tm',
  'pd': 'Pe', 'pe': 'Pe', 'ped': 'Pe',
  'jo': 'Jo',
};

const Set<String> _validNumbered = {
  '1Sm', '2Sm', '1Rs', '2Rs', '1Pa', '2Pa', '1Ma', '2Ma', //
  '1Co', '2Co', '1Ts', '2Ts', '1Tm', '2Tm', '1Pe', '2Pe', //
  '1Jo', '2Jo', '3Jo',
};
