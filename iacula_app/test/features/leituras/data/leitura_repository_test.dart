import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/leituras/data/repositories/leitura_repository.dart';
import 'package:iacula_app/features/leituras/data/sources/leitura_local_source.dart';

final class _FakeLeituraLocalSource extends LeituraLocalSource {
  _FakeLeituraLocalSource({required super.loadAsset});
}

void main() {
  test('listBooks returns parsed index entries', () async {
    final source = _FakeLeituraLocalSource(
      loadAsset: (path) async {
        if (path == 'assets/books/escriva/index.json') {
          return '''
{
  "books": [
    {
      "id": "caminho",
      "title": "Caminho",
      "author": "São Josemaría Escrivá",
      "type": "points",
      "assetPath": "assets/books/escriva/caminho.json",
      "chapters": [
        {"slug": "carater", "title": "Caráter", "kind": "points"}
      ]
    }
  ]
}
''';
        }
        throw StateError('unexpected path: $path');
      },
    );
    final repository = LeituraRepository(localSource: source);

    final books = await repository.listBooks();

    expect(books, hasLength(1));
    expect(books.first.id, 'caminho');
    expect(books.first.chapters.first.slug, 'carater');
  });

  test('getChapter lazily loads the selected chapter', () async {
    final source = _FakeLeituraLocalSource(
      loadAsset: (path) async {
        if (path == 'assets/books/escriva/index.json') {
          return '''
{
  "books": [
    {
      "id": "caminho",
      "title": "Caminho",
      "author": "São Josemaría Escrivá",
      "type": "points",
      "assetPath": "assets/books/escriva/caminho.json",
      "chapters": [
        {"slug": "carater", "title": "Caráter", "kind": "points"}
      ]
    }
  ]
}
''';
        }

        if (path == 'assets/books/escriva/caminho.json') {
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
          "paragraphs": ["Que a tua vida não seja uma vida estéril."]
        }
      ]
    }
  ]
}
''';
        }

        throw StateError('unexpected path: $path');
      },
    );
    final repository = LeituraRepository(localSource: source);

    final chapter = await repository.getChapter(
      bookId: 'caminho',
      chapterSlug: 'carater',
    );

    expect(chapter, isNotNull);
    expect(chapter!.sections, hasLength(1));
    expect(chapter.sections.first.number, 1);
  });
}
