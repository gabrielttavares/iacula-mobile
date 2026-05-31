import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../custom_phrases/domain/entities/custom_phrase.dart';
import '../../custom_phrases/presentation/edit_prayer_alarm_screen.dart';
import '../../custom_phrases/presentation/edit_text_phrase_screen.dart';
import '../../custom_phrases/presentation/widgets/phrase_row.dart';
import 'builtin_quotes_screen.dart';

class MinhasJaculatoriasScreen extends ConsumerStatefulWidget {
  const MinhasJaculatoriasScreen({super.key});

  @override
  ConsumerState<MinhasJaculatoriasScreen> createState() =>
      _MinhasJaculatoriasScreenState();
}

class _MinhasJaculatoriasScreenState
    extends ConsumerState<MinhasJaculatoriasScreen> {
  @override
  Widget build(BuildContext context) {
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
            largeTitle: const Text('Minhas Jaculatórias'),
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
                final prayerAlarms =
                    phrases.where((p) => p.isPrayerAlarm).toList();
                final textPhrases =
                    phrases.where((p) => !p.isPrayerAlarm).toList();

                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'ALARMES DE ORAÇÃO'),
                      if (prayerAlarms.isEmpty)
                        _EmptySectionHint(
                          message: 'Nenhum alarme configurado',
                        ),
                      for (final alarm in prayerAlarms)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: IaculaSpacing.sm),
                          child: _DismissiblePhraseRow(
                            phrase: alarm,
                            notifier: notifier,
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) =>
                                    EditPrayerAlarmScreen(existing: alarm),
                              ),
                            ),
                          ),
                        ),
                      _AddButton(
                        label: 'Adicionar alarme',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const EditPrayerAlarmScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: IaculaSpacing.lg),
                      _SectionHeader(title: 'FRASES PESSOAIS'),
                      if (textPhrases.isEmpty)
                        _EmptySectionHint(
                          message: 'Nenhuma frase pessoal ainda',
                        ),
                      for (final phrase in textPhrases)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: IaculaSpacing.sm),
                          child: _DismissiblePhraseRow(
                            phrase: phrase,
                            notifier: notifier,
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) =>
                                    EditTextPhraseScreen(existing: phrase),
                              ),
                            ),
                          ),
                        ),
                      _AddButton(
                        label: 'Adicionar frase',
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const EditTextPhraseScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: IaculaSpacing.lg),
                      Center(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => const BuiltinQuotesScreen(),
                            ),
                          ),
                          child: Text(
                            'Gerenciar jaculatórias padrão',
                            style: context.textStyles.secondary.copyWith(
                              color: context.colors.primaryButton,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Padding(
                  padding: EdgeInsets.all(IaculaSpacing.md),
                  child: IaculaShimmerList(itemCount: 3),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: IaculaErrorState(
                    title: 'Erro ao carregar',
                    message: 'Tente novamente para atualizar.',
                    onRetry: () =>
                        ref.invalidate(customPhrasesNotifierProvider),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissiblePhraseRow extends StatelessWidget {
  const _DismissiblePhraseRow({
    required this.phrase,
    required this.notifier,
    required this.onTap,
  });

  final CustomPhrase phrase;
  final dynamic notifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
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
          title: phrase.isPrayerAlarm ? 'Remover alarme' : 'Remover frase',
          message: phrase.isPrayerAlarm
              ? 'Tem certeza que deseja remover este alarme?'
              : 'Tem certeza que deseja remover esta frase?',
          confirmLabel: 'Remover',
          destructive: true,
        );
      },
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        notifier.delete(phrase.id);
      },
      child: PhraseRow(
        phrase: phrase,
        onToggle: (val) {
          HapticFeedback.selectionClick();
          notifier.toggleActive(phrase.id);
        },
        onTap: onTap,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: context.textStyles.secondary.copyWith(
          fontSize: 11,
          letterSpacing: 1.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptySectionHint extends StatelessWidget {
  const _EmptySectionHint({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
      child: IaculaSoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Center(
          child: Text(
            message,
            style: context.textStyles.secondary.copyWith(fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Row(
        children: [
          Icon(
            CupertinoIcons.add_circled,
            size: 18,
            color: context.colors.primaryButton,
          ),
          const SizedBox(width: IaculaSpacing.xs),
          Text(
            label,
            style: context.textStyles.secondary.copyWith(
              color: context.colors.primaryButton,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
