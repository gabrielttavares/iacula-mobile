import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/domain/services/prayer_block_parser.dart';

void main() {
  const parser = PrayerBlockParser();

  group('PrayerBlockParser', () {
    test('versicle and response, with or without the legacy dot', () {
      final v = parser.parse('℣ O anjo do Senhor anunciou a Maria.');
      expect(v.kind, PrayerBlockKind.versicle);
      expect(v.plainText, 'O anjo do Senhor anunciou a Maria.');

      final r = parser.parse('℟. E Ela concebeu do Espírito Santo.');
      expect(r.kind, PrayerBlockKind.response);
      expect(r.plainText, 'E Ela concebeu do Espírito Santo.');
    });

    test('headings, rubrics and abbreviated prayer cues', () {
      expect(parser.parse('# Ato de fé').kind, PrayerBlockKind.heading);
      expect(parser.parse('# Ato de fé').plainText, 'Ato de fé');

      final rubric = parser.parse('*Todos dizem:*');
      expect(rubric.kind, PrayerBlockKind.rubric);
      expect(rubric.plainText, 'Todos dizem:');

      final cue = parser.parse(
        '_Pai-nosso, Ave-Maria, Glória._ *(três vezes)*',
      );
      expect(cue.kind, PrayerBlockKind.text);
      expect(cue.spans, [
        const PrayerSpan(PrayerSpanKind.cue, 'Pai-nosso, Ave-Maria, Glória.'),
        const PrayerSpan(PrayerSpanKind.text, ' '),
        const PrayerSpan(PrayerSpanKind.rubric, '(três vezes)'),
      ]);
    });

    test('inline response marks the people\'s part of a litany line', () {
      final line = parser.parse('São Miguel, ℟ rogai por nós.');
      expect(line.kind, PrayerBlockKind.text);
      expect(line.hasResponse, isTrue);
      expect(line.spans, [
        const PrayerSpan(PrayerSpanKind.text, 'São Miguel, '),
        const PrayerSpan(PrayerSpanKind.response, 'rogai por nós.'),
      ]);
    });

    test('plain prayer text keeps line breaks and asterisk-free content', () {
      final stanza = parser.parse(
        'A morrer crucificado,\nTeu Jesus é condenado',
      );
      expect(stanza.kind, PrayerBlockKind.text);
      expect(stanza.plainText, 'A morrer crucificado,\nTeu Jesus é condenado');
      expect(stanza.hasResponse, isFalse);
    });
  });

  group('prayer catalog markup', () {
    final files = Directory('assets/seed/prayers/details')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    test('every block is well formed', () {
      final problems = <String>[];
      for (final file in files) {
        final data = jsonDecode(file.readAsStringSync()) as Map;
        final slug = data['slug'];
        final blocks = (data['blocks'] as Map).cast<String, List>();
        for (final entry in blocks.entries) {
          for (final raw in entry.value.cast<String>()) {
            final where = '$slug/${entry.key}: $raw';
            if ('*'.allMatches(raw).length.isOdd) problems.add('odd *: $where');
            if (RegExp(r'(^|\s)_|_($|[\s.,])').allMatches(raw).length.isOdd) {
              problems.add('odd _: $where');
            }
            if (raw.startsWith('℣') && raw.substring(1).contains('℟')) {
              problems.add('℣ and ℟ in one block: $where');
            }
            if (RegExp(r'^[℣℟][.:]').hasMatch(raw)) {
              problems.add('legacy marker: $where');
            }
            if (RegExp(r'\b\w*[a-zà-ú][A-ZÀ-Ú]\w*\b').hasMatch(raw)) {
              problems.add('broken casing: $where');
            }
            if (raw.startsWith('..') || raw.startsWith('___')) {
              problems.add('import residue: $where');
            }
            expect(parser.parse(raw).plainText, isNotEmpty, reason: where);
          }
        }
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('litanies tell the people what to answer on every invocation', () {
      for (final slug in [
        'ladainha-de-nossa-senhora',
        'ladainha-de-todos-os-santos',
      ]) {
        final data =
            jsonDecode(
                  File(
                    'assets/seed/prayers/details/$slug.json',
                  ).readAsStringSync(),
                )
                as Map;
        final blocks = parser.parseAll(
          ((data['blocks'] as Map)['pt-br'] as List).cast<String>(),
        );
        final bareInvocations = <String>[];
        var cued = false;
        for (final b in blocks) {
          if (b.kind == PrayerBlockKind.rubric &&
              b.plainText.startsWith('A cada invocação')) {
            cued = true;
          } else if (b.kind == PrayerBlockKind.text &&
              !b.hasResponse &&
              b.plainText.endsWith(',') &&
              !cued) {
            bareInvocations.add(b.plainText);
          }
        }
        expect(bareInvocations, isEmpty, reason: slug);
      }
    });
  });
}
