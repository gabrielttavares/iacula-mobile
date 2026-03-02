import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/compline_day.dart';

final class AssetComplineRepository {
  List<ComplineDay>? _cache;

  Future<List<ComplineDay>> listAll() async {
    if (_cache != null) return _cache!;

    final raw =
        await rootBundle.loadString('assets/seed/night_prayer/compline.json');
    final List<dynamic> decoded = jsonDecode(raw) as List;
    _cache = decoded
        .map((e) => ComplineDay.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<ComplineDay?> getForDay(int dayOfWeek) async {
    final all = await listAll();
    // Use Sunday Compline as fallback
    return all.where((d) => d.dayOfWeek == dayOfWeek).firstOrNull ??
        all.firstOrNull;
  }
}
