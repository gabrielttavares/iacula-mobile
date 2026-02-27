import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/infrastructure/repositories/asset_prayer_content_repository.dart';

void main() {
  test('loadPrayerDetail returns PT and LAT blocks for known slug', () async {
    final repository = AssetPrayerContentRepository(
      loadAsset: (_) async => '''
{
  "slug": "pai-nosso",
  "default_language": "pt-br",
  "titles": {
    "pt-br": "Pai Nosso",
    "la": "Pater Noster"
  },
  "blocks": {
    "pt-br": [
      "Pai nosso que estais nos céus."
    ],
    "la": [
      "Pater noster, qui es in caelis."
    ]
  }
}
''',
      loadAvailableAssets: () async => {
        'assets/seed/prayers/details/pai-nosso.json',
      },
    );

    final detail = await repository.loadPrayerDetail(slug: 'pai-nosso');
    expect(detail.slug, 'pai-nosso');
    expect(detail.defaultLanguage, 'pt-br');
    expect(detail.titlesByLanguage['pt-br'], 'Pai Nosso');
    expect(detail.titlesByLanguage['la'], 'Pater Noster');
    expect(detail.blocksByLanguage['pt-br'], [
      'Pai nosso que estais nos céus.',
    ]);
    expect(detail.blocksByLanguage['la'], ['Pater noster, qui es in caelis.']);
  });

  test('loadPrayerDetail falls back when LAT blocks are missing', () async {
    final repository = AssetPrayerContentRepository(
      loadAsset: (_) async => '''
{
  "slug": "gloria",
  "default_language": "pt-br",
  "titles": {"pt-br": "Glória"},
  "blocks": {"pt-br": ["Glória ao Pai e ao Filho e ao Espírito Santo."]}
}
''',
      loadAvailableAssets: () async => {
        'assets/seed/prayers/details/gloria.json',
      },
    );

    final detail = await repository.loadPrayerDetail(slug: 'gloria');
    expect(detail.blocksByLanguage['pt-br'], isNotEmpty);
    expect(detail.blocksByLanguage['la'], isNull);
  });
}
