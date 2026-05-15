import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_input.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/custom_phrase.dart';
import '../domain/entities/phrase_schedule.dart';
import 'widgets/schedule_form_widgets.dart';

class EditTextPhraseScreen extends ConsumerStatefulWidget {
  const EditTextPhraseScreen({this.existing, super.key});

  final CustomPhrase? existing;

  @override
  ConsumerState<EditTextPhraseScreen> createState() =>
      _EditTextPhraseScreenState();
}

class _EditTextPhraseScreenState extends ConsumerState<EditTextPhraseScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.existing?.text ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _save() {
    final text = _textController.text.trim();
    if (text.length < 5 || text.length > 300) {
      IaculaModal.showAlert(
        context: context,
        title: 'Ajuste o texto',
        message: 'A frase precisa ter entre 5 e 300 caracteres.',
      );
      return;
    }

    final phrase = (widget.existing ??
            CustomPhrase(
              id: const Uuid().v4(),
              text: text,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              schedule: const PhraseSchedule(type: PhraseScheduleType.daily),
            ))
        .copyWith(
      text: text,
      displayOnHero: true,
      displayAsNotification: true,
      useFixedSchedule: false,
      schedule: const PhraseSchedule(type: PhraseScheduleType.daily),
      prayerSlug: null,
      prayerTitle: null,
    );

    ref.read(customPhrasesNotifierProvider.notifier).save(phrase);
    Navigator.pop(context);
  }

  void _delete() async {
    final confirmed = await IaculaModal.showConfirm(
      context: context,
      title: 'Remover frase',
      message: 'Tem certeza que deseja remover esta frase?',
      confirmLabel: 'Remover',
      destructive: true,
    );

    if (confirmed && mounted) {
      ref
          .read(customPhrasesNotifierProvider.notifier)
          .delete(widget.existing!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle:
            Text(widget.existing == null ? 'Nova Frase' : 'Editar Frase'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ScheduleSection(
                    title: 'FRASE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IaculaTextInput(
                          controller: _textController,
                          placeholder: 'Escreva uma frase espiritual...',
                          maxLines: 5,
                          padding: const EdgeInsets.all(12),
                          onChanged: (val) => setState(() {}),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_textController.text.length}/300',
                          style: context.textStyles.secondary
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (widget.existing != null) ...[
                    const SizedBox(height: 24),
                    CupertinoButton(
                      onPressed: _delete,
                      child: const Text(
                        'Remover Frase',
                        style:
                            TextStyle(color: CupertinoColors.destructiveRed),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: IaculaPrimaryPillButton(
                label: 'Salvar',
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
