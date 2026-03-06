import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/journal_prompts/domain/entities/journal_prompt.dart';
import 'package:iacula_app/features/journal_prompts/infrastructure/repositories/asset_journal_prompt_repository.dart';

final class _TestBundle extends CachingAssetBundle {
  _TestBundle(this._data);

  final Map<String, String> _data;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _data[key];
    if (value == null) throw Exception('Asset not found: $key');
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

void main() {
  test('listAll flattens all prompt categories', () async {
    final bundle = _TestBundle({
      'assets/seed/journal_prompts/prompts.json': jsonEncode({
        'liturgical': ['L1', 'L2'],
        'ignatian': ['I1'],
        'lectio_divina': ['D1'],
        'general': ['G1', 'G2'],
      }),
    });

    final repository = AssetJournalPromptRepository(bundle: bundle);
    final prompts = await repository.listAll();

    expect(prompts, hasLength(6));
    expect(
      prompts.where((p) => p.category == JournalPromptCategory.liturgical),
      hasLength(2),
    );
    expect(
      prompts.where((p) => p.category == JournalPromptCategory.ignatian),
      hasLength(1),
    );
    expect(
      prompts.where((p) => p.category == JournalPromptCategory.lectioDivina),
      hasLength(1),
    );
    expect(
      prompts.where((p) => p.category == JournalPromptCategory.general),
      hasLength(2),
    );
  });

  test('listAll returns empty list when JSON is invalid', () async {
    final repository = AssetJournalPromptRepository(
      bundle: _TestBundle({
        'assets/seed/journal_prompts/prompts.json': 'not-json',
      }),
    );

    expect(await repository.listAll(), isEmpty);
  });

  test('listAll returns empty list when asset is missing', () async {
    final repository = AssetJournalPromptRepository(bundle: _TestBundle({}));

    expect(await repository.listAll(), isEmpty);
  });
}
