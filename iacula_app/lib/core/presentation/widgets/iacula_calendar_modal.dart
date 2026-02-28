import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaCalendarModal extends StatefulWidget {
  const IaculaCalendarModal({super.key, required this.initialDate});

  final DateTime initialDate;

  @override
  State<IaculaCalendarModal> createState() => _IaculaCalendarModalState();
}

class _IaculaCalendarModalState extends State<IaculaCalendarModal> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _visibleMonth =
        DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );
    final leadingBlanks = firstDayOfMonth.weekday - 1;
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final totalCells = ((leadingBlanks + daysInMonth + 6) ~/ 7) * 7;

    return SizedBox(
      height: 460,
      child: Padding(
        padding: const EdgeInsets.all(IaculaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Escolha a data',
              style: IaculaText.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: IaculaSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _visibleMonth = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month - 1,
                      );
                    });
                  },
                  child: const Icon(CupertinoIcons.chevron_left),
                ),
                Text(
                  '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                  style: IaculaText.cardTitle,
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _visibleMonth = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month + 1,
                      );
                    });
                  },
                  child: const Icon(CupertinoIcons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: IaculaSpacing.sm),
            const Row(
              children: [
                _WeekdayHeader('S'),
                _WeekdayHeader('T'),
                _WeekdayHeader('Q'),
                _WeekdayHeader('Q'),
                _WeekdayHeader('S'),
                _WeekdayHeader('S'),
                _WeekdayHeader('D'),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCells,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final dayNumber = index - leadingBlanks + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }
                  final cellDate = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month,
                    dayNumber,
                  );
                  final isSelected = _sameDate(cellDate, _selectedDate);

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDate = cellDate),
                    child: Center(
                      child: Container(
                        key: ValueKey<String>(
                            'calendar-day-$dayNumber'),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? IaculaColors.primaryButton
                              : CupertinoColors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: isSelected
                                ? CupertinoColors.white
                                : IaculaColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            CupertinoButton.filled(
              borderRadius: BorderRadius.circular(26),
              onPressed: () =>
                  Navigator.of(context).pop(_selectedDate),
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _monthName(int month) {
    const names = <String>[
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return names[(month - 1).clamp(0, 11)];
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: IaculaText.secondary,
      ),
    );
  }
}
