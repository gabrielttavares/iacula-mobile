import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/application/use_cases/get_prayer_catalog_use_case.dart';
import 'package:iacula_app/features/prayers/infrastructure/repositories/asset_prayer_catalog_repository.dart';

import 'dart:io';

void main() {
  group('Angelus/Regina Caeli presence in real prayer catalog', () {
    late GetPrayerCatalogUseCase useCase;

    setUp(() {
      final repository = AssetPrayerCatalogRepository(
        loadAsset: (path) => File(path.startsWith('assets/')
            ? path
            : 'assets/$path')
            .readAsString(),
        loadAvailableAssets: () async {
          final assetDir = Directory('assets/seed/prayers');
          if (!assetDir.existsSync()) return <String>{};
          return assetDir
              .listSync(recursive: true)
              .whereType<File>()
              .map((file) => file.path)
              .toSet();
        },
      );
      useCase = GetPrayerCatalogUseCase(repository: repository);
    });

    test('catalog contains angelus slug', () async {
      final entry = await useCase.getBySlug(language: 'pt-br', slug: 'angelus');
      expect(entry, isNotNull, reason: 'angelus must exist in the prayer catalog for notification routing');
      expect(entry!.slug, 'angelus');
    });

    test('catalog contains regina-coeli slug', () async {
      final entry = await useCase.getBySlug(language: 'pt-br', slug: 'regina-coeli');
      expect(entry, isNotNull, reason: 'regina-coeli must exist in the prayer catalog for notification routing');
      expect(entry!.slug, 'regina-coeli');
    });
  });
}
