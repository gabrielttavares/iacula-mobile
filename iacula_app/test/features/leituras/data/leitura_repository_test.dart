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

  test(
    'getBook returns the native compendium book when present in library',
    () async {
      final source = _FakeLeituraLocalSource(
        loadAsset: (path) async {
          if (path == 'assets/books/library/index.json') {
            return '''
{
  "authors": [
    {
      "id": "catecismo-da-igreja-catolica",
      "name": "Catecismo da Igreja Católica",
      "description": "Doutrina católica em perguntas e respostas.",
      "worksCount": 1,
      "availableWorksCount": 1,
      "assetPath": "assets/books/library/authors/catecismo-da-igreja-catolica.json"
    }
  ]
}
''';
          }

          if (path ==
              'assets/books/library/authors/catecismo-da-igreja-catolica.json') {
            return '''
{
  "id": "catecismo-da-igreja-catolica",
  "name": "Catecismo da Igreja Católica",
  "books": [
    {
      "id": "compendio-catecismo-da-igreja-catolica",
      "title": "Compêndio do Catecismo da Igreja Católica",
      "author": "Catecismo da Igreja Católica",
      "type": "chapters",
      "assetPath": "assets/books/library/works/compendio-catecismo-da-igreja-catolica.json",
      "available": true,
      "chapters": [
        {"slug": "profissao-da-fe", "title": "A Profissão da Fé", "kind": "chapter"}
      ]
    }
  ]
}
''';
          }

          if (path ==
              'assets/books/library/works/compendio-catecismo-da-igreja-catolica.json') {
            return '''
{
  "id": "compendio-catecismo-da-igreja-catolica",
  "title": "Compêndio do Catecismo da Igreja Católica",
  "author": "Catecismo da Igreja Católica",
  "type": "chapters",
  "chapters": [
    {
      "slug": "profissao-da-fe",
      "title": "A Profissão da Fé",
      "kind": "chapter",
      "sections": [
        {
          "number": 1,
          "title": "Qual é o desígnio de Deus acerca do homem?",
          "paragraphs": [
            "Deus, infinitamente perfeito e bem-aventurado em si mesmo, criou livremente o homem para o tornar participante da sua vida bem-aventurada."
          ]
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

      final book = await repository.getBook(
        'compendio-catecismo-da-igreja-catolica',
      );

      expect(book, isNotNull);
      expect(book!.title, 'Compêndio do Catecismo da Igreja Católica');
      expect(book.chapters, hasLength(1));
      expect(book.chapters.first.sections.first.number, 1);
    },
  );
}
