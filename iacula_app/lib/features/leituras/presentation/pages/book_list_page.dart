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

final _booksByAuthorProvider = FutureProvider.family<List<BookModel>, String>((
  ref,
  authorId,
) async {
  return ref.watch(leituraRepositoryProvider).listBooksByAuthor(authorId);
});

class BookListPage extends ConsumerWidget {
  const BookListPage({
    super.key,
    this.authorId,
    this.authorName,
    this.title = 'Livros',
  });

  final String? authorId;
  final String? authorName;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: PremiumGate(
        feature: PremiumFeature.leituras,
        child: _UnlockedBookList(authorId: authorId, authorName: authorName),
      ),
    );
  }
}

class _UnlockedBookList extends ConsumerWidget {
  const _UnlockedBookList({required this.authorId, required this.authorName});

  final String? authorId;
  final String? authorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = authorId == null
        ? ref.watch(_booksProvider)
        : ref.watch(_booksByAuthorProvider(authorId!));

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
                  if (!book.available) {
                    showCupertinoDialog<void>(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Em preparação'),
                        content: const Text(
                          'Esta obra está em curadoria e será adicionada em breve.',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('Fechar'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

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
