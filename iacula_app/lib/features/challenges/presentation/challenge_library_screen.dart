import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/challenge.dart';
import 'challenge_detail_screen.dart';

class ChallengeLibraryScreen extends ConsumerWidget {
  const ChallengeLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(challengeCatalogProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text(
          'Desafios e Novenas',
          style: context.textStyles.cardTitle,
        ),
      ),
      child: SafeArea(
        child: catalogAsync.when(
          data: (challenges) => _ChallengeGrid(challenges: challenges),
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(
            child: Text('Erro ao carregar', style: context.textStyles.secondary),
          ),
        ),
      ),
    );
  }
}

class _ChallengeGrid extends StatelessWidget {
  const _ChallengeGrid({required this.challenges});

  final List<Challenge> challenges;

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return Center(
        child: Text(
          'Nenhum desafio disponível',
          style: context.textStyles.secondary,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      separatorBuilder: (_, __) => const SizedBox(height: IaculaSpacing.sm),
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _ChallengeCard(challenge: challenge);
      },
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => ChallengeDetailScreen(challenge: challenge),
          ),
        );
      },
      child: IaculaSoftCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.primaryButton.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${challenge.durationDays}',
                  style: context.textStyles.sectionTitle.copyWith(
                    color: context.colors.primaryButton,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.secondaryButton,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          challenge.category.label,
                          style: context.textStyles.secondary.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${challenge.durationDays} dias',
                        style: context.textStyles.secondary.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    challenge.title,
                    style: context.textStyles.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.secondary.copyWith(fontSize: 14),
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
