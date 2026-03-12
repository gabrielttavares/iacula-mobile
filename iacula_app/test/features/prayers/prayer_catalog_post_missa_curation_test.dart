import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('post-Mass curation keeps only context-appropriate saint prayers there', () async {
    final file = File('assets/seed/prayers/pt-br/oracoes_catalog.json');
    final payload = jsonDecode(await file.readAsString()) as List<dynamic>;
    final entries = <String, Map<String, dynamic>>{};

    for (final item in payload) {
      if (item is Map<String, dynamic>) {
        final id = item['id'];
        if (id is String && id.isNotEmpty) {
          entries[id] = item;
        }
      }
    }

    expect(entries['fica-comigo-senhor'], isNotNull);
    expect(entries['fica-comigo-senhor']!['section_id'], 'acao-de-gracas-santa-missa');
    expect(entries['fica-comigo-senhor']!['section_title'], 'Ação de Graças depois da Santa Missa');
    expect(entries['fica-comigo-senhor']!['saints'], contains('padre-pio'));
    expect(entries['fica-comigo-senhor']!['theme'], contains('missa-acao-de-gracas'));

    for (final id in const [
      'oracao-a-sao-paulo',
      'oracao-sao-boaventura',
      'oracao-sao-francisco',
      'oracao-aos-pastores-de-fatima',
    ]) {
      expect(entries[id], isNotNull, reason: 'missing curated entry: $id');
      expect(entries[id]!['section_id'], 'oracoes-diversas', reason: 'expected $id to leave post-Mass section');
      expect(entries[id]!['section_title'], 'Orações Diversas');
    }

    expect(entries['oracao-do-padre-pio'], isNotNull);
    expect(entries['oracao-do-padre-pio']!['section_id'], 'acao-de-gracas-santa-missa');

    expect(entries['oracao-de-sao-bento'], isNotNull);
    expect(entries['oracao-de-sao-bento']!['section_id'], 'oracoes-diversas');
  });

  test('details exist for curated saint prayers that should not fallback', () {
    for (final slug in const [
      'fica-comigo-senhor',
      'oracao-do-padre-pio',
      'oracao-de-sao-bento',
    ]) {
      expect(
        File('assets/seed/prayers/details/$slug.json').existsSync(),
        isTrue,
        reason: 'missing detail file for $slug',
      );
    }
  });
}
