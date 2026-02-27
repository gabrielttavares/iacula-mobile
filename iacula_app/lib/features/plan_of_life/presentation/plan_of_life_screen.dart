import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_input.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_calendar_modal.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../application/plan_of_life_notifier.dart';
import '../domain/entities/plan_item.dart';
import '../domain/entities/plan_item_schedule.dart';
import 'widgets/plan_item_row.dart';

class PlanOfLifeScreen extends ConsumerStatefulWidget {
  const PlanOfLifeScreen({super.key});

  @override
  ConsumerState<PlanOfLifeScreen> createState() => _PlanOfLifeScreenState();
}

class _PlanOfLifeScreenState extends ConsumerState<PlanOfLifeScreen> {
  final ScrollController _dateScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollController.hasClients) {
        _dateScrollController.jumpTo(100.0);
      }
    });
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      feature: PremiumFeature.planOfLife,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final state = ref.watch(planOfLifeNotifierProvider);
    final notifier = ref.read(planOfLifeNotifierProvider.notifier);

    final morningItems = <PlanItem>[];
    final afternoonItems = <PlanItem>[];
    final nightItems = <PlanItem>[];
    final unscheduledItems = <PlanItem>[];

    for (final item in state.items) {
      if (item.schedule.time != null) {
        final parts = item.schedule.time!.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          if (hour < 12) {
            morningItems.add(item);
          } else if (hour < 18) {
            afternoonItems.add(item);
          } else {
            nightItems.add(item);
          }
        } else {
          unscheduledItems.add(item);
        }
      } else {
        unscheduledItems.add(item);
      }
    }

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const IaculaLargeTitle('Plano de vida'),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _showEditItemModal(context, null),
                        child: const Icon(CupertinoIcons.add),
                      ),
                      const SizedBox(width: 10),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          final picked = await _showCalendarSheet(
                            context,
                            state.selectedDate,
                          );
                          if (picked != null) {
                            notifier.selectDate(picked);
                          }
                        },
                        child: const Icon(CupertinoIcons.calendar),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildDateStrip(state.selectedDate, notifier),
            Expanded(
              child: state.isLoading && state.items.isEmpty
                  ? const Center(child: CupertinoActivityIndicator())
                  : state.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Ainda não há itens para este dia.',
                        style: IaculaText.secondary,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 80.0, top: 8.0),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        if (morningItems.isNotEmpty)
                          _buildSection(
                            'Manhã',
                            CupertinoIcons.sun_max,
                            morningItems,
                            notifier,
                          ),
                        if (afternoonItems.isNotEmpty)
                          _buildSection(
                            'Tarde',
                            CupertinoIcons.cloud,
                            afternoonItems,
                            notifier,
                          ),
                        if (nightItems.isNotEmpty)
                          _buildSection(
                            'Noite',
                            CupertinoIcons.moon_stars,
                            nightItems,
                            notifier,
                          ),
                        if (unscheduledItems.isNotEmpty)
                          _buildSection(
                            'Outros',
                            CupertinoIcons.check_mark_circled,
                            unscheduledItems,
                            notifier,
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateStrip(DateTime selectedDate, PlanOfLifeNotifier notifier) {
    final dates = List.generate(
      7,
      (i) => selectedDate.add(Duration(days: i - 3)),
    );

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isActive = _sameDate(date, selectedDate);
          final dayName = const [
            'Seg',
            'Ter',
            'Qua',
            'Qui',
            'Sex',
            'Sáb',
            'Dom',
          ][date.weekday - 1];

          return GestureDetector(
            onTap: () => notifier.selectDate(date),
            child: Container(
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: isActive
                    ? IaculaColors.primaryButton
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? IaculaColors.primaryButton
                      : CupertinoColors.systemGrey4,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive
                          ? CupertinoColors.white
                          : IaculaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? CupertinoColors.white
                          : IaculaColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<PlanItem> items,
    PlanOfLifeNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            top: 24.0,
            bottom: 8.0,
            right: 20.0,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: IaculaColors.textSecondary),
              const SizedBox(width: 8),
              Text(title, style: IaculaText.cardTitle),
            ],
          ),
        ),
        ...items.map((item) {
          return Dismissible(
            key: Key(item.id),
            direction: item.schedule.isDefault
                ? DismissDirection.none
                : DismissDirection.endToStart,
            background: Container(
              color: CupertinoColors.destructiveRed,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                CupertinoIcons.delete,
                color: CupertinoColors.white,
              ),
            ),
            onDismissed: (_) => notifier.deleteItem(item.id),
            child: GestureDetector(
              onLongPress: () => _showEditItemModal(context, item),
              child: PlanItemRow(
                title: item.title,
                scheduleSummary: _scheduleSummary(item.schedule),
                isCompleted: item.isCompleted,
                onToggle: (bool newValue) =>
                    notifier.toggleItem(item.id, newValue),
                onEdit: () => _showEditItemModal(context, item),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _scheduleSummary(PlanItemSchedule schedule) {
    final time = schedule.time?.trim();
    if (time == null || time.isEmpty) {
      return 'Sem horário';
    }

    if (schedule.daysOfWeek.isEmpty) {
      return 'Todos os dias • $time';
    }

    const dayLabels = <int, String>{
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sáb',
      7: 'Dom',
    };
    final days = schedule.daysOfWeek
        .map((d) => dayLabels[d] ?? '')
        .where((d) => d.isNotEmpty)
        .join(', ');
    return '$days • $time';
  }

  void _showEditItemModal(BuildContext context, PlanItem? item) {
    IaculaModal.showSheet<void>(
      context: context,
      builder: (ctx) => _EditItemForm(item: item),
    );
  }

  Future<DateTime?> _showCalendarSheet(
    BuildContext context,
    DateTime initialDate,
  ) {
    return IaculaModal.showSheet<DateTime>(
      context: context,
      builder: (context) => IaculaCalendarModal(initialDate: initialDate),
    );
  }
}

class _EditItemForm extends ConsumerStatefulWidget {
  const _EditItemForm({this.item});

  final PlanItem? item;

  @override
  ConsumerState<_EditItemForm> createState() => _EditItemFormState();
}

class _EditItemFormState extends ConsumerState<_EditItemForm> {
  late TextEditingController _titleController;
  late TextEditingController _timeController;
  late List<bool> _days;
  bool _notify = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _timeController = TextEditingController(
      text: widget.item?.schedule.time ?? '',
    );

    _days = List.generate(7, (i) {
      if (widget.item == null || widget.item!.schedule.daysOfWeek.isEmpty)
        return true;
      return widget.item!.schedule.daysOfWeek.contains(i + 1);
    });

    _notify = widget.item?.schedule.notify ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(planOfLifeNotifierProvider.notifier);
    final isDefault = widget.item?.schedule.isDefault ?? false;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.item == null ? 'Novo Item' : 'Editar Item',
                  style: IaculaText.sectionTitle,
                ),
                const SizedBox(height: 16),
                if (!isDefault) ...[
                  IaculaTextInput(
                    controller: _titleController,
                    placeholder: 'Título',
                  ),
                  const SizedBox(height: 16),
                ],
                IaculaTimeInput(
                  controller: _timeController,
                  placeholder: 'Horário (HH:MM)',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lembrete (Notificação)',
                      style: IaculaText.secondary,
                    ),
                    CupertinoSwitch(
                      value: _notify,
                      onChanged: (v) => setState(() => _notify = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Dias da semana:', style: IaculaText.secondary),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final dayName = const [
                      'S',
                      'T',
                      'Q',
                      'Q',
                      'S',
                      'S',
                      'D',
                    ][index];
                    final selected = _days[index];
                    return GestureDetector(
                      onTap: () => setState(() => _days[index] = !selected),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? IaculaColors.primaryButton
                              : CupertinoColors.systemGrey5,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          dayName,
                          style: TextStyle(
                            color: selected
                                ? CupertinoColors.white
                                : IaculaColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                CupertinoButton.filled(
                  onPressed: () {
                    final title = isDefault
                        ? (widget.item?.title ?? '')
                        : _titleController.text.trim();
                    if (title.isEmpty) return;

                    final selectedDays = <int>[];
                    for (int i = 0; i < 7; i++) {
                      if (_days[i]) selectedDays.add(i + 1);
                    }
                    if (selectedDays.length == 7) selectedDays.clear();

                    final timeText = _timeController.text.trim();
                    final timeStr = _isValidTime(timeText) ? timeText : null;

                    final schedule = PlanItemSchedule(
                      time: timeStr,
                      daysOfWeek: selectedDays,
                      notify: _notify,
                      isDefault: widget.item?.schedule.isDefault ?? false,
                    );

                    if (widget.item == null) {
                      notifier.addItem(title, schedule);
                    } else {
                      notifier.updateItem(widget.item!.id, title, schedule);
                    }

                    Navigator.pop(context);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidTime(String value) {
    if (value.isEmpty) return false;
    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return regex.hasMatch(value);
  }
}
