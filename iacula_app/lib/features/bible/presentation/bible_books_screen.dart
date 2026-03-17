import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/bible_book.dart';
import 'bible_chapters_screen.dart';
import 'bible_chapter_screen.dart';

class BibleBooksScreen extends ConsumerStatefulWidget {
  const BibleBooksScreen({super.key});

  @override
  ConsumerState<BibleBooksScreen> createState() => _BibleBooksScreenState();
}

class _BibleBooksScreenState extends ConsumerState<BibleBooksScreen> {
  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(bibleBooksProvider);
    final prefs = ref.watch(biblePrefsProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: const Text('Bíblia'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: IaculaSpacing.md,
                vertical: IaculaSpacing.sm,
              ),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<BibleTestament>(
                  groupValue: prefs.testament,
                  children: const {
                    BibleTestament.antigo: Text('Antigo'),
                    BibleTestament.novo: Text('Novo'),
                  },
                  onValueChanged: (value) {
                    if (value != null) {
                      ref.read(biblePrefsProvider.notifier).setTestament(value);
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: booksAsync.when(
                data: (books) {
                  final filteredBooks = books
                      .where((b) => b.testament == prefs.testament)
                      .toList();

                  if (filteredBooks.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum livro disponível',
                        style: context.textStyles.secondary,
                      ),
                    );
                  }

                  final lastBookAbbrev = prefs.lastBookAbbrev;
                  final lastChapter = prefs.lastChapterNumber;
                  BibleBook? lastBook;
                  if (lastBookAbbrev != null) {
                    try {
                      lastBook = books.firstWhere((b) => b.abbrev == lastBookAbbrev);
                    } catch (_) {}
                  }

                  final showContinueReading = lastBook != null &&
                      lastBook.testament == prefs.testament &&
                      lastChapter != null;

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      IaculaSpacing.md,
                      IaculaSpacing.sm,
                      IaculaSpacing.md,
                      IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: filteredBooks.length + (showContinueReading ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: IaculaSpacing.sm),
                    itemBuilder: (context, index) {
                      if (showContinueReading && index == 0) {
                        return _ContinueReadingCard(
                          book: lastBook!,
                          chapterNumber: lastChapter!,
                        );
                      }
                      final bookIndex = showContinueReading ? index - 1 : index;
                      return _BookCard(book: filteredBooks[bookIndex]);
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(IaculaSpacing.md),
                  child: IaculaShimmerList(itemCount: 8),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(
                    'Não foi possível carregar a Bíblia',
                    style: context.textStyles.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({
    required this.book,
    required this.chapterNumber,
  });

  final BibleBook book;
  final int chapterNumber;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => BibleChapterScreen(
              book: book,
              chapterNumber: chapterNumber,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(IaculaSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.primaryButton.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.primaryButton.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.book_fill,
              color: context.colors.primaryButton,
              size: 28,
            ),
            const SizedBox(width: IaculaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continuar lendo',
                    style: context.textStyles.secondary.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primaryButton,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${book.name} $chapterNumber',
                    style: context.textStyles.cardTitle,
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.arrow_right,
              color: context.colors.primaryButton,
            ),
          ],
        ),
      ),
    );
  }
}

final class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final BibleBook book;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => BibleChaptersScreen(book: book)),
        );
      },
      child: IaculaSoftCard(
        radius: 16,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.name, style: context.textStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    '${book.chapterCount} capítulos',
                    style: context.textStyles.secondary,
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
