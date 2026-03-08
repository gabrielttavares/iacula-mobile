import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_spring_button.dart';
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../journal_prompts/domain/entities/journal_prompt.dart';
import '../domain/entities/meditation_item.dart';
import 'journal_prompt_detail_screen.dart';
import 'meditation_detail_screen.dart';
import 'models/meditation_feed_item.dart';

class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen> {
  String _selectedFilter = 'Todos';

  static const _filters = [
    'Todos',
    'Reflexão guiada',
    'Espiritual',
    'Evangelho',
    'Diário',
    'Contemplação',
  ];

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      feature: PremiumFeature.meditation,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final catalogAsync = ref.watch(meditationCatalogProvider);
    final promptsAsync = ref.watch(journalPromptCatalogProvider);

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
                      'Escolha pelo seu momento',
                      style: context.textStyles.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: IaculaSpacing.md),
              child: Column(
                children: [
                  _FilterChips(
                    filters: _filters,
                    selected: _selectedFilter,
                    onSelected: (f) => setState(() => _selectedFilter = f),
                  ),
                  const SizedBox(height: IaculaSpacing.md),
                ],
              ),
            ),
          ),
          ...catalogAsync.when(
            data: (items) {
              final prompts =
                  promptsAsync.valueOrNull ?? const <JournalPrompt>[];
              return _buildSliverFeed(
                context,
                _buildFeedItems(
                  meditations: _applyFilter(items),
                  prompts: prompts,
                ),
              );
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
                    'Não foi possível carregar as meditações.',
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
    if (_selectedFilter == 'Todos') return items;
    final tag = _selectedFilter.toLowerCase();
    return items
        .where((item) => item.categoryTags.contains(tag))
        .toList(growable: false);
  }

  List<MeditationFeedItem> _buildFeedItems({
    required List<MeditationItem> meditations,
    required List<JournalPrompt> prompts,
  }) {
    final promptGroup = _buildPromptGroup(prompts);

    if (_selectedFilter == 'Reflexão guiada') {
      return promptGroup == null
          ? const <MeditationFeedItem>[]
          : <MeditationFeedItem>[promptGroup];
    }

    final includePrompts = _selectedFilter == 'Todos';

    if (meditations.isEmpty) {
      return includePrompts
          ? promptGroup == null
                ? const <MeditationFeedItem>[]
                : <MeditationFeedItem>[promptGroup]
          : const <MeditationFeedItem>[];
    }

    final items = <MeditationFeedItem>[
      MeditationContentFeedItem(meditations.first),
      if (includePrompts && promptGroup != null) promptGroup,
      ...meditations
          .skip(1)
          .map<MeditationFeedItem>((item) => MeditationContentFeedItem(item)),
    ];

    return items;
  }

  List<Widget> _buildSliverFeed(
    BuildContext context,
    List<MeditationFeedItem> items,
  ) {
    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Text(
              'Nenhuma meditação encontrada para este filtro.',
              style: context.textStyles.secondary,
            ),
          ),
        ),
      ];
    }

    final hero = items.whereType<MeditationContentFeedItem>().firstOrNull;
    if (hero == null) {
      final promptGroup = items
          .whereType<JournalPromptGroupFeedItem>()
          .firstOrNull;
      if (promptGroup == null) {
        return [
          SliverFillRemaining(
            child: Center(
              child: Text(
                'Nenhuma meditação encontrada para este filtro.',
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
          sliver: SliverToBoxAdapter(
            child: _ReflexoesCard(
              sections: promptGroup.sections,
              onPromptTap: (prompt) => _openPromptDetail(context, prompt),
            ),
          ),
        ),
      ];
    }

    final heroAdapter = SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: IaculaSpacing.md),
        child: _MeditationHeroCard(
          item: hero.item,
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => MeditationDetailScreen(item: hero.item),
              ),
            );
          },
        ),
      ),
    );

    final promptGroup = items
        .whereType<JournalPromptGroupFeedItem>()
        .firstOrNull;
    final library = items
        .whereType<MeditationContentFeedItem>()
        .skip(1)
        .toList(growable: false);

    final slivers = <Widget>[heroAdapter];
    if (items.length == 1) return slivers;

    if (promptGroup != null) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            IaculaSpacing.md,
            16,
            IaculaSpacing.md,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _ReflexoesCard(
              sections: promptGroup.sections,
              onPromptTap: (prompt) => _openPromptDetail(context, prompt),
            ),
          ),
        ),
      );
    }

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
          final item = library[index].item;
          return _MeditationGridCard(
            item: item,
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => MeditationDetailScreen(item: item),
                ),
              );
            },
          );
        }, childCount: library.length),
      ),
    );

    slivers.add(librarySliverPadding);
    return slivers;
  }

  JournalPromptGroupFeedItem? _buildPromptGroup(List<JournalPrompt> prompts) {
    if (prompts.isEmpty) return null;

    final sections = JournalPromptCategory.values
        .map((category) {
          final items = prompts
              .where((prompt) => prompt.category == category)
              .toList(growable: false);
          if (items.isEmpty) return null;
          return JournalPromptSection(category: category, prompts: items);
        })
        .nonNulls
        .toList(growable: false);

    if (sections.isEmpty) return null;
    return JournalPromptGroupFeedItem(sections);
  }

  void _openPromptDetail(BuildContext context, JournalPrompt prompt) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => JournalPromptDetailScreen(prompt: prompt),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

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
                filter,
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

