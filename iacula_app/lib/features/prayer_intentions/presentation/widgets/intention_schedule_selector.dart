import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/design/iacula_modal.dart';
import '../../../../core/presentation/widgets/iacula_calendar_modal.dart';
import '../../domain/entities/intention_schedule.dart';

class IntentionScheduleSelector extends StatefulWidget {
  const IntentionScheduleSelector({
    super.key,
    required this.schedule,
    required this.onChanged,
  });

  final IntentionSchedule schedule;
  final ValueChanged<IntentionSchedule> onChanged;

  @override
  State<IntentionScheduleSelector> createState() =>
      _IntentionScheduleSelectorState();
}

class _IntentionScheduleSelectorState extends State<IntentionScheduleSelector> {
  late IntentionScheduleType _scheduleType;
  late List<int> _daysOfWeek;
  late List<String> _specificDates;
  late List<String> _times;

  @override
  void initState() {
    super.initState();
    _scheduleType = widget.schedule.type;
    _daysOfWeek = List.from(widget.schedule.daysOfWeek);
    _specificDates = List.from(widget.schedule.specificDates);
    _times = List.from(widget.schedule.times);
  }

  void _updateSchedule() {
    widget.onChanged(
      IntentionSchedule(
        type: _scheduleType,
        daysOfWeek: _daysOfWeek,
        specificDates: _specificDates,
        times: _times,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Section(
          title: 'FREQUÊNCIA',
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<IntentionScheduleType>(
                  groupValue: _scheduleType,
                  children: const {
                    IntentionScheduleType.daily:
                        Text('Diário', style: TextStyle(fontSize: 13)),
                    IntentionScheduleType.weekly:
                        Text('Semanal', style: TextStyle(fontSize: 13)),
                    IntentionScheduleType.specificDates:
                        Text('Datas', style: TextStyle(fontSize: 13)),
                  },
                  onValueChanged: (v) {
                    if (v != null) {
                      setState(() => _scheduleType = v);
                      _updateSchedule();
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _scheduleType == IntentionScheduleType.weekly
                    ? _DaySelector(
                        key: const ValueKey<String>('weekly'),
                        selected: _daysOfWeek,
                        onChanged: (days) {
                          setState(() => _daysOfWeek = days);
                          _updateSchedule();
                        },
                      )
                    : _scheduleType == IntentionScheduleType.specificDates
                        ? _DateSelector(
                            key: const ValueKey<String>('specificDates'),
                            dates: _specificDates,
                            onChanged: (dates) {
                              setState(() => _specificDates = dates);
                              _updateSchedule();
                            },
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
            onChanged: (times) {
              setState(() => _times = times);
              _updateSchedule();
            },
          ),
        ),
      ],
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
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
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

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final days = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
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
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Text(
              days[index],
              style: TextStyle(
                color: isSelected
                    ? CupertinoColors.white
                    : CupertinoColors.label,
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
  const _DateSelector({
    super.key,
    required this.dates,
    required this.onChanged,
  });
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
          children: dates
              .map(
                (date) => _Chip(
                  label: _formatDate(date),
                  onDelete: () {
                    final next = List<String>.from(dates)..remove(date);
                    onChanged(next);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showPicker(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.add_circled, size: 20),
              SizedBox(width: 6),
              Text('Adicionar data', style: TextStyle(fontSize: 14)),
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.time, size: 20),
              SizedBox(width: 6),
              Text('Adicionar horário', style: TextStyle(fontSize: 14)),
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
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(CupertinoIcons.xmark_circle_fill, size: 16),
          ),
        ],
      ),
    );
  }
}
