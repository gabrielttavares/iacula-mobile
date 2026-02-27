import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/doctrina/domain/entities/doctrine_entry.dart';
import 'package:iacula_app/features/doctrina/infrastructure/repositories/asset_doctrine_repository.dart';
import 'package:iacula_app/features/doctrina/application/use_cases/get_doctrine_catalog_use_case.dart';

void main() {
  group('DoctrineEntry', () {
    test('constructs with required fields', () {
      const entry = DoctrineEntry(
        slug: 'santissima-trindade',
        title: 'A Santíssima Trindade',
        content: 'A Santíssima Trindade é o mistério central da fé.',
        category: 'dogma',
      );

      expect(entry.slug, 'santissima-trindade');
      expect(entry.title, 'A Santíssima Trindade');
      expect(entry.content, contains('mistério central'));
      expect(entry.category, 'dogma');
    });

    test('supports empty category', () {
      const entry = DoctrineEntry(
        slug: 'test',
        title: 'Test',
        content: 'Content',
        category: '',
      );

      expect(entry.category, isEmpty);
    });
  });

  group('AssetDoctrineRepository', () {
    test('parses valid JSON catalog', () async {
      final json = jsonEncode([
        {
          'id': 'test-entry',
          'title': 'Test Doctrine',
          'content': 'Test content here.',
          'category': 'dogma',
        },
        {
          'id': 'test-entry-2',
          'title': 'Second Doctrine',
          'content': 'More content.',
          'category': 'moral',
        },
      ]);

      final repository = AssetDoctrineRepository(
        loadAsset: (_) async => json,
        loadAvailableAssets: () async => {
          'assets/seed/doctrina/pt-br/doctrina_catalog.json',
        },
      );

      final entries = await repository.listCatalog(language: 'pt-br');

      expect(entries, hasLength(2));
      expect(entries[0].slug, 'test-entry');
      expect(entries[0].title, 'Test Doctrine');
      expect(entries[0].content, 'Test content here.');
      expect(entries[0].category, 'dogma');
      expect(entries[1].slug, 'test-entry-2');
      expect(entries[1].category, 'moral');
    });

    test('skips entries with missing required fields', () async {
      final json = jsonEncode([
        {
          'id': 'valid',
          'title': 'Valid',
          'content': 'Valid content',
          'category': 'dogma',
        },
        {
          'id': '',
          'title': 'No ID',
          'content': 'Content',
          'category': 'dogma',
        },
        {
          'id': 'no-title',
          'title': '',
          'content': 'Content',
          'category': 'dogma',
        },
        {
          'id': 'no-content',
          'title': 'Title',
          'content': '',
          'category': 'dogma',
        },
      ]);

      final repository = AssetDoctrineRepository(
        loadAsset: (_) async => json,
        loadAvailableAssets: () async => {
          'assets/seed/doctrina/pt-br/doctrina_catalog.json',
        },
      );

      final entries = await repository.listCatalog(language: 'pt-br');

      expect(entries, hasLength(1));
      expect(entries[0].slug, 'valid');
    });

    test('returns empty list on invalid JSON', () async {
      final repository = AssetDoctrineRepository(
        loadAsset: (_) async => 'not valid json!!!',
        loadAvailableAssets: () async => {
          'assets/seed/doctrina/pt-br/doctrina_catalog.json',
        },
      );

      final entries = await repository.listCatalog(language: 'pt-br');

      expect(entries, isEmpty);
    });

    test('returns empty list when JSON is not an array', () async {
      final repository = AssetDoctrineRepository(
        loadAsset: (_) async => '{"key": "value"}',
        loadAvailableAssets: () async => {
          'assets/seed/doctrina/pt-br/doctrina_catalog.json',
        },
      );

      final entries = await repository.listCatalog(language: 'pt-br');

      expect(entries, isEmpty);
    });

    test('normalizes language pt to pt-br', () async {
      String? requestedPath;
      final json = jsonEncode([
        {
          'id': 'test',
          'title': 'Test',
          'content': 'Content',
          'category': 'dogma',
        },
      ]);

      final repository = AssetDoctrineRepository(
        loadAsset: (path) async {
          requestedPath = path;
          return json;
        },
        loadAvailableAssets: () async => {
          'assets/seed/doctrina/pt-br/doctrina_catalog.json',
        },
      );

      await repository.listCatalog(language: 'pt');

      expect(requestedPath, 'assets/seed/doctrina/pt-br/doctrina_catalog.json');
    });

    test('handles missing category gracefully', () async {
      final json = jsonEncode([
        {
          'id': 'no-category',
          'title': 'No Category',
          'content': 'Content here.',
        },
      ]);

      final repository = AssetDoctrineRepository(
        loadAsset: (_) async => json,
        loadAvailableAssets: () async => {
          'assets/seed/doctrina/pt-br/doctrina_catalog.json',
        },
      );

      final entries = await repository.listCatalog(language: 'pt-br');

      expect(entries, hasLength(1));
      expect(entries[0].category, isEmpty);
    });
  });

  group('GetDoctrineCatalogUseCase', () {
    test('listAll delegates to repository', () async {
      final json = jsonEncode([
        {
          'id': 'a',
          'title': 'A',
          'content': 'Content A',
          'category': 'dogma',
        },
        {
          'id': 'b',
          'title': 'B',
          'content': 'Content B',
          'category': 'moral',
        },
      ]);

      final repository = AssetDoctrineRepository(
        loadAsset: (_) async => json,
        loadAvailableAssets: () async => {
          'assets/seed/doctrina/pt-br/doctrina_catalog.json',
        },
      );

      final useCase = GetDoctrineCatalogUseCase(repository: repository);
      final entries = await useCase.listAll(language: 'pt-br');

      expect(entries, hasLength(2));
    });

    test('byCategory filters correctly', () async {
      final json = jsonEncode([
        {
          'id': 'a',
          'title': 'A',
          'content': 'Content A',
          'category': 'dogma',
        },
        {
          'id': 'b',
          'title': 'B',
          'content': 'Content B',
          'category': 'moral',
        },
        {
          'id': 'c',
          'title': 'C',
          'content': 'Content C',
          'category': 'dogma',
        },
      ]);

      final repository = AssetDoctrineRepository(
        loadAsset: (_) async => json,
        loadAvailableAssets: () async => {
          'assets/seed/doctrina/pt-br/doctrina_catalog.json',
        },
      );

      final useCase = GetDoctrineCatalogUseCase(repository: repository);
      final entries = await useCase.byCategory(
        language: 'pt-br',
        category: 'dogma',
      );

      expect(entries, hasLength(2));
      expect(entries.every((e) => e.category == 'dogma'), isTrue);
    });
  });
}
