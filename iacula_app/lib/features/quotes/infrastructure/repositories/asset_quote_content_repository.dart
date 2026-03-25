import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../liturgical/domain/liturgical_season.dart';
import '../../domain/entities/day_quotes.dart';
import '../../domain/repositories/quote_content_repository.dart';

final class AssetQuoteContentRepository implements QuoteContentRepository {
  const AssetQuoteContentRepository();

  static AssetManifest? _manifestCache;
  static final Map<LiturgicalSeason, Map<String, DayQuotes>> _quotesCache = {};
  static final Map<(int, LiturgicalSeason), List<String>> _dayImagesCache = {};

  static Future<AssetManifest> _getManifest() async {
    return _manifestCache ??= await AssetManifest.loadFromAssetBundle(rootBundle);
  }

  /// [language] is ignored; bundled quotes are always loaded from the pt-BR JSON assets.
  @override
  Future<Map<String, DayQuotes>> loadQuotes({
    required String language,
    required LiturgicalSeason season,
  }) async {
    final cached = _quotesCache[season];
    if (cached != null) return cached;

    final path = await _resolveQuotePath(season: season);

    try {
      final jsonString = await rootBundle.loadString(path);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      final result = jsonMap.map((key, value) {
        final data = value as Map<String, dynamic>;
        final quotes = (data['quotes'] as List<dynamic>).map((e) => e.toString()).toList(growable: false);
        return MapEntry(
          key,
          DayQuotes(
            day: data['day']?.toString() ?? '',
            theme: data['theme']?.toString() ?? '',
            quotes: quotes,
          ),
        );
      });

      _quotesCache[season] = result;
      return result;
    } catch (_) {
      return const <String, DayQuotes>{};
    }
  }

  @override
  Future<List<String>> listDayImages({
    required int dayOfWeek,
    required LiturgicalSeason season,
  }) async {
    final key = (dayOfWeek, season);
    final cached = _dayImagesCache[key];
    if (cached != null) return cached;

    final manifest = await _getManifest();
    final assets = manifest.listAssets();

    final seasonFolder = season == LiturgicalSeason.ordinary ? 'ordinary/$dayOfWeek' : _seasonFolder(season);
    final prefix = 'assets/seed/images/$seasonFolder/';

    final imageKeys = assets.where((k) => _isSupportedImage(k) && k.startsWith(prefix)).toList()..sort();

    if (imageKeys.isNotEmpty) {
      _dayImagesCache[key] = imageKeys;
      return imageKeys;
    }

    if (season != LiturgicalSeason.ordinary) {
      final fallback = await listDayImages(dayOfWeek: dayOfWeek, season: LiturgicalSeason.ordinary);
      _dayImagesCache[key] = fallback;
      return fallback;
    }

    _dayImagesCache[key] = const <String>[];
    return const <String>[];
  }

  @override
  Future<List<String>> loadFeastQuotes(String feastSlug) async {
    final manifest = await _getManifest();
    final assets = manifest.listAssets().toSet();

    final path = 'assets/seed/quotes/pt-br/feasts/$feastSlug.json';
    if (!assets.contains(path)) {
      return const <String>[];
    }

    try {
      final jsonString = await rootBundle.loadString(path);
      final decoded = jsonDecode(jsonString);

      if (decoded is List<dynamic>) {
        return decoded.map((e) => e.toString()).toList(growable: false);
      }

      if (decoded is Map<String, dynamic>) {
        final quotes = decoded['quotes'];
        if (quotes is List<dynamic>) {
          return quotes.map((e) => e.toString()).toList(growable: false);
        }
      }

      return const <String>[];
    } catch (_) {
      return const <String>[];
    }
  }

  @override
  Future<String?> getFeastImagePath(String feastSlug) async {
    final manifest = await _getManifest();
    final assets = manifest.listAssets();
    final prefix = 'assets/seed/images/feasts/$feastSlug/';

    final images = assets.where((k) => _isSupportedImage(k) && k.startsWith(prefix)).toList()..sort();

    return images.isEmpty ? null : images.first;
  }

  Future<String> _resolveQuotePath({required LiturgicalSeason season}) async {
    final manifest = await _getManifest();
    final assets = manifest.listAssets().toSet();

    final preferred = _quotePath(season: season);
    if (assets.contains(preferred)) {
      return preferred;
    }

    const fallbacks = <String>[
      'assets/seed/quotes/pt-br/quotes.json',
    ];

    for (final candidate in fallbacks) {
      if (assets.contains(candidate)) {
        return candidate;
      }
    }

    return preferred;
  }

  String _quotePath({required LiturgicalSeason season}) {
    if (season == LiturgicalSeason.ordinary) {
      return 'assets/seed/quotes/pt-br/quotes.json';
    }

    return switch (season) {
      LiturgicalSeason.advent => 'assets/seed/quotes/pt-br/advent.json',
      LiturgicalSeason.lent => 'assets/seed/quotes/pt-br/lent.json',
      LiturgicalSeason.easter => 'assets/seed/quotes/pt-br/easter.json',
      LiturgicalSeason.christmas => 'assets/seed/quotes/pt-br/christmas.json',
      LiturgicalSeason.ordinary => 'assets/seed/quotes/pt-br/quotes.json',
    };
  }

  String _seasonFolder(LiturgicalSeason season) {
    return switch (season) {
      LiturgicalSeason.advent => 'advent',
      LiturgicalSeason.lent => 'lent',
      LiturgicalSeason.easter => 'easter',
      LiturgicalSeason.christmas => 'christmas',
      LiturgicalSeason.ordinary => 'ordinary',
    };
  }

  bool _isSupportedImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
  }
}
