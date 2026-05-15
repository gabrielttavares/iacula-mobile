import 'package:flutter/cupertino.dart';

import '../../../../core/presentation/design/iacula_modal.dart';
import '../../../../core/presentation/widgets/iacula_calendar_modal.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class ScheduleSection extends StatelessWidget {
  const ScheduleSection({super.key, required this.title, required this.child});
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

class DaySelector extends StatelessWidget {
  const DaySelector({super.key, required this.selected, required this.onChanged});
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

class DateSelector extends StatelessWidget {
  const DateSelector({super.key, required this.dates, required this.onChanged});
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
          children: dates.map((date) => ScheduleChip(
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

class TimeSelector extends StatelessWidget {
  const TimeSelector({super.key, required this.times, required this.onChanged});
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
          children: times.map((time) => ScheduleChip(
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

class ScheduleChip extends StatelessWidget {
  const ScheduleChip({super.key, required this.label, required this.onDelete});
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
