import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/bible_book.dart';
import 'bible_chapters_screen.dart';

class BibleBooksScreen extends ConsumerWidget {
  const BibleBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(bibleBooksProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: const Text('Bíblia'),
      ),
      child: SafeArea(
        child: booksAsync.when(
          data: (books) {
            if (books.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum livro disponível',
                  style: context.textStyles.secondary,
                ),
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                IaculaSpacing.md,
                IaculaSpacing.sm,
                IaculaSpacing.md,
                IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: books.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: IaculaSpacing.sm),
              itemBuilder: (context, index) => _BookCard(book: books[index]),
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
