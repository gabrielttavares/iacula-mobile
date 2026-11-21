import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/bible/domain/bible_citation.dart';

void main() {
  const parser = BibleCitationParser();

  BibleCitation single(String text, [BibleCitationParser p = parser]) {
    final found = p.parse(text);
    expect(found, hasLength(1), reason: text);
    return found.single;
  }

  group('BibleCitationParser', () {
    test('parses a simple parenthesised citation with offsets', () {
      const text = 'se não conheço varão? (Lc 1, 34). A voz';
      final c = single(text);
      expect(c.primary.bookAbbrev, 'Lc');
      expect(c.primary.chapter, 1);
      expect(c.primary.verses, [const BibleVerseRange(34)]);
      expect(c.label, 'Lc 1, 34');
      expect(text.substring(c.start, c.end), 'Lc 1, 34');
    });

    test('parses verse ranges and extra verses', () {
      expect(single('(Jo 19, 5-6)').primary.verses, [const BibleVerseRange(5, 6)]);
      expect(single('(Nm 14,22-23)').primary.verses, [const BibleVerseRange(22, 23)]);
      final c = single('(Hb. 10, 5. 9.) Vós');
      expect(c.primary.bookAbbrev, 'Hb');
      expect(c.primary.verses, [const BibleVerseRange(5), const BibleVerseRange(9)]);
      expect(c.label, 'Hb. 10, 5. 9');
    });

    test('maps aliases to the bundled Bible abbreviations', () {
      expect(single('(Sl 39,9)').primary.bookAbbrev, 'Ps');
      expect(single('(At 1, 9)').primary.bookAbbrev, 'Act');
      expect(single('(Ecl 9, 10)').primary.bookAbbrev, 'Ees');
      expect(single('(Eclo 35, 21)').primary.bookAbbrev, 'Eus');
      expect(single('(Ct 4,11)').primary.bookAbbrev, 'Cc');
      expect(single('(Sb 8, 21)').primary.bookAbbrev, 'Sa');
      expect(single('(Jr 33, 3)').primary.bookAbbrev, 'Je');
      expect(single('(Fl 4, 13)').primary.bookAbbrev, 'Fp');
      expect(single('(Jó 42, 8)').primary.bookAbbrev, 'Job');
      expect(single('(Jo 3, 16)').primary.bookAbbrev, 'Jo');
    });

    test('handles numbered books with arabic and roman ordinals', () {
      expect(single('(1Cor 12, 6)').primary.bookAbbrev, '1Co');
      expect(single('(1 Cor 10, 13)').primary.bookAbbrev, '1Co');
      expect(single('(II Cor 12, 9)').primary.bookAbbrev, '2Co');
      expect(single('(I Sm 14, 45)').primary.bookAbbrev, '1Sm');
      expect(single('(1Pd 4,18)').primary.bookAbbrev, '1Pe');
      expect(single('(2Mc 7,28)').primary.bookAbbrev, '2Ma');
      expect(single('(II Cr 30,9)').primary.bookAbbrev, '2Pa');
      expect(single('(1 Re 18,37)').primary.bookAbbrev, '1Rs');
    });

    test('resolves ambiguous abbreviations against the Bible', () {
      // verse counts: Ees 3 has 22 verses, Eus 3 has 34; Jo 21 chapters; Job 42.
      int count(String b, int ch) => switch ((b, ch)) {
        ('Ees', 3) => 22,
        ('Eus', 3) => 34,
        ('Ees', 9) => 18,
        ('Jo', 3) => 36,
        ('Job', 31) => 40,
        ('Ju', 8) => 35,
        ('Jda', 1) => 25,
        ('Ps', 118) => 176,
        ('Ps', 119) => 7,
        _ => 0,
      };
      String at(String text, [BibleCitationParser p = parser]) {
        final r = single(text, p).resolve(count);
        return '${r.bookAbbrev} ${r.chapter},${r.firstVerse}';
      }

      expect(at('(Ecl 9, 10)'), 'Ees 9,10');
      expect(at('(Ecl 3,27)'), 'Eus 3,27');
      expect(at('(Jo 3, 16)'), 'Jo 3,16');
      expect(at('(Jo 31,14)'), 'Job 31,14');
      expect(at('(Jd 8, 27)'), 'Ju 8,27');
      expect(at('(Jd 1, 3)'), 'Jda 1,3');
      // Imitação mixes numberings: Hebrew 119,94 = Vulgate 118,94.
      expect(at('(Sl 119, 94)'), 'Ps 118,94');
      expect(at('(Sl 119, 5)'), 'Ps 119,5');
    });

    test('finds every citation in a list', () {
      final found = parser.parse('(Mt 25,41.46; 2Ts 1,8; Mc 9,48)');
      expect(found.map((c) => c.primary.bookAbbrev), ['Mt', '2Ts', 'Mc']);
      expect(found.first.primary.verses, [
        const BibleVerseRange(41),
        const BibleVerseRange(46),
      ]);
    });

    test('ignores non-biblical references and plain numbers', () {
      expect(parser.parse('(Sto. Tomás, em III Sen. Dist. 26, 6)'), isEmpty);
      expect(parser.parse('Capítulo 3, versão 2, 4'), isEmpty);
      expect(parser.parse('Os 3 apóstolos'), isEmpty);
      expect(parser.parse('MtX 1, 2'), isEmpty);
    });

    test('converts Hebrew psalm numbering when asked', () {
      const hebrew = BibleCitationParser(psalmNumbering: PsalmNumbering.hebrew);
      BibleReference h(String t) => single(t, hebrew).primary;
      expect(h('(Sal 119,105)').chapter, 118);
      expect(h('(Sal 119,105)').verses, [const BibleVerseRange(105)]);
      expect(h('(Sal 23, 1)').chapter, 22);
      expect(h('(Sal 10, 1)').firstVerse, 22);
      expect(h('(Sal 116, 12)').chapter, 115);
      expect(h('(Sal 116, 12)').firstVerse, 3);
      expect(h('(Sal 147, 12)').chapter, 147);
      expect(h('(Sal 147, 12)').firstVerse, 1);
      // Vulgate is the default and leaves numbers alone.
      expect(single('(Sl 118, 105)').primary.chapter, 118);
    });
  });

  group('whole-chapter references (liturgy fields)', () {
    const liturgy = BibleCitationParser(
      psalmNumbering: PsalmNumbering.hebrew,
      allowWholeChapter: true,
    );

    test('links chapter-only references, Hebrew psalms first', () {
      final c = liturgy.parse('Sl 110').single;
      expect(c.primary.bookAbbrev, 'Ps');
      expect(c.primary.chapter, 109);
      expect(c.primary.isWholeChapter, isTrue);
      expect(liturgy.parse('Salmo 134 (133)').single.primary.chapter, 133);
      expect(liturgy.parse('Sl 63,2-9').single.primary.chapter, 62);
      expect(liturgy.parse('1Ts 5,9-10').single.primary.bookAbbrev, '1Ts');
    });

    test('free text never links chapter-only mentions', () {
      expect(parser.parse('Os 3 apóstolos e Sl 110'), isEmpty);
    });
  });

  group('library corpus', () {
    test('every detected citation exists in the bundled Bible', () {
      final bible = _loadBible();
      final failures = <String>[];
      var total = 0;

      for (final file in _bookFiles()) {
        final id = file.uri.pathSegments.last.replaceAll('.json', '');
        final p = BibleCitationParser(
          psalmNumbering: hebrewPsalmWorks.contains(id)
              ? PsalmNumbering.hebrew
              : PsalmNumbering.vulgate,
        );
        for (final text in _strings(jsonDecode(file.readAsStringSync()))) {
          for (final c in p.parse(text)) {
            total++;
            final r = c.resolve((b, ch) => bible[b]?[ch] ?? 0);
            final ok = (bible[r.bookAbbrev]?[r.chapter] ?? 0) >= r.firstVerse;
            if (!ok) failures.add('$id: "${c.label}" → $r');
          }
        }
      }

      // Print for visibility when tuning the alias table.
      // ignore: avoid_print
      print('citations: $total, unresolved: ${failures.length}');
      for (final f in failures) {
        // ignore: avoid_print
        print('  $f');
      }
      expect(total, greaterThan(1000));
      // A handful of source typos remain (e.g. wrong chapter in the original);
      // they open the chapter screen instead of a verse.
      expect(failures.length, lessThan(total * 0.02));
    });
  });
}

