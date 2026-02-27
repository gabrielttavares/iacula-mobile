import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/doctrine_entry.dart';
import '../../domain/repositories/doctrine_repository.dart';

typedef CatalogAssetLoader = Future<String> Function(String path);
typedef AvailableAssetsLoader = Future<Set<String>> Function();

final class AssetDoctrineRepository implements DoctrineRepository {
  AssetDoctrineRepository({
    CatalogAssetLoader? loadAsset,
    AvailableAssetsLoader? loadAvailableAssets,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString,
       _loadAvailableAssets =
           loadAvailableAssets ?? _loadAvailableAssetsFromManifest;

  final CatalogAssetLoader _loadAsset;
  final AvailableAssetsLoader _loadAvailableAssets;

  @override
  Future<List<DoctrineEntry>> listCatalog({required String language}) async {
    try {
      final path = await _resolveCatalogPath(language);
      final content = await _loadAsset(path);
      final payload = jsonDecode(content);
      if (payload is! List<dynamic>) {
        return const <DoctrineEntry>[];
      }

      final entries = <DoctrineEntry>[];
      for (final item in payload) {
        final parsed = _parseEntry(item);
        if (parsed != null) {
          entries.add(parsed);
        }
      }

      return entries;
    } catch (_) {
      return const <DoctrineEntry>[];
    }
  }

  DoctrineEntry? _parseEntry(dynamic item) {
    if (item is! Map<String, dynamic>) {
      return null;
    }

    final id = item['id']?.toString().trim() ?? '';
    final title = item['title']?.toString().trim() ?? '';
    final content = item['content']?.toString().trim() ?? '';
    final category = item['category']?.toString().trim() ?? '';

    if (id.isEmpty || title.isEmpty || content.isEmpty) {
      return null;
    }

    return DoctrineEntry(
      slug: id,
      title: title,
      content: content,
      category: category,
    );
  }

  Future<String> _resolveCatalogPath(String language) async {
    final assets = await _loadAvailableAssets();
    final normalized = _normalizeLanguage(language);
    final preferred =
        'assets/seed/doctrina/$normalized/doctrina_catalog.json';

    if (assets.contains(preferred)) {
      return preferred;
    }

    const fallbacks = <String>[
      'assets/seed/doctrina/pt-br/doctrina_catalog.json',
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
