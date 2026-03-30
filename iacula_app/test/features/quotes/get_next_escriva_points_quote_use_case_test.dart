import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/leituras/data/repositories/leitura_repository.dart';
import 'package:iacula_app/features/leituras/data/sources/leitura_local_source.dart';
import 'package:iacula_app/features/quotes/application/use_cases/get_next_escriva_points_quote_use_case.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';

void main() {
  test('maps Caminho/Sulco/Forja points into quote payload', () async {
    final useCase = GetNextEscrivaPointsQuoteUseCase(
      LeituraRepository(
        localSource: LeituraLocalSource(loadAsset: _fakeAssetLoader),
      ),
    );

    final quote = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 1, 1),
    );

    expect(quote.text, 'Caminho ponto 1');
    expect(
      quote.theme,
      matches(RegExp(r'^(Caminho|Sulco|Forja) · Caráter$')),
    );
    expect(quote.season, LiturgicalSeason.ordinary);
    expect(quote.source, QuoteSource.escrivaPoints);
    expect(
      quote.referenceLabel,
      matches(RegExp(r'^(Caminho|Sulco|Forja), 1$')),
    );
  });

  test('returns unavailable content fallback when no points exist', () async {
    final useCase = GetNextEscrivaPointsQuoteUseCase(
      LeituraRepository(
        localSource: LeituraLocalSource(
          loadAsset: (path) async {
            if (path.endsWith('index.json')) {
              return jsonEncode({
                'books': [
                  {
                    'id': 'caminho',
                    'title': 'Caminho',
                    'author': 'Autor',
                    'description': 'x',
                    'type': 'points',
                    'assetPath': 'assets/books/escriva/caminho.json',
                  },
                ],
              });
            }

            return jsonEncode({
              'chapters': [
                {
                  'slug': 'prologo-do-autor',
                  'title': 'Intro',
                  'kind': 'intro',
                  'paragraphs': ['n/a'],
                },
              ],
            });
          },
        ),
      ),
    );

    final quote = await useCase.call(language: 'pt-br');
    expect(quote.text, 'Conteudo indisponivel para hoje.');
  });

  test('does not follow the natural book order across consecutive buckets',
      () async {
    // With many points, consecutive cadence buckets should NOT produce
    // points in the same order they appear in the books (i.e., the pool
    // should be shuffled).
    final useCase = GetNextEscrivaPointsQuoteUseCase(
      LeituraRepository(
        localSource:
            LeituraLocalSource(loadAsset: _fakeAssetLoaderManyPoints),
      ),
    );

    final labels = <String>[];
    // Collect 20 consecutive cadence buckets starting at midnight on Jan 1
    for (var i = 0; i < 20; i++) {
      final quote = await useCase.call(
        language: 'pt-br',
        now: DateTime(2026, 1, 1, 0, i * 15),
        cadenceMinutes: 15,
      );
      labels.add(quote.referenceLabel!);
    }

    // Build the natural (unshuffled) order: Caminho 1..10, Sulco 1..10,
    // Forja 1..10 — repeating via modulo.
    final naturalOrder = <String>[];
    for (var i = 0; i < 30; i++) {
      final book = i < 10
          ? 'Caminho'
          : i < 20
              ? 'Sulco'
              : 'Forja';
      naturalOrder.add('$book, ${(i % 10) + 1}');
    }

    // The actual labels should NOT match the first 20 entries of natural
    // order — that would mean no shuffling happened.
    expect(labels, isNot(equals(naturalOrder.sublist(0, 20))));
  });

  test('rotates point across cadence buckets on same day', () async {
    final useCase = GetNextEscrivaPointsQuoteUseCase(
      LeituraRepository(
        localSource: LeituraLocalSource(loadAsset: _fakeAssetLoader),
      ),
    );

    final first = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 1, 1, 14, 24),
      cadenceMinutes: 15,
    );
    final second = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 1, 1, 14, 39),
      cadenceMinutes: 15,
    );

    expect(first.referenceLabel, isNot(second.referenceLabel));
  });
}

Future<String> _fakeAssetLoader(String path) async {
  if (path.endsWith('index.json')) {
    return jsonEncode({
      'books': [
        {
          'id': 'caminho',
          'title': 'Caminho',
          'author': 'Autor',
          'description': 'x',
          'type': 'points',
          'assetPath': 'assets/books/escriva/caminho.json',
        },
        {
          'id': 'sulco',
          'title': 'Sulco',
          'author': 'Autor',
          'description': 'x',
          'type': 'points',
          'assetPath': 'assets/books/escriva/sulco.json',
        },
        {
          'id': 'forja',
          'title': 'Forja',
          'author': 'Autor',
          'description': 'x',
          'type': 'points',
          'assetPath': 'assets/books/escriva/forja.json',
        },
      ],
    });
  }

  return jsonEncode({
    'chapters': [
      {
        'slug': 'carater',
        'title': 'Caráter',
        'kind': 'points',
        'sections': [
          {
            'number': 1,
            'paragraphs': ['Caminho ponto 1'],
          },
        ],
      },
    ],
  });
}

Future<String> _fakeAssetLoaderManyPoints(String path) async {
  if (path.endsWith('index.json')) {
    return jsonEncode({
      'books': [
        {
          'id': 'caminho',
          'title': 'Caminho',
          'author': 'Autor',
          'description': 'x',
          'type': 'points',
          'assetPath': 'assets/books/escriva/caminho.json',
        },
        {
          'id': 'sulco',
          'title': 'Sulco',
          'author': 'Autor',
          'description': 'x',
          'type': 'points',
          'assetPath': 'assets/books/escriva/sulco.json',
        },
        {
          'id': 'forja',
          'title': 'Forja',
          'author': 'Autor',
          'description': 'x',
          'type': 'points',
          'assetPath': 'assets/books/escriva/forja.json',
        },
      ],
    });
  }

  // Each book gets 10 points so there's a clear sequential pattern to detect.
  final bookName = path.contains('caminho')
      ? 'Caminho'
      : path.contains('sulco')
          ? 'Sulco'
          : 'Forja';

  return jsonEncode({
    'chapters': [
      {
        'slug': 'cap',
        'title': 'Cap',
        'kind': 'points',
        'sections': [
          for (var i = 1; i <= 10; i++)
            {
              'number': i,
              'paragraphs': ['$bookName ponto $i'],
            },
        ],
      },
    ],
  });
}
