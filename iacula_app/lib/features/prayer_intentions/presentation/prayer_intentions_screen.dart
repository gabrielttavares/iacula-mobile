// lib/features/prayer_intentions/presentation/prayer_intentions_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_input.dart';
import '../../../core/presentation/design/iacula_modal.dart';
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
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16, 12, 16,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: state.isLoading && state.openIntentions.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: CupertinoActivityIndicator()),
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
                                  CupertinoIcons.heart,
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
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final intention = state.openIntentions[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: IaculaSpacing.sm,
                              ),
                              child: Dismissible(
                                key: Key(intention.id),
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
                                  notifier.deleteIntention(intention.id);
                                },
                                child: IntentionRow(
                                  intention: intention,
                                  onTap: () => _showAddEditSheet(
                                    context, notifier, intention,
                                  ),
                                  onRespond: () async {
                                    final confirmed = await IaculaModal.showConfirm(
                                      context: context,
                                      title: 'Marcar como respondida',
                                      message: 'Sua oração foi atendida?',
                                      confirmLabel: 'Sim, respondida',
                                    );
                                    if (confirmed) {
                                      notifier.markResponded(intention.id);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          childCount: state.openIntentions.length,
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
    return Padding(
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
