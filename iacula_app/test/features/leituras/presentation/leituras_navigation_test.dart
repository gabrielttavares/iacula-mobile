import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/leituras/data/repositories/leitura_repository.dart';
import 'package:iacula_app/features/leituras/data/sources/leitura_local_source.dart';
import 'package:iacula_app/features/leituras/presentation/pages/book_list_page.dart';
import 'package:iacula_app/features/leituras/presentation/pages/book_reader_page.dart';
import 'package:iacula_app/features/leituras/presentation/pages/author_list_page.dart';
import 'package:iacula_app/features/leituras/presentation/pages/compendium_reader_page.dart';
import 'package:iacula_app/features/leituras/presentation/pages/leituras_home_page.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';

void main() {
  Widget _buildCompendiumStub(BuildContext context, String url, String title) {
    return Center(child: Text(title));
  }

  LeituraRepository _buildLeiturasRepository() {
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
      "description": "Espiritualidade no cotidiano.",
      "worksCount": 8,
      "availableWorksCount": 8,
      "assetPath": "assets/books/library/authors/sao-josemaria-escriva.json"
    }
  ]
}
''';
          }

          if (path ==
              'assets/books/library/authors/sao-josemaria-escriva.json') {
            return '''
{
  "id": "sao-josemaria-escriva",
  "name": "São Josemaría Escrivá",
  "books": []
}
''';
          }

          throw StateError('unexpected path: $path');
        },
      ),
    );
  }

  testWidgets('Leituras home shows featured compendium before authors', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith((ref) {
            return Stream<PremiumStatus>.value(
              const PremiumStatus(isPremium: true),
            );
          }),
          leituraRepositoryProvider.overrideWithValue(
            _buildLeiturasRepository(),
          ),
        ],
        child: CupertinoApp(
          home: LeiturasHomePage(
            compendiumContentBuilder: _buildCompendiumStub,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Leituras'), findsAtLeastNWidgets(1));
    expect(
      find.text(
        'A biblioteca reúne os melhores livros de autores e Santos renomados da espiritualidade meditativa e prática.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Compêndio do Catecismo da Igreja Católica'),
      findsOneWidget,
    );
    expect(find.text('São Josemaría Escrivá'), findsOneWidget);

    final compendiumTopLeft = tester.getTopLeft(
      find.text('Compêndio do Catecismo da Igreja Católica'),
    );
    final authorTopLeft = tester.getTopLeft(find.text('São Josemaría Escrivá'));

    expect(compendiumTopLeft.dy, lessThan(authorTopLeft.dy));
  });

  testWidgets('Leituras home opens compendium reader from featured card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith((ref) {
            return Stream<PremiumStatus>.value(
              const PremiumStatus(isPremium: true),
            );
          }),
          leituraRepositoryProvider.overrideWithValue(
            _buildLeiturasRepository(),
          ),
        ],
        child: CupertinoApp(
          home: LeiturasHomePage(
            compendiumContentBuilder: _buildCompendiumStub,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Compêndio do Catecismo da Igreja Católica'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CompendiumReaderPage), findsOneWidget);
  });

  testWidgets('Leituras home still opens books list from author card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumStatusProvider.overrideWith((ref) {
            return Stream<PremiumStatus>.value(
              const PremiumStatus(isPremium: true),
            );
          }),
          leituraRepositoryProvider.overrideWithValue(
            _buildLeiturasRepository(),
          ),
        ],
        child: CupertinoApp(
          home: LeiturasHomePage(
            compendiumContentBuilder: _buildCompendiumStub,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('São Josemaría Escrivá').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(BookListPage), findsOneWidget);
  });

  testWidgets('author list screen renders available authors', (tester) async {
    final repository = LeituraRepository(
      localSource: LeituraLocalSource(
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

          if (path ==
              'assets/books/library/authors/sao-josemaria-escriva.json') {
            return '''
{
  "id": "sao-josemaria-escriva",
  "name": "São Josemaría Escrivá",
  "books": []
}
''';
          }

          throw StateError('unexpected path: $path');
        },
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
          leituraRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(home: AuthorListPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('São Josemaría Escrivá'), findsOneWidget);
  });

  testWidgets('author list unlocks authors with available works', (
    tester,
  ) async {
    final repository = LeituraRepository(
      localSource: LeituraLocalSource(
        loadAsset: (path) async {
          if (path == 'assets/books/library/index.json') {
            return '''
{
  "authors": [
    {
      "id": "sao-francisco-sales",
      "name": "São Francisco de Sales",
      "description": "Vida devota.",
      "worksCount": 3,
      "availableWorksCount": 1,
      "assetPath": "assets/books/library/authors/sao-francisco-sales.json"
    }
  ]
}
''';
          }

          if (path == 'assets/books/library/authors/sao-francisco-sales.json') {
            return '''
{
  "id": "sao-francisco-sales",
  "name": "São Francisco de Sales",
  "books": [
    {
      "id": "introducao-a-vida-devota",
      "title": "Filotéia ou Introdução à Vida Devota",
      "author": "São Francisco de Sales",
      "type": "chapters",
      "assetPath": "assets/books/library/works/introducao-a-vida-devota.json",
      "available": true,
      "chapters": [
        {"slug": "texto-integral", "title": "Texto integral", "kind": "chapter"}
      ]
    }
  ]
}
''';
          }

          throw StateError('unexpected path: $path');
        },
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
          leituraRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(home: AuthorListPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('São Francisco de Sales'), findsOneWidget);
    expect(find.text('Em breve'), findsNothing);

    await tester.tap(find.text('São Francisco de Sales'));
    await tester.pumpAndSettle();

    expect(find.byType(BookListPage), findsOneWidget);
    expect(find.text('Filotéia ou Introdução à Vida Devota'), findsOneWidget);
  });

  testWidgets('blocked author shows Em breve and curadoria popup on tap', (
    tester,
  ) async {
    final repository = LeituraRepository(
      localSource: LeituraLocalSource(
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
    },
    {
      "id": "dom-chautard",
      "name": "Dom Jean-Baptiste Chautard",
      "description": "Vida interior e apostolado.",
      "worksCount": 2,
      "availableWorksCount": 0,
      "assetPath": "assets/books/library/authors/dom-chautard.json"
    }
  ]
}
''';
          }

          if (path ==
              'assets/books/library/authors/sao-josemaria-escriva.json') {
            return '{"id":"sao-josemaria-escriva","name":"São Josemaría Escrivá","books":[]}';
          }

          if (path == 'assets/books/library/authors/dom-chautard.json') {
            return '{"id":"dom-chautard","name":"Dom Jean-Baptiste Chautard","books":[]}';
          }

          throw StateError('unexpected path: $path');
        },
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
          leituraRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(home: AuthorListPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Em breve'), findsOneWidget);

    await tester.tap(find.text('Dom Jean-Baptiste Chautard'));
    await tester.pumpAndSettle();

    expect(find.text('Em preparação'), findsOneWidget);
    expect(find.byType(BookListPage), findsNothing);
  });

  testWidgets('Book reader nav bar uses the book title in chapter mode', (
    tester,
  ) async {
    final repository = LeituraRepository(
      localSource: LeituraLocalSource(
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
      "description": "",
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
          "paragraphs": ["Texto de teste"]
        }
      ]
    }
  ]
}
''';
        },
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
          leituraRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(
          home: BookReaderPage(bookId: 'caminho', chapterSlug: 'carater'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Caminho'), findsOneWidget);
    expect(find.text('Leitura'), findsNothing);
  });
}
