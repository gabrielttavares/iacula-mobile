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
import '../../../core/presentation/widgets/iacula_spring_button.dart';
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
  _MeditationFilter _selectedFilter = _MeditationFilter.all;

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
          /* SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: IaculaSpacing.md),
              child: Column(
                children: [
                  _FilterChips(
                    filters: _MeditationFilter.values,
                    selected: _selectedFilter,
                    onSelected: (f) => setState(() => _selectedFilter = f),
                  ),
                  const SizedBox(height: IaculaSpacing.md),
                ],
              ),
            ),
          ), */
          ...catalogAsync.when(
            data: (items) {
              final textItems = items
                  .where((item) => item.type == MeditationType.text)
                  .toList(growable: false);
              return _buildSliverFeed(context, textItems);
            },
            loading: () => [
              SliverPadding(
                padding: const EdgeInsets.all(IaculaSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: const [
                      IaculaShimmerCard(height: 280),
                      SizedBox(height: IaculaSpacing.md),
                      IaculaShimmerList(itemCount: 3),
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

  List<MeditationItem> _applyFilter(List<MeditationItem> items) {
    if (_selectedFilter == _MeditationFilter.all) return items;
    final tags = _selectedFilter.tags;
    return items
        .where(
          (item) =>
              item.categoryTags.any((tag) => tags.contains(tag.toLowerCase())),
        )
        .toList(growable: false);
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
              'Não encontramos meditações para este caminho. Tente outro filtro.',
              style: context.textStyles.secondary,
            ),
          ),
        ),
      ];
    }

    final heroAdapter = SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: IaculaSpacing.md),
        child: _MeditationHeroCard(
          item: items.first,
          onTap: () => _openMeditationDetail(context, items.first),
        ),
      ),
    );

    final library = items.skip(1).toList(growable: false);

    final slivers = <Widget>[heroAdapter];
    if (items.length == 1) return slivers;

    if (library.isEmpty) {
      return slivers;
    }

    final librarySliverPadding = SliverPadding(
      padding: EdgeInsets.only(
        top: 16,
        left: IaculaSpacing.md,
        right: IaculaSpacing.md,
        bottom: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = library[index];
          return _MeditationGridCard(
            item: item,
            onTap: () => _openMeditationDetail(context, item),
          );
        }, childCount: library.length),
      ),
    );

    slivers.add(librarySliverPadding);
    return slivers;
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

enum _MeditationFilter {
  all('Todos', <String>[]),
  silence('Silêncio e presença de Deus', <String>[
    'espiritual',
    'contemplacao',
    'silencio',
  ]),
  gospel('Evangelho do dia', <String>['evangelho']),
  examen('Exame e revisão do dia', <String>['diario', 'exame']),
  dailyRhythm('Ritmo de oração diário', <String>['foco', 'manha', 'noite']);

  const _MeditationFilter(this.label, this.tags);

  final String label;
  final List<String> tags;
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<_MeditationFilter> filters;
  final _MeditationFilter selected;
  final ValueChanged<_MeditationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;
          return IaculaSpringButton(
            scaleFactor: 0.92,
            onTap: () => onSelected(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primaryButton
                    : context.colors.card,
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFD1D1D6)),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? context.colors.background
                      : context.colors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MeditationGridCard extends StatelessWidget {
  const _MeditationGridCard({required this.item, required this.onTap});

  final MeditationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        showShadow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypeGlyph(type: item.type, size: 32, iconSize: 16),
            const SizedBox(height: 12),
            Text(
              item.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.cardTitle,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                item.summary,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.durationLabel != null)
                  _Badge(text: item.durationLabel!),
                if (item.availability.kind == MeditationAvailabilityKind.daily)
                  const _Badge(text: 'Diário'),
              ],
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

BoxDecoration _getGradientForType(MeditationType type, BuildContext context) {
  final LinearGradient gradient = switch (type) {
    MeditationType.video => const LinearGradient(
      colors: [Color(0xFF673AB7), Color(0xFFE91E63)], // Deep Purple to Magenta
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    MeditationType.audio => const LinearGradient(
      colors: [Color(0xFF0D47A1), Color(0xFF00BCD4)], // Deep Blue to Cyan
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    MeditationType.text => const LinearGradient(
      colors: [Color(0xFFE64A19), Color(0xFFFFEB3B)], // Deep Orange to Yellow
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  };

  return BoxDecoration(gradient: gradient);
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: context.colors.background,
        ),
      ),
    );
  }
}

class _MeditationHeroCard extends StatelessWidget {
  const _MeditationHeroCard({required this.item, required this.onTap});

  final MeditationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.type) {
      MeditationType.video => CupertinoIcons.play_circle_fill,
      MeditationType.audio => CupertinoIcons.waveform,
      MeditationType.text => CupertinoIcons.doc_text_fill,
    };

    return IaculaTouchableCard(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 280,
          decoration: _getGradientForType(
            item.type,
            context,
          ).copyWith(borderRadius: BorderRadius.circular(24)),
          child: Stack(
            children: [
              Positioned(
                bottom: -20,
                right: -20,
                child: Icon(
                  icon,
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                  size: 160,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroBadge(text: item.sourceName),
                        if (item.durationLabel != null)
                          _HeroBadge(text: item.durationLabel!),
                        if (item.availability.kind ==
                            MeditationAvailabilityKind.daily)
                          const _HeroBadge(text: 'Diário'),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFFFFFFF).withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF000000),
        ),
      ),
    );
  }
}