class _ReflexoesCard extends StatelessWidget {
  const _ReflexoesCard({required this.sections, required this.onPromptTap});

  final List<JournalPromptSection> sections;
  final ValueChanged<JournalPrompt> onPromptTap;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MeditationResourceHeader(
            title: 'Reflexões',
            subtitle:
                'Lectio, exame inaciano e outras perguntas para aprofundar a oração.',
            iconKind: MeditationResourceIconKind.reflexoes,
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < sections.length; index++) ...[
            if (index > 0) const SizedBox(height: 16),
            _PromptSection(section: sections[index], onPromptTap: onPromptTap),
          ],
        ],
      ),
    );
  }
}

enum MeditationResourceIconKind { reflexoes, biblia, rosario }

extension on MeditationResourceIconKind {
  String get assetPath => switch (this) {
    // Intended CC0/usable replacements from SVG Repo sources:
    // reflections/catholic-prayers, holy-bible, rosary.
    MeditationResourceIconKind.reflexoes =>
      'assets/seed/icons/meditation_resources/reflexoes.svg',
    MeditationResourceIconKind.biblia =>
      'assets/seed/icons/meditation_resources/biblia.svg',
    MeditationResourceIconKind.rosario =>
      'assets/seed/icons/meditation_resources/rosario.svg',
  };
}

class _MeditationResourceHeader extends StatelessWidget {
  const _MeditationResourceHeader({
    required this.title,
    required this.subtitle,
    required this.iconKind,
  });

  final String title;
  final String subtitle;
  final MeditationResourceIconKind iconKind;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: context.colors.primaryButton.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
            iconKind.assetPath,
            key: ValueKey('meditation-resource-icon-${iconKind.name}'),
            colorFilter: ColorFilter.mode(
              context.colors.primaryButton,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textStyles.cardTitle),
              const SizedBox(height: 4),
              Text(subtitle, style: context.textStyles.secondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromptSection extends StatelessWidget {
  const _PromptSection({required this.section, required this.onPromptTap});

  final JournalPromptSection section;
  final ValueChanged<JournalPrompt> onPromptTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.category.label,
          style: context.textStyles.secondary.copyWith(
            color: context.colors.primaryButton,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < section.prompts.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          IaculaTouchableCard(
            onTap: () => onPromptTap(section.prompts[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.secondaryButton,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      section.prompts[index].text,
                      style: context.textStyles.secondary.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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
