import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/prayer_catalog_entry.dart';
import 'prayer_catalog_detail_screen.dart';
import 'prayer_screen.dart';

final _catalogProvider = FutureProvider<List<PrayerCatalogEntry>>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  return ref.watch(getPrayerCatalogUseCaseProvider).listAll(language: settings.language);
});

class PrayerCollectionsScreen extends ConsumerWidget {
  const PrayerCollectionsScreen({super.key});

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
              const IaculaLargeTitle('Orações'),
              const SizedBox(height: IaculaSpacing.lg),
              _PrayerCategoryCard(
                title: 'Angelus / Regina Caeli',
                icon: CupertinoIcons.bell,
                onTap: () async {
                  final settings = await ref
                      .read(getSettingsUseCaseProvider)
                      .call();
                  final prayer = await ref
                      .read(getPrayerUseCaseProvider)
                      .call(language: settings.language);
                  if (context.mounted) {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => PrayerScreen(prayer: prayer),
                      ),
                    );
                  }
                },
              ),
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
                      return _PrayerCategoryCard(
                        title: entry.title,
                        icon: CupertinoIcons.book,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) =>
                                  PrayerCatalogDetailScreen(entry: entry),
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
                  'Erro ao carregar orações',
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

class _PrayerCategoryCard extends StatelessWidget {
  const _PrayerCategoryCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
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
                color: const Color(0xFFF0F1F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: IaculaColors.primaryButton),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: IaculaText.cardTitle)),
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
