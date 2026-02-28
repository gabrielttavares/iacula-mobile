import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_spring_button.dart';
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/meditation_item.dart';
import 'meditation_detail_screen.dart';

class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen> {
  String _selectedFilter = 'Todos';

  static const _filters = [
    'Todos',
    'Espiritual',
    'Evangelho',
    'Diário',
    'Contemplação',
  ];

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(meditationCatalogProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: SafeArea(
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
              const SizedBox(height: IaculaSpacing.md),
              _FilterChips(
                filters: _filters,
                selected: _selectedFilter,
                onSelected: (f) => setState(() => _selectedFilter = f),
              ),
              const SizedBox(height: IaculaSpacing.md),
              Expanded(
                child: catalogAsync.when(
                  data: (items) => _buildFeed(context, _applyFilter(items)),
                  loading: () => const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                  error: (_, _) => Center(
                    child: Text(
                      'Não foi possível carregar as meditações.',
                      style: context.textStyles.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildFeed(BuildContext context, List<MeditationItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma meditação encontrada para este filtro.',
          style: context.textStyles.secondary,
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + IaculaSpacing.md,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _MeditationFeedCard(
          item: item,
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => MeditationDetailScreen(item: item),
              ),
            );
          },
        );
      },
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

class _MeditationFeedCard extends StatelessWidget {
  const _MeditationFeedCard({
    required this.item,
    required this.onTap,
  });

  final MeditationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        child: Row(
          children: [
            _TypeGlyph(type: item.type),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: context.textStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    item.summary,
                    style: context.textStyles.secondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Badge(text: item.sourceName),
                      if (item.durationLabel != null) ...[
                        const SizedBox(width: 8),
                        _Badge(text: item.durationLabel!),
                      ],
                      if (item.availability.kind ==
                          MeditationAvailabilityKind.daily) ...[
                        const SizedBox(width: 8),
                        const _Badge(text: 'Diário'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              color: context.colors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeGlyph extends StatelessWidget {
  const _TypeGlyph({
    required this.type,
    // ignore: unused_element_parameter
    this.size = 44,
    // ignore: unused_element_parameter
    this.iconSize = 22,
  });

  final MeditationType type;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      MeditationType.video => (CupertinoIcons.play_circle, context.colors.primaryButton),
      MeditationType.audio => (CupertinoIcons.waveform, const Color(0xFF34C759)),
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

// ignore: unused_element
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

  return BoxDecoration(
    gradient: gradient,
  );
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
