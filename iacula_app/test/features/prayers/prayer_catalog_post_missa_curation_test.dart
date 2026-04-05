import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('post-Mass catalog keeps current curated mapping', () async {
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

    expect(entries['oracao-sao-boaventura'], isNotNull);
    expect(
      entries['oracao-sao-boaventura']!['section_id'],
      'acao-de-gracas-santa-missa',
    );
    expect(
      entries['oracao-sao-boaventura']!['section_title'],
      'Ação de Graças depois da Santa Missa',
    );
    expect(entries['oracao-sao-boaventura']!['saints'], contains('sao-boaventura'));
    expect(entries['oracao-sao-boaventura']!['theme'], contains('missa-acao-de-gracas'));

    expect(entries['oracao-de-sao-bento'], isNotNull);
    expect(entries['oracao-de-sao-bento']!['section_id'], 'oracoes-diversas');
  });

  test('details exist for current curated saint prayers', () {
    for (final slug in const [
      'oracao-sao-boaventura',
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
