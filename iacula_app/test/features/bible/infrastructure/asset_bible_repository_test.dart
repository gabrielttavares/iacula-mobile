import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/bible/infrastructure/repositories/asset_bible_repository.dart';

void main() {
  test('listBooks reads listalivros and maps labels', () async {
    final repository = AssetBibleRepository(
      loadAsset: (path) async {
        if (path.endsWith('listalivros.json')) {
          return '''
[
  {"livro": "Gn", "quantidadeCap": 50},
  {"livro": "Mt", "quantidadeCap": 28}
]
''';
        }
        throw StateError('unexpected path $path');
      },
    );

    final books = await repository.listBooks();

    expect(books.length, 2);
    expect(books.first.abbrev, 'Gn');
    expect(books.first.name, 'Gênesis');
    expect(books.first.chapterCount, 50);
    expect(books.last.name, 'Mateus');
  });

  test('getChapter loads chapter and strips [n] prefix from text', () async {
    final repository = AssetBibleRepository(
      loadAsset: (path) async {
        if (path.endsWith('listalivros.json')) {
          return '[{"livro":"Gn","quantidadeCap":50}]';
        }
        if (path.endsWith('antigotestamento/gn.json')) {
          return '''
{
  "livro":"Gênesis",
  "capitulos":[
    {
      "capitulo":1,
      "versiculos":[
        {"numero":1,"texto":"[1] No princípio"},
        {"numero":2,"texto":"[2] A terra"}
      ]
    }
  ]
}
''';
        }
        throw StateError('missing path $path');
      },
    );

    final verses = await repository.getChapter(
      bookAbbrev: 'Gn',
      chapterNumber: 1,
    );

    expect(verses.length, 2);
    expect(verses.first.number, 1);
    expect(verses.first.text, 'No princípio');
    expect(verses.last.text, 'A terra');
  });
}
