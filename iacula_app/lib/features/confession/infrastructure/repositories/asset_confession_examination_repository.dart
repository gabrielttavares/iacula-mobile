import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/confession_examination_item.dart';
import '../../domain/repositories/confession_examination_repository.dart';

typedef ConfessionExaminationAssetLoader = Future<String> Function(String path);

final class AssetConfessionExaminationRepository
    implements ConfessionExaminationRepository {
  AssetConfessionExaminationRepository({
    ConfessionExaminationAssetLoader? loadAsset,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  static const _assetPath =
      'assets/seed/examination/confession_examination_items.json';

  final ConfessionExaminationAssetLoader _loadAsset;

  List<ConfessionExaminationItem>? _cache;

  @override
  Future<List<ConfessionExaminationItem>> listAll() async {
    if (_cache != null) {
      return _cache!;
    }

    final raw = await _loadAsset(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    final items =
        decoded
            .map(
              (item) => ConfessionExaminationItem.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    _cache = List<ConfessionExaminationItem>.unmodifiable(items);
    return _cache!;
  }
}
