import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/custom_phrase.dart';
import 'edit_phrase_screen.dart';

class CustomPhrasesScreen extends ConsumerWidget {
  const CustomPhrasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phrasesAsync = ref.watch(customPhrasesNotifierProvider);
    final notifier = ref.read(customPhrasesNotifierProvider.notifier);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: context.colors.background,
            border: null,
            largeTitle: const Text('Frases Pessoais'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const EditPhraseScreen(),
                  ),
                );
              },
              child: Icon(
                CupertinoIcons.add,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: phrasesAsync.when(
              data: (phrases) {
                if (phrases.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      onAction: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => const EditPhraseScreen(),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final phrase = phrases[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
                        child: Dismissible(
                          key: Key(phrase.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: CupertinoColors.destructiveRed,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              CupertinoIcons.delete,
                              color: context.colors.background,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            return IaculaModal.showConfirm(
                              context: context,
                              title: 'Remover frase',
                              message: 'Tem certeza que deseja remover esta frase?',
                              confirmLabel: 'Remover',
                              destructive: true,
                            );
                          },
                          onDismissed: (_) {
                            HapticFeedback.mediumImpact();
                            notifier.delete(phrase.id);
                          },
                          child: _PhraseRow(
                            phrase: phrase,
                            onToggle: (val) {
                              HapticFeedback.selectionClick();
                              notifier.toggleActive(phrase.id);
                            },
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => EditPhraseScreen(existing: phrase),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: phrases.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Erro ao carregar frases: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.quote_bubble,
              size: 48,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Você ainda não criou frases personalizadas.',
              style: context.textStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crie frases para fortalecer sua vida espiritual ao longo do dia.',
              style: context.textStyles.secondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: onAction,
              child: const Text('Criar Primeira Frase'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhraseRow extends StatelessWidget {
  const _PhraseRow({
    required this.phrase,
    required this.onToggle,
    required this.onTap,
  });

  final CustomPhrase phrase;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phrase.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.cardTitle.copyWith(
                      fontSize: 15,
                      color: phrase.isActive
                          ? context.colors.textPrimary
                          : context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phrase.schedule.summary(),
                    style: context.textStyles.secondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CupertinoSwitch(
              value: phrase.isActive,
              onChanged: onToggle,
              activeTrackColor: context.colors.primaryButton,
            ),
          ],
        ),
      ),
    );
  }
}
