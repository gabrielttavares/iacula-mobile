import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../../leituras/presentation/pages/leituras_home_page.dart';
import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/meditation_item.dart';
import 'meditation_reader_screen.dart';

class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final catalogAsync = ref.watch(meditationCatalogProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              ref.invalidate(meditationCatalogProvider);
              ref.invalidate(journalPromptCatalogProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
          ),
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(IaculaSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IaculaLargeTitle('Meditações'),
                    const SizedBox(height: 4),
                    Text(
                      'Escolha um caminho mais concreto para rezar agora.',
                      style: context.textStyles.secondary,
                    ),
                    const SizedBox(height: IaculaSpacing.md),
                    _LeiturasEntryCard(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const LeiturasHomePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...catalogAsync.when(
            data: (items) {
              final textItems = items
                  .where((item) => item.type == MeditationType.text)
                  .toList(growable: false);
              return _buildSliverFeed(context, textItems);
            },
            loading: () => [
              const SliverPadding(
                padding: EdgeInsets.all(IaculaSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      IaculaShimmerList(itemCount: 5),
                    ],
                  ),
                ),
              ),
            ],
            error: (error, stackTrace) => [
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Não foi possível abrir as meditações agora. Tente novamente em instantes.',
                    style: context.textStyles.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSliverFeed(
    BuildContext context,
    List<MeditationItem> items,
  ) {
    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Text(
              'Não encontramos meditações para este caminho.',
              style: context.textStyles.secondary,
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.only(
          left: IaculaSpacing.md,
          right: IaculaSpacing.md,
          bottom: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MeditationListCard(
                  item: item,
                  onTap: () => _openMeditationDetail(context, item),
                ),
              );
            },
            childCount: items.length,
          ),
        ),
      ),
    ];
  }

  Future<bool> _canOpenMeditation() async {
    final premiumStatus = await ref.read(premiumStatusProvider.future);
    return premiumStatus.isPremium;
  }

  Future<void> _openMeditationDetail(
    BuildContext context,
    MeditationItem item,
  ) async {
    final canOpen = await _canOpenMeditation();
    if (!mounted || !context.mounted) return;
    if (!canOpen) {
      PremiumGate.showModal(context, feature: PremiumFeature.meditation);
      return;
    }
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => MeditationReaderScreen(item: item)),
    );
  }
}

class _MeditationListCard extends StatelessWidget {
  const _MeditationListCard({required this.item, required this.onTap});

  final MeditationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        showShadow: true,
        child: Row(
          children: [
            _TypeGlyph(type: item.type, size: 52, iconSize: 24),
            const SizedBox(width: IaculaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: context.textStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.summary,
                    style: context.textStyles.secondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              color: context.colors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeiturasEntryCard extends StatelessWidget {
  const _LeiturasEntryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        showShadow: true,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.book_solid,
                color: Color(0xFFFF9500),
                size: 24,
              ),
            ),
            const SizedBox(width: IaculaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Leituras', style: context.textStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    'Aprofunde a oração com autores e santos.',
                    style: context.textStyles.secondary,
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: context.colors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeGlyph extends StatelessWidget {
  const _TypeGlyph({required this.type, this.size = 44, this.iconSize = 22});

  final MeditationType type;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      MeditationType.video => (
        CupertinoIcons.play_circle,
        context.colors.primaryButton,
      ),
      MeditationType.audio => (
        CupertinoIcons.waveform,
        const Color(0xFF34C759),
      ),
      MeditationType.text => (CupertinoIcons.doc_text, const Color(0xFFFF9500)),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
