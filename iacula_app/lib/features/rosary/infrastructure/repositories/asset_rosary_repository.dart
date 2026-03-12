import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/rosary_mystery_set.dart';
import '../../domain/entities/rosary_final_prayers.dart';
import '../../domain/entities/rosary_initial_prayers.dart';
import '../../domain/repositories/rosary_repository.dart';

final class AssetRosaryRepository implements RosaryRepository {
  List<RosaryMysterySet>? _cache;
  final Map<String, RosaryCompletionPrayers> _completionPrayersCache =
      <String, RosaryCompletionPrayers>{};
  RosaryCompletionPrayers? _allCompletionPrayers;

  final Map<String, RosaryInitialPrayers> _initialPrayersCache =
      <String, RosaryInitialPrayers>{};
  RosaryInitialPrayers? _allInitialPrayers;

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

  @override
  Future<RosaryCompletionPrayers> getCompletionPrayers({
    required String language,
  }) async {
    final normalizedLanguage = language.trim().toLowerCase();
    if (_completionPrayersCache.containsKey(normalizedLanguage)) {
      return _completionPrayersCache[normalizedLanguage]!;
    }

    if (_allCompletionPrayers == null) {
      try {
        final raw = await rootBundle.loadString(
          'assets/seed/rosary/final_prayers.json',
        );
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _allCompletionPrayers = RosaryCompletionPrayers.fromJson(decoded);
      } catch (_) {
        return RosaryCompletionPrayers.empty();
      }
    }

    final prayersForLanguage = RosaryCompletionPrayers(
      pages: {
        normalizedLanguage: _allCompletionPrayers!.pagesForLanguage(
          normalizedLanguage,
        ),
      },
    );

    _completionPrayersCache[normalizedLanguage] = prayersForLanguage;
    return prayersForLanguage;
  }

  @override
  Future<RosaryInitialPrayers> getInitialPrayers({
    required String language,
  }) async {
    final normalizedLanguage = language.trim().toLowerCase();
    if (_initialPrayersCache.containsKey(normalizedLanguage)) {
      return _initialPrayersCache[normalizedLanguage]!;
    }

    if (_allInitialPrayers == null) {
      try {
        final raw = await rootBundle.loadString(
          'assets/seed/rosary/initial_prayers.json',
        );
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _allInitialPrayers = RosaryInitialPrayers.fromJson(decoded);
      } catch (_) {
        return RosaryInitialPrayers.empty();
      }
    }

    final prayersForLanguage = RosaryInitialPrayers(
      options: {
        normalizedLanguage: _allInitialPrayers!.optionsForLanguage(
          normalizedLanguage,
        ),
      },
    );

    _initialPrayersCache[normalizedLanguage] = prayersForLanguage;
    return prayersForLanguage;
  }
}