/// Works that cite the Psalms by the Hebrew numbering. Keep in sync with
/// `book_reader_page.dart`.
const hebrewPsalmWorks = {'compendio-catecismo-da-igreja-catolica'};

Iterable<File> _bookFiles() sync* {
  for (final dir in ['assets/books/escriva', 'assets/books/library/works']) {
    yield* Directory(dir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json') && !f.path.endsWith('index.json'));
  }
}

Iterable<String> _strings(Object? node) sync* {
  if (node is String) {
    yield node;
  } else if (node is Map) {
    for (final v in node.values) {
      yield* _strings(v);
    }
  } else if (node is List) {
    for (final v in node) {
      yield* _strings(v);
    }
  }
}

/// abbrev → chapter → highest verse number (the data has a few gaps).
Map<String, Map<int, int>> _loadBible() {
  final books = jsonDecode(
    File('assets/seed/bible/listalivros.json').readAsStringSync(),
  ) as List;
  final result = <String, Map<int, int>>{};
  for (final b in books) {
    final abbrev = (b as Map)['livro'] as String;
    final name = abbrev.toLowerCase();
    var file = File('assets/seed/bible/antigotestamento/$name.json');
    if (!file.existsSync()) {
      file = File('assets/seed/bible/novotestamento/$name.json');
    }
    final data = jsonDecode(file.readAsStringSync()) as Map;
    result[abbrev] = {
      for (final ch in data['capitulos'] as List)
        (ch as Map)['capitulo'] as int: (ch['versiculos'] as List)
            .map((v) => (v as Map)['numero'] as int)
            .fold(0, (a, b) => a > b ? a : b),
    };
  }
  return result;
}
