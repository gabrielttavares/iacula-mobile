import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';
import 'package:iacula_app/features/meditation/infrastructure/repositories/asset_meditation_catalog_repository.dart';

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
  test('listAll parses catalog JSON and returns items', () async {
    final catalog = [
      {
        'id': 'v1',
        'type': 'video',
        'title': 'Video One',
        'summary': 'Summary',
        'durationSec': 300,
        'categoryTags': ['espiritual'],
        'sourceName': 'Source',
        'availability': {'kind': 'evergreen'},
        'provenance': {'providerId': 'p', 'providerType': 'channel'},
      },
      {
        'id': 't1',
        'type': 'text',
        'title': 'Text One',
        'summary': 'Summary',
        'categoryTags': ['diário'],
        'sourceName': 'Source',
        'availability': {'kind': 'daily', 'timezone': 'America/Sao_Paulo'},
        'textContent': {
          'body': 'Body text',
          'format': 'plain',
          'language': 'pt',
        },
        'provenance': {'providerId': 'p', 'providerType': 'daily_text'},
      },
    ];

    final bundle = _TestBundle({
      'assets/seed/meditations/catalog.json': jsonEncode(catalog),
    });

    final repo = AssetMeditationCatalogRepository(bundle: bundle);
    final items = await repo.listAll();

    expect(items, hasLength(2));
    expect(items[0].type, MeditationType.video);
    expect(items[1].type, MeditationType.text);
  });

  test('listByCategory filters by tag', () async {
    final catalog = [
      {
        'id': 'v1',
        'type': 'video',
        'title': 'V',
        'summary': 'S',
        'categoryTags': ['espiritual'],
        'sourceName': 'S',
        'availability': {'kind': 'evergreen'},
        'provenance': {'providerId': 'p', 'providerType': 'channel'},
      },
      {
        'id': 'v2',
        'type': 'audio',
        'title': 'A',
        'summary': 'S',
        'categoryTags': ['foco'],
        'sourceName': 'S',
        'availability': {'kind': 'evergreen'},
        'provenance': {'providerId': 'p', 'providerType': 'channel'},
      },
    ];

    final bundle = _TestBundle({
      'assets/seed/meditations/catalog.json': jsonEncode(catalog),
    });

    final repo = AssetMeditationCatalogRepository(bundle: bundle);

    final spiritual = await repo.listByCategory('espiritual');
    expect(spiritual, hasLength(1));
    expect(spiritual.first.id, 'v1');

    final foco = await repo.listByCategory('foco');
    expect(foco, hasLength(1));
    expect(foco.first.id, 'v2');

    final empty = await repo.listByCategory('nonexistent');
    expect(empty, isEmpty);
  });

  test('listByType filters by content type', () async {
    final catalog = [
      {
        'id': 'v1',
        'type': 'video',
        'title': 'V',
        'summary': 'S',
        'categoryTags': <String>[],
        'sourceName': 'S',
        'availability': {'kind': 'evergreen'},
        'provenance': {'providerId': 'p', 'providerType': 'channel'},
      },
      {
        'id': 't1',
        'type': 'text',
        'title': 'T',
        'summary': 'S',
        'categoryTags': <String>[],
        'sourceName': 'S',
        'availability': {'kind': 'evergreen'},
        'textContent': {'body': 'B', 'format': 'plain', 'language': 'pt'},
        'provenance': {'providerId': 'p', 'providerType': 'daily_text'},
      },
    ];

    final bundle = _TestBundle({
      'assets/seed/meditations/catalog.json': jsonEncode(catalog),
    });

    final repo = AssetMeditationCatalogRepository(bundle: bundle);

    final videos = await repo.listByType(MeditationType.video);
    expect(videos, hasLength(1));

    final texts = await repo.listByType(MeditationType.text);
    expect(texts, hasLength(1));
  });

  test('getById returns item or null', () async {
    final catalog = [
      {
        'id': 'v1',
        'type': 'video',
        'title': 'V',
        'summary': 'S',
        'categoryTags': <String>[],
        'sourceName': 'S',
        'availability': {'kind': 'evergreen'},
        'provenance': {'providerId': 'p', 'providerType': 'channel'},
      },
    ];

    final bundle = _TestBundle({
      'assets/seed/meditations/catalog.json': jsonEncode(catalog),
    });

    final repo = AssetMeditationCatalogRepository(bundle: bundle);

    expect(await repo.getById('v1'), isNotNull);
    expect(await repo.getById('nonexistent'), isNull);
  });

  test('returns empty list when JSON is invalid', () async {
    final bundle = _TestBundle({
      'assets/seed/meditations/catalog.json': 'not valid json',
    });

    final repo = AssetMeditationCatalogRepository(bundle: bundle);
    final items = await repo.listAll();

    expect(items, isEmpty);
  });

  test('bundled catalog contains only text meditations', () async {
    final raw = File('assets/seed/meditations/catalog.json').readAsStringSync();
    final list = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();

    expect(list, isNotEmpty);
    expect(list.every((item) => item['type'] == 'text'), isTrue);
  });
}
