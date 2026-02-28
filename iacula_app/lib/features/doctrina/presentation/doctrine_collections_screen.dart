import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
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
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IaculaLargeTitle('Doutrina Católica'),
              const SizedBox(height: IaculaSpacing.lg),
              catalogAsync.when(
                data: (entries) => Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: IaculaSpacing.sm),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _DoctrineCard(
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
                      );
                    },
                  ),
                ),
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
                error: (_, __) => const Text(
                  'Erro ao carregar doutrina',
                  style: IaculaText.secondary,
                ),
              ),
            ],
          ),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.book,
                color: IaculaColors.primaryButton,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: IaculaText.cardTitle),
                  if (category.isNotEmpty)
                    Text(
                      category,
                      style: IaculaText.secondary,
                    ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: IaculaColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
