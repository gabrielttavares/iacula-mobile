import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_collection.dart';
import '../../domain/entities/prayer_detail.dart';
import '../../domain/repositories/prayer_content_repository.dart';

typedef PrayerAssetLoader = Future<String> Function(String path);
typedef PrayerAssetsLoader = Future<Set<String>> Function();

final class AssetPrayerContentRepository implements PrayerContentRepository {
  AssetPrayerContentRepository({
    PrayerAssetLoader? loadAsset,
    PrayerAssetsLoader? loadAvailableAssets,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString,
       _loadAvailableAssets =
           loadAvailableAssets ?? _loadAvailableAssetsFromManifest;

  final PrayerAssetLoader _loadAsset;
  final PrayerAssetsLoader _loadAvailableAssets;

  @override
  Future<PrayerCollection> loadPrayers({required String language}) async {
    try {
      final path = await _resolvePrayerPath(language);
      final content = await _loadAsset(path);
      final jsonMap = jsonDecode(content) as Map<String, dynamic>;

      final regular = jsonMap['regular'] as Map<String, dynamic>;
      final easter = jsonMap['easter'] as Map<String, dynamic>;

      return PrayerCollection(
        regularTitle: regular['title']?.toString() ?? 'Angelus',
        regularVerses: _parseVerses(regular['verses'] as List<dynamic>),
        regularPrayer: regular['prayer']?.toString() ?? '',
        easterTitle: easter['title']?.toString() ?? 'Regina Caeli',
        easterVerses: _parseVerses(easter['verses'] as List<dynamic>),
        easterPrayer: easter['prayer']?.toString() ?? '',
      );
    } catch (_) {
      const fallbackVerse = PrayerVerse(
        verse: 'Conteudo indisponivel.',
        response: 'Tente novamente mais tarde.',
      );
      return const PrayerCollection(
        regularTitle: 'Angelus',
        regularVerses: [fallbackVerse],
        regularPrayer: '',
        easterTitle: 'Regina Caeli',
        easterVerses: [fallbackVerse],
        easterPrayer: '',
      );
    }
  }

  @override
  Future<PrayerDetail> loadPrayerDetail({required String slug}) async {
    final assets = await _loadAvailableAssets();
    final path = 'assets/seed/prayers/details/$slug.json';
    if (!assets.contains(path)) {
      return PrayerDetail(
        slug: slug,
        titlesByLanguage: const <String, String>{
          'pt-br': 'Conteudo indisponivel',
        },
        blocksByLanguage: const <String, List<String>>{
          'pt-br': <String>['Detalhe nao encontrado para esta oracao.'],
        },
        defaultLanguage: 'pt-br',
      );
    }

    try {
      final content = await _loadAsset(path);
      final payload = jsonDecode(content) as Map<String, dynamic>;
      final titlesMap = payload['titles'] as Map<String, dynamic>? ?? const {};
      final blocksMap = payload['blocks'] as Map<String, dynamic>? ?? const {};

      final titlesByLanguage = <String, String>{};
      for (final entry in titlesMap.entries) {
        final value = entry.value.toString().trim();
        if (value.isNotEmpty) {
          titlesByLanguage[entry.key] = value;
        }
      }

      final blocksByLanguage = <String, List<String>>{};
      for (final entry in blocksMap.entries) {
        final blockList = entry.value;
        if (blockList is! List<dynamic>) {
          continue;
        }
        final parsed = blockList
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
        if (parsed.isNotEmpty) {
          blocksByLanguage[entry.key] = parsed;
        }
      }

      final defaultLanguage =
          payload['default_language']?.toString().trim() ?? 'pt-br';
      return PrayerDetail(
        slug: payload['slug']?.toString().trim().isNotEmpty == true
            ? payload['slug'].toString().trim()
            : slug,
        titlesByLanguage: titlesByLanguage,
        blocksByLanguage: blocksByLanguage,
        defaultLanguage: defaultLanguage,
      );
    } catch (_) {
      return PrayerDetail(
        slug: slug,
        titlesByLanguage: const <String, String>{
          'pt-br': 'Conteudo indisponivel',
        },
        blocksByLanguage: const <String, List<String>>{
          'pt-br': <String>[
            'Nao foi possivel carregar o detalhe desta oracao.',
          ],
        },
        defaultLanguage: 'pt-br',
      );
    }
  }

  @override
  Future<String?> getAngelusImagePath() async =>
      'assets/seed/images/angelus/J.jpg';

  @override
  Future<String?> getReginaCaeliImagePath() async =>
      'assets/seed/images/reginaCaeli/Regina caeli.jpg';

  List<PrayerVerse> _parseVerses(List<dynamic> data) {
    return data
        .map((item) {
          final map = item as Map<String, dynamic>;
          return PrayerVerse(
            verse: map['verse']?.toString() ?? '',
            response: map['response']?.toString() ?? '',
          );
        })
        .toList(growable: false);
  }

  Future<String> _resolvePrayerPath(String language) async {
    final assets = await _loadAvailableAssets();

    final normalized = _normalizeLanguage(language);
    final preferred = 'assets/seed/prayers/$normalized/angelus.json';
    if (assets.contains(preferred)) {
      return preferred;
    }

    const fallbacks = <String>[
      'assets/seed/prayers/pt-br/angelus.json',
      'assets/seed/prayers/en/angelus.json',
      'assets/seed/prayers/la/angelus.json',
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
