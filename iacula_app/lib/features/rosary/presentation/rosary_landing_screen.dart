import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/rosary_mystery_set.dart';
import 'rosary_prayer_screen.dart';

class RosaryLandingScreen extends ConsumerWidget {
  const RosaryLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayType = RosaryMysteryTypeX.forDay(DateTime.now());
    final mysterySetAsync = ref.watch(rosaryMysterySetProvider(todayType));

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text('Rosário', style: context.textStyles.cardTitle),
      ),
      child: SafeArea(
        child: mysterySetAsync.when(
          data: (mysterySet) {
            if (mysterySet == null) {
              return Center(
                child: Text(
                  'Conteúdo não disponível',
                  style: context.textStyles.secondary,
                ),
              );
            }
            return _LandingContent(
              mysterySet: mysterySet,
              todayType: todayType,
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(
            child: Text('Erro ao carregar', style: context.textStyles.secondary),
          ),
        ),
      ),
    );
  }
}

class _LandingContent extends ConsumerWidget {
  const _LandingContent({
    required this.mysterySet,
    required this.todayType,
  });

  final RosaryMysterySet mysterySet;
  final RosaryMysteryType todayType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSetsAsync = ref.watch(allRosaryMysterySetProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Today's mystery
          IaculaSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mistérios de Hoje',
                  style: context.textStyles.secondary.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  todayType.label,
                  style: context.textStyles.sectionTitle,
                ),
                const SizedBox(height: 16),
                // Mystery list
                for (int i = 0; i < mysterySet.mysteries.length; i++) ...[
                  Text(
                    '${i + 1}° ${mysterySet.mysteries[i].name}',
                    style: context.textStyles.cardTitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fruto: ${mysterySet.mysteries[i].fruit}',
                    style: context.textStyles.secondary.copyWith(fontSize: 13),
                  ),
                  if (i < mysterySet.mysteries.length - 1)
                    const SizedBox(height: 12),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: IaculaPrimaryPillButton(
                    label: 'Iniciar Rosário',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => RosaryPrayerScreen(
                            mysterySet: mysterySet,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: IaculaSpacing.xl),

          // Other mystery sets
          Text(
            'Outros Mistérios',
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: IaculaSpacing.sm),
          allSetsAsync.when(
            data: (allSets) => Column(
              children: allSets
                  .where((s) => s.type != todayType)
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
                      child: _MysterySetCard(mysterySet: s),
                    ),
                  )
                  .toList(),
            ),
            loading: () => const CupertinoActivityIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MysterySetCard extends StatelessWidget {
  const _MysterySetCard({required this.mysterySet});

  final RosaryMysterySet mysterySet;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => RosaryPrayerScreen(mysterySet: mysterySet),
          ),
        );
      },
      child: IaculaSoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mysterySet.type.label,
                    style: context.textStyles.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${mysterySet.mysteries.length} mistérios',
                    style: context.textStyles.secondary.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
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
