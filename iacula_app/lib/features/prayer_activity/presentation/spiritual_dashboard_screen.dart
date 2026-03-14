import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../domain/entities/dashboard_stats.dart';
import 'widgets/calendar_heat_map.dart';
import 'widgets/stats_card.dart';

class SpiritualDashboardScreen extends ConsumerWidget {
  const SpiritualDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text(
          'Painel Espiritual',
          style: context.textStyles.cardTitle,
        ),
      ),
      child: PremiumGate(
        feature: PremiumFeature.streakDashboard,
        child: _DashboardContent(),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) => _DashboardBody(stats: stats),
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => Center(
        child: Text('Erro ao carregar dados', style: context.textStyles.secondary),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak highlight
            IaculaSoftCard(
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats.currentStreak} ${stats.currentStreak == 1 ? 'dia' : 'dias'}',
                          style: context.textStyles.sectionTitle,
                        ),
                        Text(
                          'Sequência atual',
                          style: context.textStyles.secondary,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${stats.longestStreak}',
                        style: context.textStyles.sectionTitle,
                      ),
                      Text(
                        'Recorde',
                        style: context.textStyles.secondary.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: IaculaSpacing.lg),

            // Calendar heat map
            const IaculaSectionHeader(title: 'Atividade Mensal'),
            const SizedBox(height: IaculaSpacing.sm),
            IaculaSoftCard(
              child: CalendarHeatMap(
                activityByDate: stats.activityByDate,
                goalMinutes: stats.dailyGoalMinutes,
              ),
            ),
            const SizedBox(height: IaculaSpacing.lg),

            // Stats grid
            const IaculaSectionHeader(title: 'Estatísticas'),
            const SizedBox(height: IaculaSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    icon: CupertinoIcons.time,
                    value: '${stats.totalMinutes}',
                    label: 'Minutos totais',
                  ),
                ),
                const SizedBox(width: IaculaSpacing.sm),
                Expanded(
                  child: StatsCard(
                    icon: CupertinoIcons.book,
                    value: '${stats.totalPrayers}',
                    label: 'Orações',
                  ),
                ),
              ],
            ),
            const SizedBox(height: IaculaSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    icon: CupertinoIcons.heart,
                    value: '${stats.totalMeditations}',
                    label: 'Meditações',
                  ),
                ),
                const SizedBox(width: IaculaSpacing.sm),
                Expanded(
                  child: StatsCard(
                    icon: CupertinoIcons.circle_grid_3x3,
                    value: '${stats.totalRosaries}',
                    label: 'Rosários',
                  ),
                ),
              ],
            ),
            const SizedBox(height: IaculaSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    icon: CupertinoIcons.checkmark_shield,
                    value: '${stats.totalExaminations}',
                    label: 'Exames',
                  ),
                ),
                const SizedBox(width: IaculaSpacing.sm),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
