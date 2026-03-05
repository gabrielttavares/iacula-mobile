import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/bible/domain/entities/bible_book.dart';
import 'package:iacula_app/features/bible/domain/entities/bible_verse.dart';
import 'package:iacula_app/features/bible/domain/repositories/bible_repository.dart';
import 'package:iacula_app/features/bible/presentation/bible_books_screen.dart';
import 'package:iacula_app/features/bible/presentation/bible_chapter_screen.dart';
import 'package:iacula_app/features/bible/presentation/bible_chapters_screen.dart';

final class _FakeBibleRepository implements BibleRepository {
  @override
  Future<List<BibleBook>> listBooks() async {
    return const [
      BibleBook(abbrev: 'Gn', name: 'Gênesis', chapterCount: 2, order: 0),
    ];
  }

  @override
  Future<List<BibleVerse>> getChapter({
    required String bookAbbrev,
    required int chapterNumber,
  }) async {
    if (bookAbbrev == 'Gn' && chapterNumber == 1) {
      return const [
        BibleVerse(number: 1, text: 'No princípio criou Deus o céu e a terra.'),
        BibleVerse(number: 2, text: 'A terra, porém, estava informe e vazia.'),
      ];
    }
    return const [];
  }
}

void main() {
  testWidgets('bible flow opens chapters and renders verses', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bibleRepositoryProvider.overrideWithValue(_FakeBibleRepository()),
        ],
        child: const CupertinoApp(home: BibleBooksScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BibleBooksScreen), findsOneWidget);
    expect(find.text('Gênesis'), findsOneWidget);

    await tester.tap(find.text('Gênesis'));
    await tester.pumpAndSettle();

    expect(find.byType(BibleChaptersScreen), findsOneWidget);
    final chapterOneFinder = find.descendant(
      of: find.byType(GridView),
      matching: find.text('1'),
    );
    expect(chapterOneFinder, findsOneWidget);

    await tester.tap(chapterOneFinder);
    await tester.pumpAndSettle();

    expect(find.byType(BibleChapterScreen), findsOneWidget);
    expect(
      find.textContaining('No princípio criou Deus', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('A terra, porém', findRichText: true),
      findsOneWidget,
    );
  });
}
