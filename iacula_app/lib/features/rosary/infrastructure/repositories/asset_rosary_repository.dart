import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/rosary_mystery_set.dart';
import '../../domain/repositories/rosary_repository.dart';

final class AssetRosaryRepository implements RosaryRepository {
  List<RosaryMysterySet>? _cache;

  @override
  Future<List<RosaryMysterySet>> listAll() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/seed/rosary/mysteries.json');
    final List<dynamic> decoded = jsonDecode(raw) as List;
    _cache = decoded
        .map((e) => RosaryMysterySet.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  @override
  Future<RosaryMysterySet?> getMysterySet(RosaryMysteryType type) async {
    final all = await listAll();
    return all.where((s) => s.type == type).firstOrNull;
  }
}
