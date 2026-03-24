import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import '../domain/entities/custom_phrase.dart';
import 'edit_phrase_screen.dart';

class CustomPhrasesScreen extends ConsumerStatefulWidget {
  const CustomPhrasesScreen({super.key});

  @override
  ConsumerState<CustomPhrasesScreen> createState() =>
      _CustomPhrasesScreenState();
}

class _CustomPhrasesScreenState extends ConsumerState<CustomPhrasesScreen> {
  bool _escrivaPointsFeedEnabled = false;
  bool _escrivaPointsFeedOptionVisible = false;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    if (!mounted) {
      return;
    }

    setState(() {
      _escrivaPointsFeedEnabled = settings.escrivaPointsFeedEnabled;
      _escrivaPointsFeedOptionVisible = settings.escrivaPointsFeedOptionVisible;
      _settingsLoaded = true;
    });
  }

  Future<void> _toggleEscrivaFeed(bool value) async {
    final previous = _escrivaPointsFeedEnabled;
    setState(() {
      _escrivaPointsFeedEnabled = value;
    });

    try {
      final current = await ref.read(getSettingsUseCaseProvider).call();
      final updated = current.copyWith(escrivaPointsFeedEnabled: value);
      await ref.read(updateSettingsUseCaseProvider).call(updated);

      final schedulerRepo = ref.read(notificationSchedulerRepositoryProvider);
      await schedulerRepo.cancelAll();
      await ScheduleCoreRemindersUseCase(
        schedulerRepo,
        quoteFetcher: ({required String language, required DateTime now}) {
          if (value) {
            return ref
                .read(getNextEscrivaPointsQuoteUseCaseProvider)
                .call(language: language, now: now);
          }

          return ref
              .read(getNextQuoteUseCaseProvider)
              .call(language: language, now: now);
        },
        notificationHistoryRepository: ref.read(
          notificationHistoryRepositoryProvider,
        ),
        lastDeliveredCardRepository: ref.read(
          lastDeliveredCardRepositoryProvider,
        ),
      ).call(updated);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _escrivaPointsFeedEnabled = previous;
      });
    }
  }

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
            largeTitle: const Text('Frases Personalizadas'),
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
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              ref.invalidate(customPhrasesNotifierProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
          ),
          if (_escrivaPointsFeedOptionVisible)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: IaculaSoftCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pontos de Caminho/Sulco/Forja',
                              style: context.textStyles.cardTitle.copyWith(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Usa estes conteúdos no lugar das jaculatórias.',
                              style: context.textStyles.secondary.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      CupertinoSwitch(
                        value: _escrivaPointsFeedEnabled,
                        onChanged: _settingsLoaded
                            ? (value) {
                                HapticFeedback.selectionClick();
                                _toggleEscrivaFeed(value);
                              }
                            : null,
                        activeTrackColor: context.colors.primaryButton,
                      ),
                    ],
                  ),
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

                return SliverToBoxAdapter(
                  child: AnimatedSwitcher(
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
                                  message: 'Tem certeza que deseja remover esta frase?',
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
                                    builder: (_) => EditPhraseScreen(existing: phrases[i]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
                    title: 'Erro ao carregar frases',
                    message: 'Tente novamente para atualizar suas frases.',
                    onRetry: () => ref.invalidate(customPhrasesNotifierProvider),
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
