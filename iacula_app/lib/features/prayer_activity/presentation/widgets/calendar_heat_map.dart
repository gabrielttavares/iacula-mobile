import 'package:flutter/cupertino.dart';

import '../../../../core/theme/cupertino_tokens.dart';

class CalendarHeatMap extends StatelessWidget {
  const CalendarHeatMap({
    super.key,
    required this.activityByDate,
    this.goalMinutes = 10,
  });

  final Map<String, int> activityByDate;
  final int goalMinutes;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday; // 1=Mon, 7=Sun

    final weekdayLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month name
        Text(
          _monthName(now.month),
          style: context.textStyles.cardTitle,
        ),
        const SizedBox(height: 12),
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdayLabels
              .map(
                (l) => SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      l,
                      style: context.textStyles.secondary.copyWith(fontSize: 11),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        ...List.generate(_weekCount(startWeekday, daysInMonth), (week) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (weekday) {
                final day = week * 7 + weekday + 1 - (startWeekday - 1);
                if (day < 1 || day > daysInMonth) {
                  return const SizedBox(width: 32, height: 32);
                }
                final dateStr =
                    '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                final minutes = activityByDate[dateStr] ?? 0;
                final isToday = day == now.day;
                final intensity = minutes == 0
                    ? 0.0
                    : (minutes / goalMinutes).clamp(0.0, 1.0);

                return _DayCell(
                  day: day,
                  intensity: intensity,
                  isToday: isToday,
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  int _weekCount(int startWeekday, int daysInMonth) {
    return ((startWeekday - 1 + daysInMonth) / 7).ceil();
  }

  String _monthName(int month) {
    const names = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    return names[month - 1];
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.intensity,
    required this.isToday,
  });

  final int day;
  final double intensity;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = intensity == 0
        ? colors.systemGray6
        : Color.lerp(
            colors.primaryButton.withValues(alpha: 0.2),
            colors.primaryButton,
            intensity,
          )!;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: isToday
            ? Border.all(color: colors.primaryButton, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            color: intensity > 0.5 ? CupertinoColors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
