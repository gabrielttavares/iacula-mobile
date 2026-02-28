import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/doctrine_entry.dart';
import 'doctrine_detail_screen.dart';

final _catalogProvider = FutureProvider<List<DoctrineEntry>>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  return ref
      .watch(getDoctrineCatalogUseCaseProvider)
      .listAll(language: settings.language);
});

class DoctrineCollectionsScreen extends ConsumerWidget {
  const DoctrineCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(_catalogProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Doutrina Católica'),
            backgroundColor: context.colors.background,
            border: null,
          ),
          catalogAsync.when(
            data: (entries) => SliverPadding(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = entries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
                      child: _DoctrineCard(
                        title: entry.title,
                        category: entry.category,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) =>
                                  DoctrineDetailScreen(entry: entry),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: entries.length,
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Erro ao carregar doutrina',
                  style: context.textStyles.secondary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
            ),
          ),
        ],
      ),
    );

  }
}

class _DoctrineCard extends StatelessWidget {
  const _DoctrineCard({
    required this.title,
    required this.category,
    required this.onTap,
  });

  final String title;
  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.systemGray6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.book,
                color: context.colors.primaryButton,
              ),
            ),

            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textStyles.cardTitle),
                  if (category.isNotEmpty)
                    Text(
                      category,
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
