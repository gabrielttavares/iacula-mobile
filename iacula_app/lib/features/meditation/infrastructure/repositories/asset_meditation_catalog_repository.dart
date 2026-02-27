import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/meditation_item.dart';
import '../../domain/repositories/meditation_catalog_repository.dart';

final class AssetMeditationCatalogRepository
    implements MeditationCatalogRepository {
  AssetMeditationCatalogRepository({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<MeditationItem>? _cache;

  Future<List<MeditationItem>> _load() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await _bundle
          .loadString('assets/seed/meditations/catalog.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _cache = list
          .map((e) => MeditationItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      _cache = const [];
    }
    return _cache!;
  }

  @override
  Future<List<MeditationItem>> listAll() => _load();

  @override
  Future<List<MeditationItem>> listByCategory(String category) async {
    final all = await _load();
    return all
        .where((item) => item.categoryTags.contains(category))
        .toList(growable: false);
  }

  @override
  Future<List<MeditationItem>> listByType(MeditationType type) async {
    final all = await _load();
    return all
        .where((item) => item.type == type)
        .toList(growable: false);
  }

  @override
  Future<MeditationItem?> getById(String id) async {
    final all = await _load();
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
