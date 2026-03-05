import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/bible_book.dart';
import '../domain/entities/bible_chapter_ref.dart';

class BibleChapterScreen extends ConsumerWidget {
  const BibleChapterScreen({
    super.key,
    required this.book,
    required this.chapterNumber,
  });

  final BibleBook book;
  final int chapterNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterAsync = ref.watch(
      bibleChapterProvider(
        BibleChapterRef(bookAbbrev: book.abbrev, chapterNumber: chapterNumber),
      ),
    );

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text('${book.name} $chapterNumber'),
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
                    style: context.textStyles.secondary.copyWith(
                      fontSize: 16,
                      color: context.colors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '${verse.number} ',
                        style: context.textStyles.cardTitle.copyWith(
                          fontSize: 15,
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
