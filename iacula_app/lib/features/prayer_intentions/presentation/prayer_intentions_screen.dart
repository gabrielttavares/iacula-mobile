// lib/features/prayer_intentions/presentation/prayer_intentions_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_input.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_shimmer.dart';
import '../../../core/presentation/widgets/iacula_toast.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../application/prayer_intentions_notifier.dart';
import '../domain/entities/prayer_intention.dart';
import 'responded_intentions_screen.dart';
import 'widgets/intention_row.dart';

class PrayerIntentionsScreen extends ConsumerWidget {
  const PrayerIntentionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerIntentionsNotifierProvider);
    final notifier = ref.read(prayerIntentionsNotifierProvider.notifier);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: context.colors.background,
            border: null,
            largeTitle: const Text('Intenções de Oração'),
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
              16, 12, 16,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: state.isLoading && state.openIntentions.isEmpty
                ? const SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.all(IaculaSpacing.md),
                      child: IaculaShimmerList(itemCount: 4),
                    ),
                  )
                : state.openIntentions.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.pin,
                                  size: 48,
                                  color: context.colors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma intenção de oração',
                                  style: context.textStyles.cardTitle,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Adicione suas intenções para rezar por elas.',
                                  style: context.textStyles.secondary,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            key: ValueKey<int>(state.openIntentions.length),
                            children: [
                              for (int i = 0; i < state.openIntentions.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: IaculaSpacing.sm,
                                  ),
                                  child: Dismissible(
                                    key: Key(state.openIntentions[i].id),
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
                                        title: 'Remover intenção',
                                        message: 'Tem certeza que deseja remover esta intenção?',
                                        confirmLabel: 'Remover',
                                        destructive: true,
                                      );
                                    },
                                    onDismissed: (_) {
                                      HapticFeedback.mediumImpact();
                                      notifier.deleteIntention(state.openIntentions[i].id);
                                    },
                                    child: IntentionRow(
                                      intention: state.openIntentions[i],
                                      onTap: () => _showAddEditSheet(
                                        context, notifier, state.openIntentions[i],
                                      ),
                                      onReminderTap: () => _showReminderSheet(
                                        context, notifier, state.openIntentions[i],
                                      ),
                                      onRespond: () async {
                                        final confirmed = await IaculaModal.showConfirm(
                                          context: context,
                                          title: 'Marcar como respondida',
                                          message: 'Sua oração foi atendida?',
                                          confirmLabel: 'Sim, respondida',
                                        );
                                        if (confirmed) {
                                          notifier.markResponded(state.openIntentions[i].id);
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
      builder: (ctx) => _IntentionForm(
        notifier: notifier,
        existing: existing,
      ),
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
      builder: (ctx) => _ReminderSheet(
        notifier: notifier,
        intention: intention,
      ),
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
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
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
  const _ReminderSheet({
    required this.notifier,
    required this.intention,
  });

  final PrayerIntentionsNotifier notifier;
  final PrayerIntention intention;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.intention.reminderTime != null
        ? _parseReminderTime(widget.intention.reminderTime!)
        : DateTime(2000, 1, 1, 9, 0);
  }

  @override
  Widget build(BuildContext context) {
    final hasReminder = widget.intention.reminderTime != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Lembrete para esta intenção',
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: _selected,
              onDateTimeChanged: (v) => setState(() => _selected = v),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (hasReminder) ...[
                CupertinoButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await widget.notifier.clearReminder(widget.intention.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(
                    'Remover lembrete',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              const Spacer(),
              CupertinoButton.filled(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final hhmm =
                      '${_selected.hour.toString().padLeft(2, '0')}:${_selected.minute.toString().padLeft(2, '0')}';
                  await widget.notifier.setReminder(widget.intention.id, hhmm);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
