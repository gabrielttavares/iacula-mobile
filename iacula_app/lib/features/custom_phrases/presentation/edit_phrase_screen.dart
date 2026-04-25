import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_input.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_calendar_modal.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/custom_phrase.dart';
import '../domain/entities/phrase_schedule.dart';

class EditPhraseScreen extends ConsumerStatefulWidget {
  const EditPhraseScreen({this.existing, super.key});

  final CustomPhrase? existing;

  @override
  ConsumerState<EditPhraseScreen> createState() => _EditPhraseScreenState();
}

class _EditPhraseScreenState extends ConsumerState<EditPhraseScreen> {
  late final TextEditingController _textController;
  late bool _displayOnHero;
  late bool _displayAsNotification;
  late PhraseScheduleType _scheduleType;
  late List<int> _daysOfWeek;
  late List<String> _specificDates;
  late List<String> _times;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _textController = TextEditingController(text: e?.text ?? '');
    _displayOnHero = e?.displayOnHero ?? true;
    _displayAsNotification = e?.displayAsNotification ?? true;
    _scheduleType = e?.schedule.type ?? PhraseScheduleType.daily;
    _daysOfWeek = List.from(e?.schedule.daysOfWeek ?? []);
    _specificDates = List.from(e?.schedule.specificDates ?? []);
    _times = List.from(e?.schedule.times ?? []);
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

    if (!_displayOnHero && !_displayAsNotification) {
      IaculaModal.showAlert(
        context: context,
        title: 'Forma de exibição',
        message: 'Selecione pelo menos uma opção: Destaque do Início ou Notificação.',
      );
      return;
    }

    if (_scheduleType == PhraseScheduleType.weekly && _daysOfWeek.isEmpty) {
      IaculaModal.showAlert(
        context: context,
        title: 'Escolha os dias',
        message: 'Selecione pelo menos um dia da semana.',
      );
      return;
    }

    if (_scheduleType == PhraseScheduleType.specificDates && _specificDates.isEmpty) {
      IaculaModal.showAlert(
        context: context,
        title: 'Escolha as datas',
        message: 'Selecione pelo menos uma data.',
      );
      return;
    }

    if (_times.isEmpty) {
      IaculaModal.showAlert(
        context: context,
        title: 'Escolha os horários',
        message: 'Selecione pelo menos um horário.',
      );
      return;
    }

    final phrase = (widget.existing ??
            CustomPhrase(
              id: const Uuid().v4(),
              text: text,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              schedule: PhraseSchedule(type: _scheduleType),
            ))
        .copyWith(
      text: text,
      displayOnHero: _displayOnHero,
      displayAsNotification: _displayAsNotification,
      schedule: PhraseSchedule(
        type: _scheduleType,
        daysOfWeek: _daysOfWeek,
        specificDates: _specificDates,
        times: _times,
      ),
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
      ref.read(customPhrasesNotifierProvider.notifier).delete(widget.existing!.id);
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
        middle: Text(widget.existing == null ? 'Nova Frase' : 'Editar Frase'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Section(
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
                          style: context.textStyles.secondary.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'EXIBIR EM',
                    child: IaculaSoftCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _ToggleRow(
                            label: 'Destaque do Início',
                            value: _displayOnHero,
                            onChanged: (v) => setState(() => _displayOnHero = v),
                          ),
                          const _Divider(),
                          _ToggleRow(
                            label: 'Notificação',
                            value: _displayAsNotification,
                            onChanged: (v) => setState(() => _displayAsNotification = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _Section(
                    title: 'RECORRÊNCIA',
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<PhraseScheduleType>(
                            groupValue: _scheduleType,
                            children: const {
                              PhraseScheduleType.daily: Text('Diário', style: TextStyle(fontSize: 13)),
                              PhraseScheduleType.weekly: Text('Semanal', style: TextStyle(fontSize: 13)),
                              PhraseScheduleType.specificDates: Text('Datas', style: TextStyle(fontSize: 13)),
                            },
                            onValueChanged: (v) {
                              if (v != null) setState(() => _scheduleType = v);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _scheduleType == PhraseScheduleType.weekly
                              ? _DaySelector(
                                  key: const ValueKey<String>('weekly'),
                                  selected: _daysOfWeek,
                                  onChanged: (days) => setState(() => _daysOfWeek = days),
                                )
                              : _scheduleType == PhraseScheduleType.specificDates
                                  ? _DateSelector(
                                      key: const ValueKey<String>('specificDates'),
                                      dates: _specificDates,
                                      onChanged: (dates) => setState(() => _specificDates = dates),
                                    )
                                  : const SizedBox.shrink(key: ValueKey<String>('daily')),
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'HORÁRIOS',
                    child: _TimeSelector(
                      times: _times,
                      onChanged: (times) => setState(() => _times = times),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(IaculaSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.primaryButton.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(IaculaRadius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Será exibida:',
                          style: context.textStyles.secondary.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          PhraseSchedule(
                            type: _scheduleType,
                            daysOfWeek: _daysOfWeek,
                            specificDates: _specificDates,
                            times: _times,
                          ).summary(),
                          style: context.textStyles.cardTitle.copyWith(fontSize: 14),
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
                        style: TextStyle(color: CupertinoColors.destructiveRed),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
          child: Text(
            title,
            style: context.textStyles.secondary.copyWith(
              fontSize: 11,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textStyles.cardTitle.copyWith(fontSize: 15)),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: context.colors.primaryButton,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: context.colors.separator,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({super.key, required this.selected, required this.onChanged});
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSelected = selected.contains(dayNum);
        return GestureDetector(
          onTap: () {
            final newSelected = List<int>.from(selected);
            if (isSelected) {
              newSelected.remove(dayNum);
            } else {
              newSelected.add(dayNum);
            }
            onChanged(newSelected);
          },
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? context.colors.primaryButton : context.colors.card,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Text(
              days[index],
              style: TextStyle(
                color: isSelected ? context.colors.background : context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({super.key, required this.dates, required this.onChanged});
  final List<String> dates;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dates.map((date) => _Chip(
            label: _formatDate(date),
            onDelete: () {
              final next = List<String>.from(dates)..remove(date);
              onChanged(next);
            },
          )).toList(),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showPicker(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.add_circled, size: 20),
              const SizedBox(width: 6),
              const Text('Adicionar data', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) async {
    final dt = await IaculaModal.showSheet<DateTime>(
      context: context,
      builder: (ctx) => IaculaCalendarModal(
        initialDate: DateTime.now(),
      ),
    );

    if (dt != null && context.mounted) {
      final str =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      if (!dates.contains(str)) {
        onChanged(List.from(dates)..add(str));
      }
    }
  }

  String _formatDate(String iso) {
    final parts = iso.split('-');
    if (parts.length < 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({required this.times, required this.onChanged});
  final List<String> times;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: times.map((time) => _Chip(
            label: time,
            onDelete: () {
              final next = List<String>.from(times)..remove(time);
              onChanged(next);
            },
          )).toList(),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showPicker(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.time, size: 20),
              const SizedBox(width: 6),
              const Text('Adicionar horário', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    IaculaModal.showSheet<void>(
      context: context,
      builder: (ctx) => SizedBox(
        height: 250,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          onDateTimeChanged: (dt) {
            final str = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            if (!times.contains(str)) {
              onChanged(List.from(times)..add(str));
            }
          },
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onDelete});
  final String label;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.separator),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Icon(CupertinoIcons.xmark_circle_fill, size: 16, color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
