import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/saint_of_day.dart';
import 'package:iacula_app/features/liturgia_diaria/infrastructure/services/saint_image_resolver.dart';

void main() {
  test('slugifies saint names removing accents', () {
    expect(SaintImageResolver.slugify('São João Bosco'), 'sao-joao-bosco');
    expect(
      SaintImageResolver.slugify('Santa Rosa de Viterbo'),
      'santa-rosa-de-viterbo',
    );
  });

  test(
    'returns placeholder when no remote or search image is available',
    () async {
      final resolver = SaintImageResolver(
        imageDirectoryProvider: () async => '/tmp/iacula-test',
        searchImageUrl: (_) async => null,
        downloadImage: (_) async => null,
      );

      final saint = SaintOfDay(
        date: DateTime(2026, 3, 6),
        name: 'Santa Rosa de Viterbo',
        biographyParagraphs: const ['Texto'],
      );

      final result = await resolver.resolve(saint);

      expect(
        result.imageAssetPath,
        'assets/placeholders/saint-placeholder.png',
      );
      expect(result.localImagePath, isNull);
    },
  );

  test('downloads remote image once and reuses local file path', () async {
    var downloads = 0;
    final existing = <String>{};
    final bytes = Uint8List.fromList([1, 2, 3]);
    final resolver = SaintImageResolver(
      imageDirectoryProvider: () async => '/tmp/iacula-test',
      fileExists: (path) async => existing.contains(path),
      writeFileBytes: (path, data) async {
        expect(data, bytes);
        existing.add(path);
      },
      searchImageUrl: (_) async => null,
      downloadImage: (url) async {
        downloads++;
        return bytes;
      },
    );

    final saint = SaintOfDay(
      date: DateTime(2026, 3, 6),
      name: 'Santa Rosa de Viterbo',
      biographyParagraphs: const ['Texto'],
      remoteImageUrl: 'https://example.com/rosa.jpg',
    );

    final first = await resolver.resolve(saint);
    final second = await resolver.resolve(saint);

    expect(first.localImagePath, '/tmp/iacula-test/santa-rosa-de-viterbo.jpg');
    expect(second.localImagePath, '/tmp/iacula-test/santa-rosa-de-viterbo.jpg');
    expect(downloads, 1);
  });
}
