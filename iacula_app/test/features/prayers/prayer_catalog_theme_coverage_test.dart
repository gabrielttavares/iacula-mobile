import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pt-br prayer catalog covers all home thematic groups', () async {
    final file = File('assets/seed/prayers/pt-br/oracoes_catalog.json');
    final payload = jsonDecode(await file.readAsString()) as List<dynamic>;

    final expectedThemes = <String>{
      'estudos',
      'viagem',
      'matrimonio',
      'gestacao',
      'igreja',
    };

    final coveredThemes = <String>{};
    for (final item in payload) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final themes = item['theme'];
      if (themes is! List<dynamic>) {
        continue;
      }
      for (final theme in themes) {
        if (theme is String && expectedThemes.contains(theme)) {
          coveredThemes.add(theme);
        }
      }
    }

    expect(coveredThemes, expectedThemes);
  });
}
