import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText, TextSpan;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/leituras/data/repositories/leitura_repository.dart';
import 'package:iacula_app/features/leituras/data/sources/leitura_local_source.dart';
import 'package:iacula_app/features/leituras/presentation/pages/book_reader_page.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';
import 'package:iacula_app/features/reading/domain/entities/reading_bookmark.dart';
import 'package:iacula_app/features/reading/domain/entities/reading_highlight.dart';
import 'package:iacula_app/features/reading/infrastructure/repositories/in_memory_reading_annotation_repository.dart';

void main() {
  LeituraRepository buildRepository() {
    return LeituraRepository(
      localSource: LeituraLocalSource(
        loadAsset: (path) async {
          if (path == 'assets/books/library/index.json') {
            return '''
{
  "authors": [
    {
      "id": "sao-josemaria-escriva",
      "name": "São Josemaría Escrivá",
      "description": "Espiritualidade.",
      "worksCount": 1,
      "availableWorksCount": 1,
      "assetPath": "assets/books/library/authors/sao-josemaria-escriva.json"
    }
  ]
}
''';
          }
          if (path == 'assets/books/library/authors/sao-josemaria-escriva.json') {
            return '''
{
  "id": "sao-josemaria-escriva",
  "name": "São Josemaría Escrivá",
  "books": [
    {
      "id": "caminho",
      "title": "Caminho",
      "author": "São Josemaría Escrivá",
      "type": "points",
      "assetPath": "assets/books/library/works/caminho.json",
      "available": true,
      "chapters": [
        {"slug": "carater", "title": "Caráter", "kind": "points"}
      ]
    }
  ]
}
''';
          }

          return '''
{
  "id": "caminho",
  "title": "Caminho",
  "author": "São Josemaría Escrivá",
  "type": "points",
  "chapters": [
    {
      "slug": "carater",
      "title": "Caráter",
      "kind": "points",
      "sections": [
        {
          "number": 1,
          "title": "Ponto",
          "paragraphs": ["Texto de teste", "Segundo texto"]
        }
      ]
    }
  ]
}
''';
        },
      ),
    );
  }

  testWidgets('book reader renders persisted highlights and bookmark actions', (
    tester,
  ) async {
    final repository = InMemoryReadingAnnotationRepository();
    await repository.saveHighlight(
      ReadingHighlight(
        id: 'hl-1',
        documentId: 'leituras:caminho:carater',
        blockId: 'section-0-paragraph-0',
        startOffset: 0,
        endOffset: 5,
        colorKey: 'default',
        createdAt: DateTime.utc(2026, 3, 14),
      ),
    );
    await repository.saveBookmark(
      ReadingBookmark(
        documentId: 'leituras:caminho:carater',
        blockId: 'section-0-paragraph-1',
        startOffset: 0,
        label: 'Segundo texto',
        updatedAt: DateTime.utc(2026, 3, 14),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith((ref) {
            return Stream<PremiumStatus>.value(
              const PremiumStatus(isPremium: true),
            );
          }),
          leituraRepositoryProvider.overrideWithValue(buildRepository()),
          readingAnnotationRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(
          home: BookReaderPage(bookId: 'caminho', chapterSlug: 'carater'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Marcar'), findsOneWidget);
    expect(find.text('Ir ao marcador'), findsOneWidget);

    final highlightedSpan = find
        .byType(SelectableText)
        .evaluate()
        .map((element) => element.widget as SelectableText)
        .map((widget) => widget.textSpan! as TextSpan)
        .expand((span) => span.children!.whereType<TextSpan>())
        .firstWhere((span) => span.style?.backgroundColor != null);
    expect(highlightedSpan.text, 'Texto');
  });
}
