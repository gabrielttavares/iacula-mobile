import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/design/iacula_feedback.dart';
import '../../../../core/presentation/design/iacula_modal.dart';
import '../../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../custom_phrases/domain/entities/custom_phrase.dart';
import '../../../custom_phrases/presentation/edit_phrase_screen.dart';
import '../../../liturgical/domain/liturgical_season.dart';

class CustomPhrasesTab extends ConsumerStatefulWidget {
  const CustomPhrasesTab({super.key});

  @override
  ConsumerState<CustomPhrasesTab> createState() => _CustomPhrasesTabState();
}

class _CustomPhrasesTabState extends ConsumerState<CustomPhrasesTab> {
  bool _customPhrasesOnly = false;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    if (!mounted) return;

    setState(() {
      _customPhrasesOnly = settings.customPhrasesOnly;
      _settingsLoaded = true;
    });
  }

  Future<void> _toggleCustomPhrasesOnly(bool value) async {
    final previous = _customPhrasesOnly;
    setState(() {
      _customPhrasesOnly = value;
    });

    try {
      final current = await ref.read(getSettingsUseCaseProvider).call();
      final updated = current.copyWith(customPhrasesOnly: value);
      await ref.read(updateSettingsUseCaseProvider).call(updated);

      final season =
          await ref.read(liturgicalSeasonServiceProvider).getCurrentSeason();
      await ref.read(rebuildNotificationsUseCaseProvider).call(
        updated,
        isEasterSeason: season == LiturgicalSeason.easter,
        showImmediate: false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _customPhrasesOnly = previous;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final phrasesAsync = ref.watch(customPhrasesNotifierProvider);
    final notifier = ref.read(customPhrasesNotifierProvider.notifier);

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        28 + MediaQuery.paddingOf(context).bottom,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            IaculaSoftCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usar apenas minhas frases',
                          style: context.textStyles.cardTitle.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Substitui as jaculatórias do tempo pelas suas frases personalizadas.',
                          style: context.textStyles.secondary.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CupertinoSwitch(
                    value: _customPhrasesOnly,
                    onChanged: _settingsLoaded
                        ? (value) {
                            HapticFeedback.selectionClick();
                            _toggleCustomPhrasesOnly(value);
                          }
                        : null,
                    activeTrackColor: context.colors.primaryButton,
                  ),
                ],
              ),
            ),
            const SizedBox(height: IaculaSpacing.sm),
            phrasesAsync.when(
              data: (phrases) {
                if (phrases.isEmpty) {
                  return _EmptyState(
                    onAction: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const EditPhraseScreen(),
                      ),
                    ),
                  );
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey<int>(phrases.length),
                    children: [
                      for (int i = 0; i < phrases.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
                          child: Dismissible(
                            key: Key(phrases[i].id),
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
                                message:
                                    'Tem certeza que deseja remover esta frase?',
                                confirmLabel: 'Remover',
                                destructive: true,
                              );
                            },
                            onDismissed: (_) {
                              HapticFeedback.mediumImpact();
                              notifier.delete(phrases[i].id);
                            },
                            child: _PhraseRow(
                              phrase: phrases[i],
                              onToggle: (val) {
                                HapticFeedback.selectionClick();
                                notifier.toggleActive(phrases[i].id);
                              },
                              onTap: () => Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) =>
                                      EditPhraseScreen(existing: phrases[i]),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(IaculaSpacing.md),
                child: IaculaShimmerList(itemCount: 3),
              ),
              error: (err, stack) => Center(
                child: IaculaErrorState(
                  title: 'Erro ao carregar frases',
                  message: 'Tente novamente para atualizar suas frases.',
                  onRetry: () => ref.invalidate(customPhrasesNotifierProvider),
                ),
              ),
            ),
          ],
        ),
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
              'Nenhuma frase personalizada ainda',
              style: context.textStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Suas frases aparecem no destaque da tela inicial junto com as jaculatórias do tempo, e também como notificações nos horários que você escolher.',
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
                    style:
                        context.textStyles.secondary.copyWith(fontSize: 12),
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
