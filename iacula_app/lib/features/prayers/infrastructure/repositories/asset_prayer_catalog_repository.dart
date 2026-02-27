import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/prayer_catalog_entry.dart';
import '../../domain/repositories/prayer_catalog_repository.dart';

typedef CatalogAssetLoader = Future<String> Function(String path);
typedef AvailableAssetsLoader = Future<Set<String>> Function();

final class AssetPrayerCatalogRepository implements PrayerCatalogRepository {
  AssetPrayerCatalogRepository({
    CatalogAssetLoader? loadAsset,
    AvailableAssetsLoader? loadAvailableAssets,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString,
       _loadAvailableAssets =
           loadAvailableAssets ?? _loadAvailableAssetsFromManifest;

  final CatalogAssetLoader _loadAsset;
  final AvailableAssetsLoader _loadAvailableAssets;

  @override
  Future<List<PrayerCatalogEntry>> listCatalog({
    required String language,
  }) async {
    try {
      final path = await _resolveCatalogPath(language);
      final content = await _loadAsset(path);
      final payload = jsonDecode(content);
      if (payload is! List<dynamic>) {
        return const <PrayerCatalogEntry>[];
      }

      final entries = <PrayerCatalogEntry>[];
      for (final item in payload) {
        final parsed = _parseEntry(item);
        if (parsed != null) {
          entries.add(parsed);
        }
      }

      return entries;
    } catch (_) {
      return const <PrayerCatalogEntry>[];
    }
  }

  PrayerCatalogEntry? _parseEntry(dynamic item) {
    if (item is! Map<String, dynamic>) {
      return null;
    }

    final id = item['id']?.toString().trim() ?? '';
    final title = item['title']?.toString().trim() ?? '';
    final content = item['content']?.toString().trim() ?? '';
    final themes = _parseTags(item, 'theme');
    final saints = _parseTags(item, 'saints');
    final availableLanguages = _parseTags(item, 'languages');
    final sectionId = item['section_id']?.toString().trim() ?? '';
    final sectionTitle = item['section_title']?.toString().trim() ?? '';

    if (id.isEmpty || title.isEmpty || content.isEmpty) {
      return null;
    }

    if (themes == null || saints == null || availableLanguages == null) {
      return null;
    }

    final resolvedSectionId = sectionId.isNotEmpty
        ? sectionId
        : (themes.isNotEmpty ? themes.first : 'geral');
    final resolvedSectionTitle = sectionTitle.isNotEmpty ? sectionTitle : title;

    return PrayerCatalogEntry(
      slug: id,
      title: title,
      content: content,
      themes: themes,
      saints: saints,
      sectionId: resolvedSectionId,
      sectionTitle: resolvedSectionTitle,
      availableLanguages: availableLanguages,
    );
  }

  List<String>? _parseTags(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) {
      return null;
    }

    final value = map[key];
    if (value is! List<dynamic>) {
      return null;
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  Future<String> _resolveCatalogPath(String language) async {
    final assets = await _loadAvailableAssets();
    final normalized = _normalizeLanguage(language);
    final preferred = 'assets/seed/prayers/$normalized/oracoes_catalog.json';

    if (assets.contains(preferred)) {
      return preferred;
    }

    const fallbacks = <String>[
      'assets/seed/prayers/pt-br/oracoes_catalog.json',
      'assets/seed/prayers/en/oracoes_catalog.json',
      'assets/seed/prayers/la/oracoes_catalog.json',
    ];

    for (final candidate in fallbacks) {
      if (assets.contains(candidate)) {
        return candidate;
      }
    }

    return preferred;
  }

  String _normalizeLanguage(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('_', '-');
    return switch (normalized) {
      'pt' => 'pt-br',
      'pt-br' => 'pt-br',
      'en' => 'en',
      'la' => 'la',
      _ => 'pt-br',
    };
  }

  static Future<Set<String>> _loadAvailableAssetsFromManifest() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().toSet();
  }
}
