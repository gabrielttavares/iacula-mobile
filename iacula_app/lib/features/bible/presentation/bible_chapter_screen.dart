import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/bible_book.dart';
import '../domain/entities/bible_chapter_ref.dart';

class BibleChapterScreen extends ConsumerStatefulWidget {
  const BibleChapterScreen({
    super.key,
    required this.book,
    required this.chapterNumber,
  });

  final BibleBook book;
  final int chapterNumber;

  @override
  ConsumerState<BibleChapterScreen> createState() => _BibleChapterScreenState();
}

class _BibleChapterScreenState extends ConsumerState<BibleChapterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(biblePrefsProvider.notifier).savePosition(
            widget.book.abbrev,
            widget.chapterNumber,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(
      bibleChapterProvider(
        BibleChapterRef(
          bookAbbrev: widget.book.abbrev,
          chapterNumber: widget.chapterNumber,
        ),
      ),
    );

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text('${widget.book.name} ${widget.chapterNumber}'),
      ),
      child: SafeArea(
        child: chapterAsync.when(
          data: (verses) {
            if (verses.isEmpty) {
              return Center(
                child: Text(
                  'Capítulo vazio',
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
                IaculaSpacing.xl + MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: verses.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: IaculaSpacing.md),
              itemBuilder: (context, index) {
                final verse = verses[index];
                return RichText(
                  text: TextSpan(
                    style: context.textStyles.readingBody,
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.top,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0, top: 5.0),
                          child: Text(
                            '${verse.number}',
                            style: context.textStyles.secondary.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: context.colors.primaryButton,
                            ),
                          ),
                        ),
                      ),
                      TextSpan(text: verse.text),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(IaculaSpacing.md),
            child: IaculaShimmerList(itemCount: 10),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Não foi possível carregar o capítulo',
              style: context.textStyles.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
