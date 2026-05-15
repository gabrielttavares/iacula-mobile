import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_buttons.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayers/domain/entities/prayer_catalog_entry.dart';
import '../domain/entities/custom_phrase.dart';
import '../domain/entities/phrase_schedule.dart';
import 'prayer_picker_sheet.dart';
import 'widgets/schedule_form_widgets.dart';

class EditPrayerAlarmScreen extends ConsumerStatefulWidget {
  const EditPrayerAlarmScreen({this.existing, this.initialPrayer, super.key});

  final CustomPhrase? existing;
  final PrayerCatalogEntry? initialPrayer;

  @override
  ConsumerState<EditPrayerAlarmScreen> createState() =>
      _EditPrayerAlarmScreenState();
}

class _EditPrayerAlarmScreenState
    extends ConsumerState<EditPrayerAlarmScreen> {
  late PhraseScheduleType _scheduleType;
  late List<int> _daysOfWeek;
  late List<String> _specificDates;
  late List<String> _times;
  PrayerCatalogEntry? _selectedPrayer;

  @override
  void initState() {
    super.initState();
    final existingPhrase = widget.existing;
    _selectedPrayer = widget.initialPrayer;
    _scheduleType = existingPhrase?.schedule.type ?? PhraseScheduleType.daily;
    _daysOfWeek = List.from(existingPhrase?.schedule.daysOfWeek ?? []);
    _specificDates = List.from(existingPhrase?.schedule.specificDates ?? []);
    _times = List.from(existingPhrase?.schedule.times ?? []);

    if (existingPhrase?.isPrayerAlarm == true && widget.initialPrayer == null) {
      _loadExistingPrayer(existingPhrase!);
    }
  }

  Future<void> _loadExistingPrayer(CustomPhrase phrase) async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    if (!mounted) return;
    final catalogEntry = await ref
        .read(getPrayerCatalogUseCaseProvider)
        .getBySlug(language: settings.language, slug: phrase.prayerSlug!);
    if (mounted && catalogEntry != null) {
      setState(() => _selectedPrayer = catalogEntry);
    }
  }

  void _save() {
    if (_selectedPrayer == null) {
      IaculaModal.showAlert(
        context: context,
        title: 'Selecione uma oração',
        message: 'Escolha uma oração do catálogo para criar o alarme.',
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

    if (_scheduleType == PhraseScheduleType.specificDates &&
        _specificDates.isEmpty) {
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

    final prayer = _selectedPrayer!;
    final phrase = (widget.existing ??
            CustomPhrase(
              id: const Uuid().v4(),
              text: prayer.title,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              schedule: PhraseSchedule(type: _scheduleType),
            ))
        .copyWith(
      text: prayer.title,
      displayOnHero: false,
      displayAsNotification: true,
      useFixedSchedule: true,
      schedule: PhraseSchedule(
        type: _scheduleType,
        daysOfWeek: _daysOfWeek,
        specificDates: _specificDates,
        times: _times,
      ),
      prayerSlug: prayer.slug,
      prayerTitle: prayer.title,
    );

    ref.read(customPhrasesNotifierProvider.notifier).save(phrase);
    Navigator.pop(context);
  }

  void _delete() async {
    final confirmed = await IaculaModal.showConfirm(
      context: context,
      title: 'Remover alarme',
      message: 'Tem certeza que deseja remover este alarme de oração?',
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

  Future<void> _pickPrayer() async {
    final entry = await PrayerPickerSheet.show(context);
    if (entry != null && mounted) {
      setState(() => _selectedPrayer = entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle =
        _selectedPrayer?.title ?? widget.existing?.prayerTitle;
    final hasPrayer = displayTitle != null;

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text(
          widget.existing == null ? 'Alarme de Oração' : 'Editar Alarme',
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ScheduleSection(
                    title: 'ORAÇÃO',
                    child: hasPrayer
                        ? IaculaSoftCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.book,
                                  size: 20,
                                  color: context.colors.primaryButton,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    displayTitle,
                                    style: context.textStyles.cardTitle
                                        .copyWith(fontSize: 15),
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(32, 32),
                                  onPressed: _pickPrayer,
                                  child: Text(
                                    'Alterar',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.colors.primaryButton,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _pickPrayer,
                            child: IaculaSoftCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.search,
                                    size: 18,
                                    color: context.colors.textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Selecionar oração...',
                                    style: context.textStyles.secondary
                                        .copyWith(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  ScheduleSection(
                    title: 'RECORRÊNCIA',
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child:
                              CupertinoSlidingSegmentedControl<PhraseScheduleType>(
                            groupValue: _scheduleType,
                            children: const {
                              PhraseScheduleType.daily: Text('Diário',
                                  style: TextStyle(fontSize: 13)),
                              PhraseScheduleType.weekly: Text('Semanal',
                                  style: TextStyle(fontSize: 13)),
                              PhraseScheduleType.specificDates: Text('Datas',
                                  style: TextStyle(fontSize: 13)),
                            },
                            onValueChanged: (value) {
                              if (value != null) {
                                setState(() => _scheduleType = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _scheduleType == PhraseScheduleType.weekly
                              ? DaySelector(
                                  key: const ValueKey<String>('weekly'),
                                  selected: _daysOfWeek,
                                  onChanged: (days) =>
                                      setState(() => _daysOfWeek = days),
                                )
                              : _scheduleType ==
                                      PhraseScheduleType.specificDates
                                  ? DateSelector(
                                      key: const ValueKey<String>(
                                          'specificDates'),
                                      dates: _specificDates,
                                      onChanged: (dates) =>
                                          setState(() => _specificDates = dates),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey<String>('daily')),
                        ),
                      ],
                    ),
                  ),
                  ScheduleSection(
                    title: 'HORÁRIOS',
                    child: TimeSelector(
                      times: _times,
                      onChanged: (times) => setState(() => _times = times),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(IaculaSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.primaryButton
                          .withValues(alpha: 0.05),
                      borderRadius:
                          BorderRadius.circular(IaculaRadius.card),
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
                          style: context.textStyles.cardTitle
                              .copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (widget.existing != null) ...[
                    const SizedBox(height: 24),
                    CupertinoButton(
                      onPressed: _delete,
                      child: const Text(
                        'Remover Alarme',
                        style: TextStyle(
                            color: CupertinoColors.destructiveRed),
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
