import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
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
      backgroundColor: IaculaColors.background,
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
                style: IaculaText.secondary,
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
                  data: (items) => _buildFeed(_applyFilter(items)),
                  loading: () => const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                  error: (_, _) => Center(
                    child: Text(
                      'Não foi possível carregar as meditações.',
                      style: IaculaText.secondary,
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

  Widget _buildFeed(List<MeditationItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma meditação encontrada para este filtro.',
          style: IaculaText.secondary,
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
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
          return GestureDetector(
            onTap: () => onSelected(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? IaculaColors.primaryButton
                    : IaculaColors.card,
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
                      ? CupertinoColors.white
                      : IaculaColors.textPrimary,
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
    return GestureDetector(
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
                  Text(item.title, style: IaculaText.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    item.summary,
                    style: IaculaText.secondary,
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
            const Icon(
              CupertinoIcons.chevron_right,
              color: IaculaColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeGlyph extends StatelessWidget {
  const _TypeGlyph({required this.type});

  final MeditationType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      MeditationType.video => (CupertinoIcons.play_circle, IaculaColors.primaryButton),
      MeditationType.audio => (CupertinoIcons.waveform, const Color(0xFF34C759)),
      MeditationType.text => (CupertinoIcons.doc_text, const Color(0xFFFF9500)),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: IaculaColors.textSecondary,
        ),
      ),
    );
  }
}
