import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../domain/entities/streak_info.dart';
import '../spiritual_dashboard_screen.dart';

class StreakHomeCard extends ConsumerWidget {
  const StreakHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakInfoProvider);

    return streakAsync.when(
      data: (streak) => _StreakCardContent(streak: streak),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StreakCardContent extends StatelessWidget {
  const _StreakCardContent({required this.streak});

  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const SpiritualDashboardScreen(),
          ),
        );
      },
      child: IaculaSoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              streak.currentStreak > 0 ? '🔥' : '🕯️',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak.currentStreak > 0
                        ? '${streak.currentStreak} ${streak.currentStreak == 1 ? 'dia' : 'dias'} em sequência'
                        : 'Comece sua sequência hoje',
                    style: context.textStyles.cardTitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    streak.hasPrayedToday
                        ? '${streak.todayMinutes} min hoje'
                        : 'Ore agora para manter a sequência',
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
