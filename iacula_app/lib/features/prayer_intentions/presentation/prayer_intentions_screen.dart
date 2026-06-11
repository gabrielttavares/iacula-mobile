// lib/features/prayer_intentions/presentation/prayer_intentions_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_input.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_toast.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../custom_phrases/domain/entities/custom_phrase.dart';
import '../../custom_phrases/presentation/edit_prayer_alarm_screen.dart';
import '../../custom_phrases/presentation/widgets/phrase_row.dart';
import '../application/prayer_intentions_notifier.dart';
import '../domain/entities/intention_schedule.dart';
import '../domain/entities/prayer_intention.dart';
import 'responded_intentions_screen.dart';
import 'widgets/intention_row.dart';
import 'widgets/intention_schedule_selector.dart';

class PrayerIntentionsScreen extends ConsumerWidget {
  const PrayerIntentionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerIntentionsNotifierProvider);
    final notifier = ref.read(prayerIntentionsNotifierProvider.notifier);
    final phrasesAsync = ref.watch(customPhrasesNotifierProvider);
    final phrasesNotifier = ref.read(customPhrasesNotifierProvider.notifier);
    final prayerAlarms = phrasesAsync.maybeWhen(
      data: (phrases) => phrases.where((p) => p.isPrayerAlarm).toList(),
      orElse: () => const <CustomPhrase>[],
    );

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: context.colors.background,
            border: null,
            largeTitle: const Text('Intenções e Alarmes'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(32, 32),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const RespondedIntentionsScreen(),
                      ),
                    );
                  },
                  child: Icon(
                    CupertinoIcons.check_mark_circled,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(32, 32),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showAddEditSheet(context, notifier, null);
                  },
                  child: Icon(
                    CupertinoIcons.add,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              ref.invalidate(prayerIntentionsNotifierProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: state.isLoading && state.openIntentions.isEmpty
                ? const SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.all(IaculaSpacing.md),
                      child: IaculaShimmerList(itemCount: 4),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(title: 'INTENÇÕES'),
                        _AddButton(
                          label: 'Adicionar intenção',
                          onTap: () =>
                              _showAddEditSheet(context, notifier, null),
                        ),
                        if (state.openIntentions.isEmpty)
                          _EmptySectionHint(
                            message: 'Nenhuma intenção ainda',
                          )
                        else
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey<int>(state.openIntentions.length),
                              children: [
                                for (
                                  int i = 0;
                                  i < state.openIntentions.length;
                                  i++
                                )
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: IaculaSpacing.sm,
                                    ),
                                    child: Dismissible(
                                      key: Key(state.openIntentions[i].id),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(
                                          right: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.destructiveRed,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          CupertinoIcons.delete,
                                          color: context.colors.background,
                                        ),
                                      ),
                                      confirmDismiss: (_) async {
                                        return IaculaModal.showConfirm(
                                          context: context,
                                          title: 'Remover intenção',
                                          message:
                                              'Tem certeza que deseja remover esta intenção?',
                                          confirmLabel: 'Remover',
                                          destructive: true,
                                        );
                                      },
                                      onDismissed: (_) {
                                        HapticFeedback.mediumImpact();
                                        notifier.deleteIntention(
                                          state.openIntentions[i].id,
                                        );
                                      },
                                      child: IntentionRow(
                                        intention: state.openIntentions[i],
                                        onTap: () => _showAddEditSheet(
                                          context,
                                          notifier,
                                          state.openIntentions[i],
                                        ),
                                        onReminderTap: () => _showReminderSheet(
                                          context,
                                          notifier,
                                          state.openIntentions[i],
                                        ),
                                        onRespond: () async {
                                          final confirmed =
                                              await IaculaModal.showConfirm(
                                                context: context,
                                                title: 'Marcar como respondida',
                                                message:
                                                    'Sua oração foi atendida?',
                                                confirmLabel: 'Sim, respondida',
                                              );
                                          if (confirmed) {
                                            notifier.markResponded(
                                              state.openIntentions[i].id,
                                            );
                                            if (context.mounted) {
                                              IaculaToast.show(
                                                context,
                                                'Oração atendida! 🙏',
                                                icon: CupertinoIcons.heart_fill,
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: IaculaSpacing.lg),
                        _PrayerAlarmsSection(
                          alarms: prayerAlarms,
                          notifier: phrasesNotifier,
                        ),
                        const SizedBox(height: IaculaSpacing.lg),
                        Text(
                          'Suas intenções ficam salvas apenas no seu celular. Ninguém terá acesso ao que você escrever.',
                          style: context.textStyles.secondary
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddEditSheet(
    BuildContext context,
    PrayerIntentionsNotifier notifier,
    PrayerIntention? existing,
  ) {
    IaculaModal.showSheet<void>(
      context: context,
      maxHeightFraction: 0.7,
      builder: (ctx) => _IntentionForm(notifier: notifier, existing: existing),
    );
  }

  void _showReminderSheet(
    BuildContext context,
    PrayerIntentionsNotifier notifier,
    PrayerIntention intention,
  ) {
    IaculaModal.showSheet<void>(
      context: context,
      maxHeightFraction: 0.5,
      builder: (ctx) =>
          _ReminderSheet(notifier: notifier, intention: intention),
    );
  }
}

class _IntentionForm extends StatefulWidget {
  const _IntentionForm({required this.notifier, this.existing});

  final PrayerIntentionsNotifier notifier;
  final PrayerIntention? existing;

  @override
  State<_IntentionForm> createState() => _IntentionFormState();
}

class _IntentionFormState extends State<_IntentionForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existing?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'Nova Intenção' : 'Editar Intenção',
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: 16),
          IaculaTextInput(
            controller: _titleController,
            placeholder: 'Título da intenção',
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          IaculaTextInput(
            controller: _descriptionController,
            placeholder: 'Descrição (opcional)',
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () {
              HapticFeedback.lightImpact();
              final title = _titleController.text.trim();
              if (title.isEmpty) return;
              final description = _descriptionController.text.trim();

              if (widget.existing == null) {
                widget.notifier.addIntention(
                  title: title,
                  description: description.isNotEmpty ? description : null,
                );
              } else {
                widget.notifier.updateIntention(
                  id: widget.existing!.id,
                  title: title,
                  description: description.isNotEmpty ? description : null,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

DateTime _parseReminderTime(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) {
    return DateTime(2000, 1, 1, 9, 0);
  }
  final hour = int.tryParse(parts[0]) ?? 9;
  final minute = int.tryParse(parts[1]) ?? 0;
  return DateTime(2000, 1, 1, hour.clamp(0, 23), minute.clamp(0, 59));
}

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet({required this.notifier, required this.intention});

  final PrayerIntentionsNotifier notifier;
  final PrayerIntention intention;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late IntentionSchedule _schedule;

  @override
  void initState() {
    super.initState();
    _schedule =
        widget.intention.schedule ??
        IntentionSchedule(type: IntentionScheduleType.daily, times: []);
  }

  @override
  Widget build(BuildContext context) {
    final hasReminder = widget.intention.hasReminder;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lembrete', style: context.textStyles.sectionTitle),
              if (hasReminder)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await widget.notifier.clearReminder(widget.intention.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Remover',
                    style: TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: IntentionScheduleSelector(
            schedule: _schedule,
            onChanged: (schedule) => setState(() => _schedule = schedule),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Row(
            children: [
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              const Spacer(),
              CupertinoButton.filled(
                onPressed: () async {
                  if (_schedule.times.isEmpty) {
                    HapticFeedback.heavyImpact();
                    return;
                  }
                  HapticFeedback.lightImpact();
                  await widget.notifier.setSchedule(
                    widget.intention.id,
                    _schedule,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ],
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

class _PrayerAlarmsSection extends StatelessWidget {
  const _PrayerAlarmsSection({required this.alarms, required this.notifier});

  final List<CustomPhrase> alarms;
  final dynamic notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'ALARMES DE ORAÇÃO'),
        _AddButton(
          label: 'Adicionar alarme',
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const EditPrayerAlarmScreen()),
          ),
        ),
        if (alarms.isEmpty)
          _EmptySectionHint(message: 'Nenhum alarme configurado'),
        for (final alarm in alarms)
          Padding(
            padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
            child: _DismissibleAlarmRow(alarm: alarm, notifier: notifier),
          ),
      ],
    );
  }
}

class _DismissibleAlarmRow extends StatelessWidget {
  const _DismissibleAlarmRow({required this.alarm, required this.notifier});

  final CustomPhrase alarm;
  final dynamic notifier;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: CupertinoColors.destructiveRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(CupertinoIcons.delete, color: context.colors.background),
      ),
      confirmDismiss: (_) async {
        return IaculaModal.showConfirm(
          context: context,
          title: 'Remover alarme',
          message: 'Tem certeza que deseja remover este alarme?',
          confirmLabel: 'Remover',
          destructive: true,
        );
      },
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        notifier.delete(alarm.id);
      },
      child: PhraseRow(
        phrase: alarm,
        onToggle: (val) {
          HapticFeedback.selectionClick();
          notifier.toggleActive(alarm.id);
        },
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => EditPrayerAlarmScreen(existing: alarm),
          ),
        ),
      ),
    );
  }
}
