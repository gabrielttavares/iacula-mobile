import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../premium/domain/entities/premium_feature.dart';
import '../../../premium/presentation/premium_gate.dart';
import '../../data/models/book_model.dart';
import '../widgets/book_card.dart';
import 'book_reader_page.dart';

final _booksProvider = FutureProvider<List<BookModel>>((ref) async {
  return ref.watch(leituraRepositoryProvider).listBooks();
});

class BookListPage extends ConsumerWidget {
  const BookListPage({super.key, this.authorName, this.title = 'Livros'});

  final String? authorName;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: PremiumGate(
        feature: PremiumFeature.leituras,
        child: _UnlockedBookList(authorName: authorName),
      ),
    );
  }
}

class _UnlockedBookList extends ConsumerWidget {
  const _UnlockedBookList({required this.authorName});

  final String? authorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(_booksProvider);

    return SafeArea(
      child: booksAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Não foi possível carregar os livros.',
            style: context.textStyles.secondary,
          ),
        ),
        data: (books) {
          final filteredBooks = authorName == null
              ? books
              : books.where((book) => book.author == authorName).toList();

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              IaculaSpacing.md,
              IaculaSpacing.md,
              IaculaSpacing.md,
              IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: filteredBooks.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: IaculaSpacing.sm),
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              return BookCard(
                title: book.title,
                description: book.description,
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => BookReaderPage(bookId: book.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
