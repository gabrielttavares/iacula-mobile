import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/leituras/data/repositories/leitura_repository.dart';
import 'package:iacula_app/features/leituras/data/sources/leitura_local_source.dart';

final class _FakeLeituraLocalSource extends LeituraLocalSource {
  _FakeLeituraLocalSource({required super.loadAsset});
}

void main() {
  test('listAuthors parses author catalog index', () async {
    final source = _FakeLeituraLocalSource(
      loadAsset: (path) async {
        if (path == 'assets/books/library/index.json') {
          return '''
{
  "authors": [
    {
      "id": "sao-josemaria-escriva",
      "name": "São Josemaría Escrivá",
      "description": "Espiritualidade no cotidiano.",
      "worksCount": 8,
      "availableWorksCount": 8,
      "assetPath": "assets/books/library/authors/sao-josemaria-escriva.json"
    }
  ]
}
''';
        }
        throw StateError('unexpected path: $path');
      },
    );

    final repository = LeituraRepository(localSource: source);
    final authors = await repository.listAuthors();

    expect(authors, hasLength(1));
    expect(authors.first.id, 'sao-josemaria-escriva');
    expect(authors.first.name, 'São Josemaría Escrivá');
    expect(authors.first.availableWorksCount, 8);
  });

  test('listBooksByAuthor reads author works list', () async {
    final source = _FakeLeituraLocalSource(
      loadAsset: (path) async {
        if (path == 'assets/books/library/index.json') {
          return '''
{
  "authors": [
    {
      "id": "sao-josemaria-escriva",
      "name": "São Josemaría Escrivá",
      "description": "",
      "worksCount": 1,
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
      "assetPath": "assets/books/escriva/caminho.json",
      "description": "",
      "available": true,
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
    final books = await repository.listBooksByAuthor('sao-josemaria-escriva');

    expect(books, hasLength(1));
    expect(books.first.id, 'caminho');
    expect(books.first.available, isTrue);
  });
}
