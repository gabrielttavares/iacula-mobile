import 'package:flutter/cupertino.dart';

import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/bible_book.dart';
import 'bible_chapter_screen.dart';

class BibleChaptersScreen extends StatelessWidget {
  const BibleChaptersScreen({super.key, required this.book});

  final BibleBook book;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text(book.name),
      ),
      child: SafeArea(
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md,
            IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: IaculaSpacing.sm,
            mainAxisSpacing: IaculaSpacing.sm,
            childAspectRatio: 1.3,
          ),
          itemCount: book.chapterCount,
          itemBuilder: (context, index) {
            final chapter = index + 1;
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) =>
                        BibleChapterScreen(book: book, chapterNumber: chapter),
                  ),
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.separator),
                ),
                child: Center(
                  child: Text('$chapter', style: context.textStyles.cardTitle),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
