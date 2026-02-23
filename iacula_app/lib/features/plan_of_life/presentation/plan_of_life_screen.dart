import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/entities/plan_item.dart';
import '../domain/entities/plan_item_schedule.dart';
import '../application/plan_of_life_notifier.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
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
        // Approximate center for index 3 with item width ~64
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Plano de Vida', style: theme.textTheme.titleMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showEditItemModal(context, null),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                notifier.selectDate(date);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDateStrip(state.selectedDate, notifier, colorScheme, theme),
            Expanded(
              child: state.isLoading && state.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.items.isEmpty
                      ? const Center(child: Text('Nenhum item para este dia.'))
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 80.0, top: 8.0),
                          children: [
                            if (morningItems.isNotEmpty)
                              _buildSection('Manhã', Icons.wb_sunny_outlined, morningItems, notifier, theme),
                            if (afternoonItems.isNotEmpty)
                              _buildSection('Tarde', Icons.cloud_outlined, afternoonItems, notifier, theme),
                            if (nightItems.isNotEmpty)
                              _buildSection('Noite', Icons.nights_stay_outlined, nightItems, notifier, theme),
                            if (unscheduledItems.isNotEmpty)
                              _buildSection('Outros', Icons.checklist, unscheduledItems, notifier, theme),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateStrip(DateTime selectedDate, PlanOfLifeNotifier notifier, ColorScheme colorScheme, ThemeData theme) {
    final dates = List.generate(7, (i) => selectedDate.add(Duration(days: i - 3)));

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isActive = index == 3;
          final dayName = const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][date.weekday - 1];

          return GestureDetector(
            onTap: () => notifier.selectDate(date),
            child: Container(
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: isActive ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? colorScheme.onPrimary : theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
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

  Widget _buildSection(String title, IconData icon, List<PlanItem> items, PlanOfLifeNotifier notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 24.0, bottom: 8.0, right: 20.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) {
          return Dismissible(
            key: Key(item.id),
            direction: item.schedule.isDefault ? DismissDirection.none : DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              notifier.deleteItem(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item removido')),
              );
            },
            child: InkWell(
              onLongPress: () => _showEditItemModal(context, item),
              child: PlanItemRow(
                title: item.title,
                isCompleted: item.isCompleted,
                onToggle: (bool newValue) => notifier.toggleItem(item.id, newValue),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showEditItemModal(BuildContext context, PlanItem? item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _EditItemForm(item: item),
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
  late List<bool> _days;
  TimeOfDay? _time;
  bool _notify = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    
    _days = List.generate(7, (i) {
      if (widget.item == null || widget.item!.schedule.daysOfWeek.isEmpty) return true;
      return widget.item!.schedule.daysOfWeek.contains(i + 1);
    });

    if (widget.item?.schedule.time != null) {
      final parts = widget.item!.schedule.time!.split(':');
      if (parts.length == 2) {
        _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    _notify = widget.item?.schedule.notify ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(planOfLifeNotifierProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.item == null ? 'Novo Item' : 'Editar Item',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Horário'),
            subtitle: Text(_time?.format(context) ?? 'Nenhum horário definido'),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final selected = await showTimePicker(
                context: context,
                initialTime: _time ?? TimeOfDay.now(),
              );
              if (selected != null) {
                setState(() => _time = selected);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Lembrete (Notificação)'),
            value: _notify,
            onChanged: (v) => setState(() => _notify = v),
          ),
          const SizedBox(height: 8),
          const Text('Dias da semana:'),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final dayName = const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'][index];
              return FilterChip(
                label: Text(dayName),
                selected: _days[index],
                onSelected: (v) => setState(() => _days[index] = v),
              );
            }),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty) return;

              final selectedDays = <int>[];
              for (int i = 0; i < 7; i++) {
                if (_days[i]) selectedDays.add(i + 1);
              }
              if (selectedDays.length == 7) selectedDays.clear();

              final timeStr = _time != null 
                ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
                : null;

              final schedule = PlanItemSchedule(
                time: timeStr,
                daysOfWeek: selectedDays,
                notify: _notify,
                isDefault: widget.item?.schedule.isDefault ?? false,
              );

              if (widget.item == null) {
                notifier.addItem(_titleController.text.trim(), schedule);
              } else {
                notifier.updateItem(widget.item!.id, _titleController.text.trim(), schedule);
              }

              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
