import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../premium/domain/entities/premium_feature.dart';
import '../../../premium/presentation/premium_gate.dart';
import '../../data/models/book_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/models/reading_point_model.dart';
import '../widgets/reading_paragraph.dart';

final _bookProvider = FutureProvider.family<BookModel?, String>((
  ref,
  bookId,
) async {
  return ref.watch(leituraRepositoryProvider).getBook(bookId);
});

final _chapterProvider =
    FutureProvider.family<ChapterModel?, ({String bookId, String chapterSlug})>(
      (ref, args) async {
        return ref
            .watch(leituraRepositoryProvider)
            .getChapter(bookId: args.bookId, chapterSlug: args.chapterSlug);
      },
    );

class BookReaderPage extends ConsumerStatefulWidget {
  const BookReaderPage({super.key, required this.bookId, this.chapterSlug});

  final String bookId;
  final String? chapterSlug;

  @override
  ConsumerState<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends ConsumerState<BookReaderPage> {
  double _fontSize = 17;

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(_bookProvider(widget.bookId));
    final readingTitle = bookAsync.maybeWhen(
      data: (book) => book?.title ?? 'Leitura',
      orElse: () => 'Leitura',
    );

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.chapterSlug == null ? 'Capítulos' : readingTitle),
        trailing: widget.chapterSlug == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(28, 28),
                    onPressed: () {
                      setState(() {
                        _fontSize = ((_fontSize - 1).clamp(14, 24) as num)
                            .toDouble();
                      });
                    },
                    child: const Text('A-'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(28, 28),
                    onPressed: () {
                      setState(() {
                        _fontSize = ((_fontSize + 1).clamp(14, 24) as num)
                            .toDouble();
                      });
                    },
                    child: const Text('A+'),
                  ),
                ],
              ),
      ),
      child: PremiumGate(
        feature: PremiumFeature.leituras,
        child: _UnlockedBookReaderBody(
          bookId: widget.bookId,
          chapterSlug: widget.chapterSlug,
          fontSize: _fontSize,
        ),
      ),
    );
  }
}

class _UnlockedBookReaderBody extends ConsumerWidget {
  const _UnlockedBookReaderBody({
    required this.bookId,
    required this.chapterSlug,
    required this.fontSize,
  });

  final String bookId;
  final String? chapterSlug;
  final double fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: chapterSlug == null
          ? _ChapterListView(bookId: bookId)
          : _ReaderView(
              bookId: bookId,
              chapterSlug: chapterSlug!,
              fontSize: fontSize,
            ),
    );
  }
}

class _ChapterListView extends ConsumerWidget {
  const _ChapterListView({required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(_bookProvider(bookId));

    return bookAsync.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Não foi possível carregar os capítulos.',
          style: context.textStyles.secondary,
        ),
      ),
      data: (book) {
        if (book == null) {
          return Center(
            child: Text(
              'Livro não encontrado.',
              style: context.textStyles.secondary,
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: book.chapters.length,
          separatorBuilder: (_, _) => const SizedBox(height: IaculaSpacing.sm),
          itemBuilder: (context, index) {
            final chapter = book.chapters[index];
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => BookReaderPage(
                      bookId: bookId,
                      chapterSlug: chapter.slug,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(IaculaSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chapter.title,
                        textAlign: TextAlign.left,
                        style: context.textStyles.cardTitle,
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
          },
        );
      },
    );
  }
}

class _ReaderView extends ConsumerWidget {
  const _ReaderView({
    required this.bookId,
    required this.chapterSlug,
    required this.fontSize,
  });

  final String bookId;
  final String chapterSlug;
  final double fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterAsync = ref.watch(
      _chapterProvider((bookId: bookId, chapterSlug: chapterSlug)),
    );

    return chapterAsync.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Não foi possível carregar o capítulo.',
          style: context.textStyles.secondary,
        ),
      ),
      data: (chapter) {
        if (chapter == null) {
          return Center(
            child: Text(
              'Capítulo não encontrado.',
              style: context.textStyles.secondary,
            ),
          );
        }

        final readingBlocks = _toReadingBlocks(chapter);
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: readingBlocks.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: IaculaSpacing.lg),
                child: Text(
                  chapter.title,
                  style: context.textStyles.sectionTitle,
                ),
              );
            }

            final point = readingBlocks[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: IaculaSpacing.lg),
              child: ReadingParagraph(point: point, fontSize: fontSize),
            );
          },
        );
      },
    );
  }

  List<ReadingPointModel> _toReadingBlocks(ChapterModel chapter) {
    if (chapter.sections.isNotEmpty) {
      return chapter.sections;
    }
    if (chapter.paragraphs.isEmpty) {
      return const <ReadingPointModel>[];
    }
    return [ReadingPointModel(paragraphs: chapter.paragraphs)];
  }
}
