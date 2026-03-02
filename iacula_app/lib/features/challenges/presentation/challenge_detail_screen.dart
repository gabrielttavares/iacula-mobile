import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_progress_bar.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../../prayer_activity/domain/entities/prayer_activity_entry.dart';
import '../domain/entities/challenge.dart';
import '../domain/entities/challenge_progress.dart';

final _challengeProgressProvider =
    FutureProvider.family<ChallengeProgress?, String>((ref, challengeId) async {
  return ref.watch(challengeProgressRepositoryProvider).getProgress(challengeId);
});

class ChallengeDetailScreen extends ConsumerWidget {
  const ChallengeDetailScreen({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(_challengeProgressProvider(challenge.id));

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text(
          challenge.title,
          style: context.textStyles.cardTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      child: SafeArea(
        child: progressAsync.when(
          data: (progress) => _DetailContent(
            challenge: challenge,
            progress: progress,
          ),
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => Center(
            child: Text('Erro', style: context.textStyles.secondary),
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.challenge, required this.progress});

  final Challenge challenge;
  final ChallengeProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = progress != null && !progress!.isCompleted;
    final currentDay = isActive ? progress!.currentDay : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description
          IaculaSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primaryButton.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${challenge.durationDays} dias',
                        style: context.textStyles.secondary.copyWith(
                          color: context.colors.primaryButton,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.secondaryButton,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        challenge.category.label,
                        style: context.textStyles.secondary.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  challenge.description,
                  style: context.textStyles.secondary,
                ),
                const SizedBox(height: 16),
                if (!isActive)
                  IaculaPrimaryPillButton(
                    label: 'Iniciar Desafio',
                    onPressed: () => _startChallenge(ref, context),
                  )
                else ...[
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: IaculaProgressBar(
                      value: progress!.completedDays.length /
                          challenge.durationDays,
                      backgroundColor: context.colors.systemGray6,
                      color: context.colors.success,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${progress!.completedDays.length}/${challenge.durationDays} dias concluídos • Dia $currentDay',
                    style: context.textStyles.secondary.copyWith(fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: IaculaSpacing.lg),

          // Day list
          for (int i = 0; i < challenge.content.length; i++) ...[
            _DayCard(
              day: challenge.content[i],
              isCompleted:
                  progress?.isDayCompleted(challenge.content[i].dayNumber) ??
                      false,
              isCurrentDay:
                  isActive && challenge.content[i].dayNumber == currentDay,
              isFuture:
                  isActive && challenge.content[i].dayNumber > currentDay,
              isActive: isActive,
              onComplete: () => _completeDay(
                ref,
                context,
                challenge.content[i].dayNumber,
              ),
            ),
            if (i < challenge.content.length - 1)
              const SizedBox(height: IaculaSpacing.sm),
          ],
        ],
      ),
    );
  }

  Future<void> _startChallenge(WidgetRef ref, BuildContext context) async {
    final isPremium =
        ref.read(premiumStatusProvider).valueOrNull?.isPremium ?? false;
    if (!isPremium) {
      PremiumGate.showModal(context, feature: PremiumFeature.challenges);
      return;
    }

    HapticFeedback.mediumImpact();
    final newProgress = ChallengeProgress(
      challengeId: challenge.id,
      startDate: DateTime.now(),
      completedDays: [],
    );
    await ref
        .read(challengeProgressRepositoryProvider)
        .saveProgress(newProgress);
    ref.invalidate(_challengeProgressProvider(challenge.id));
  }

  Future<void> _completeDay(
    WidgetRef ref,
    BuildContext context,
    int dayNumber,
  ) async {
    if (progress == null) return;
    HapticFeedback.mediumImpact();

    final updatedDays = [...progress!.completedDays, dayNumber];
    final isNowComplete = updatedDays.length >= challenge.durationDays;

    final updated = progress!.copyWith(
      completedDays: updatedDays,
      isCompleted: isNowComplete,
      completedAt: isNowComplete ? DateTime.now() : null,
    );

    await ref.read(challengeProgressRepositoryProvider).saveProgress(updated);

    // Log activity
    ref.read(prayerActivityLoggerProvider).logActivity(
          type: PrayerActivityType.challenge,
          durationSeconds: 300, // ~5 min estimated
          featureSlug: 'challenge_${challenge.id}_day$dayNumber',
        );

    ref.invalidate(_challengeProgressProvider(challenge.id));

    if (isNowComplete && context.mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Desafio Concluído!'),
          content: Text('Parabéns! Você completou "${challenge.title}".'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Concluir'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.isCompleted,
    required this.isCurrentDay,
    required this.isFuture,
    required this.isActive,
    required this.onComplete,
  });

  final ChallengeDay day;
  final bool isCompleted;
  final bool isCurrentDay;
  final bool isFuture;
  final bool isActive;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isLocked = isFuture && !isCompleted;

    return IaculaSoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? context.colors.success
                      : isCurrentDay
                          ? context.colors.primaryButton
                          : context.colors.systemGray6,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          size: 14,
                          color: CupertinoColors.white,
                        )
                      : Text(
                          '${day.dayNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCurrentDay
                                ? CupertinoColors.white
                                : context.colors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  day.title,
                  style: context.textStyles.cardTitle.copyWith(
                    fontSize: 15,
                    color: isLocked
                        ? context.colors.textSecondary
                        : context.colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (!isLocked) ...[
            const SizedBox(height: 12),
            Text(
              day.readingText,
              style: context.textStyles.secondary.copyWith(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primaryButton.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.question_circle,
                    size: 18,
                    color: context.colors.primaryButton,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      day.reflectionPrompt,
                      style: context.textStyles.secondary.copyWith(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isActive && isCurrentDay && !isCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: IaculaPrimaryPillButton(
                  label: 'Marcar como Concluído',
                  onPressed: onComplete,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
