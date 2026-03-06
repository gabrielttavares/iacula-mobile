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
    expect(quote.theme, 'Caminho · Caráter');
    expect(quote.season, LiturgicalSeason.ordinary);
    expect(quote.source, QuoteSource.escrivaPoints);
    expect(quote.referenceLabel, 'Caminho, 1');
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
