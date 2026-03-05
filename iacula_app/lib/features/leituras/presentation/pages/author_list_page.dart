import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../premium/domain/entities/premium_feature.dart';
import '../../../premium/presentation/premium_gate.dart';
import '../../data/models/author_model.dart';
import 'book_list_page.dart';

final _authorsProvider = FutureProvider<List<AuthorModel>>((ref) async {
  return ref.watch(leituraRepositoryProvider).listAuthors();
});

class AuthorListPage extends ConsumerWidget {
  const AuthorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorsAsync = ref.watch(_authorsProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Autores e Santos'),
      ),
      child: PremiumGate(
        feature: PremiumFeature.leituras,
        child: SafeArea(
          child: authorsAsync.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Não foi possível carregar os autores.',
                style: context.textStyles.secondary,
              ),
            ),
            data: (authors) {
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  IaculaSpacing.md,
                  IaculaSpacing.md,
                  IaculaSpacing.md,
                  IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: authors.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: IaculaSpacing.sm),
                itemBuilder: (context, index) {
                  final author = authors[index];
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => BookListPage(
                            authorId: author.id,
                            authorName: author.name,
                            title: author.name,
                          ),
                        ),
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
                                Text(
                                  author.name,
                                  style: context.textStyles.cardTitle,
                                ),
                                if (author.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    author.description,
                                    style: context.textStyles.secondary,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '${author.worksCount}',
                            style: context.textStyles.secondary,
                          ),
                          const SizedBox(width: IaculaSpacing.sm),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: context.colors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
