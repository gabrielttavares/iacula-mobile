import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_collection.dart';
import '../../domain/repositories/prayer_content_repository.dart';

final class AssetPrayerContentRepository implements PrayerContentRepository {
  const AssetPrayerContentRepository();

  @override
  Future<PrayerCollection> loadPrayers({required String language}) async {
    try {
      final path = await _resolvePrayerPath(language);
      final content = await rootBundle.loadString(path);
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
  Future<String?> getAngelusImagePath() async => 'assets/seed/images/angelus/J.jpg';

  @override
  Future<String?> getReginaCaeliImagePath() async => 'assets/seed/images/reginaCaeli/Regina caeli.jpg';

  List<PrayerVerse> _parseVerses(List<dynamic> data) {
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return PrayerVerse(
        verse: map['verse']?.toString() ?? '',
        response: map['response']?.toString() ?? '',
      );
    }).toList(growable: false);
  }

  Future<String> _resolvePrayerPath(String language) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().toSet();

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
}
