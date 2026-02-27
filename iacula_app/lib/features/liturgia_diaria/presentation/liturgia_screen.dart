import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/daily_liturgy.dart';

final _liturgyPeriodProvider =
    FutureProvider.family<List<LiturgyDay>, DateTime>((ref, anchorDate) {
      return ref
          .watch(getLiturgyPeriodUseCaseProvider)
          .call(days: 7, anchorDate: anchorDate);
    });

enum _LiturgySegment { prayers, readings, antiphons }

class LiturgiaScreen extends ConsumerStatefulWidget {
  const LiturgiaScreen({super.key});

  static const routeName = '/liturgia-diaria';

  @override
  ConsumerState<LiturgiaScreen> createState() => _LiturgiaScreenState();
}

class _LiturgiaScreenState extends ConsumerState<LiturgiaScreen> {
  late DateTime _selectedDate;
  late DateTime _anchorDate;
  _LiturgySegment _segment = _LiturgySegment.prayers;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = DateTime(today.year, today.month, today.day);
    _anchorDate = _selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final asyncDays = ref.watch(_liturgyPeriodProvider(_anchorDate));

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: asyncDays.when(
          data: (days) {
            if (days.isEmpty) {
              return const Center(
                child: Text(
                  'A liturgia não está disponível agora.',
                  style: IaculaText.secondary,
                ),
              );
            }

            final selectedIndex = _indexForDate(days, _selectedDate);
            final effectiveIndex = selectedIndex >= 0 ? selectedIndex : 0;
            final selected = days[effectiveIndex];
            if (selectedIndex < 0) {
              _selectedDate = selected.date;
            }
            final accent = _accentColor(selected.color);

            return Padding(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const IaculaLargeTitle('Liturgia'),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          final picked = await _showCalendarSheet(
                            context,
                            _selectedDate,
                          );
                          if (picked == null) return;
                          if (!mounted) return;
                          _selectDateFromCalendar(picked, days);
                        },
                        child: const Text(
                          'Calendário',
                          style: TextStyle(
                            color: IaculaColors.primaryButton,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: IaculaSpacing.md),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final selectedDay = _sameDate(day.date, _selectedDate);
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDate = day.date),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: selectedDay
                                  ? accent.withValues(alpha: 0.18)
                                  : CupertinoColors.white,
                              border: Border.all(
                                color: selectedDay
                                    ? accent
                                    : const Color(0x26000000),
                              ),
                            ),
                            child: Text(
                              _dayLabel(day.date),
                              style: TextStyle(
                                color: selectedDay
                                    ? IaculaColors.textPrimary
                                    : IaculaColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: IaculaSpacing.sm),
                      itemCount: days.length,
                    ),
                  ),
                  const SizedBox(height: IaculaSpacing.md),
                  CupertinoSlidingSegmentedControl<_LiturgySegment>(
                    groupValue: _segment,
                    children: const {
                      _LiturgySegment.prayers: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text('Orações'),
                      ),
                      _LiturgySegment.readings: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text('Leituras'),
                      ),
                      _LiturgySegment.antiphons: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text('Antífonas'),
                      ),
                    },
                    onValueChanged: (segment) {
                      if (segment != null) {
                        setState(() => _segment = segment);
                      }
                    },
                  ),
                  const SizedBox(height: IaculaSpacing.md),
                  Text(selected.title, style: IaculaText.sectionTitle),
                  const SizedBox(height: IaculaSpacing.sm),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: IaculaSoftCard(
                        child: _SegmentedContent(
                          day: selected,
                          segment: _segment,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          error: (error, _) => Center(
            child: Text(
              'Não foi possível carregar a liturgia: $error',
              style: IaculaText.secondary,
            ),
          ),
          loading: () => const Center(child: CupertinoActivityIndicator()),
        ),
      ),
    );
  }

  Future<DateTime?> _showCalendarSheet(
    BuildContext context,
    DateTime selectedDate,
  ) {
    return IaculaModal.showSheet<DateTime>(
      context: context,
      builder: (context) => _CalendarModal(initialDate: selectedDate),
    );
  }

  void _selectDateFromCalendar(DateTime date, List<LiturgyDay> loadedDays) {
    final normalized = DateTime(date.year, date.month, date.day);
    final hasDateInWindow = loadedDays.any(
      (day) => _sameDate(day.date, normalized),
    );

    setState(() {
      _selectedDate = normalized;
      if (!hasDateInWindow) {
        _anchorDate = normalized;
      }
    });
  }

  int _indexForDate(List<LiturgyDay> days, DateTime date) {
    for (var i = 0; i < days.length; i++) {
      if (_sameDate(days[i].date, date)) return i;
    }
    return -1;
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _accentColor(LiturgyColor color) {
    switch (color) {
      case LiturgyColor.red:
        return const Color(0xFFD94D4D);
      case LiturgyColor.purple:
        return const Color(0xFF7A55A3);
      case LiturgyColor.pink:
        return const Color(0xFFC65B86);
      case LiturgyColor.white:
        return const Color(0xFFC29A32);
      case LiturgyColor.green:
        return const Color(0xFF3C8D53);
    }
  }

  String _dayLabel(DateTime date) {
    final weekdays = <String>['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final weekday = weekdays[(date.weekday - 1).clamp(0, 6)];
    return '$weekday ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

class _SegmentedContent extends StatelessWidget {
  const _SegmentedContent({required this.day, required this.segment});

  final LiturgyDay day;
  final _LiturgySegment segment;

  @override
  Widget build(BuildContext context) {
    switch (segment) {
      case _LiturgySegment.prayers:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IaculaSectionHeader(title: 'Orações'),
            const SizedBox(height: IaculaSpacing.sm),
            _Line(label: 'Coleta', text: day.prayers.collect),
            _Line(label: 'Oferendas', text: day.prayers.offering),
            _Line(label: 'Comunhão', text: day.prayers.communion),
            for (final extra in day.prayers.extra)
              _Line(label: 'Extra', text: extra),
          ],
        );
      case _LiturgySegment.readings:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IaculaSectionHeader(title: 'Leituras'),
            const SizedBox(height: IaculaSpacing.sm),
            if (day.readings.isEmpty)
              const _Line(
                label: 'Leituras',
                text: 'Não há leituras disponíveis.',
              )
            else
              for (final reading in day.readings) ...[
                Text(reading.title, style: IaculaText.cardTitle),
                const SizedBox(height: 4),
                _Line(
                  label: reading.reference.isEmpty
                      ? 'Texto'
                      : reading.reference,
                  text: reading.text,
                ),
                if (reading.response?.isNotEmpty == true)
                  _Line(label: 'Resposta', text: reading.response!),
                const SizedBox(height: IaculaSpacing.sm),
              ],
          ],
        );
      case _LiturgySegment.antiphons:
        final hasAntiphons =
            day.antiphons.entry != null ||
            day.antiphons.communion != null ||
            day.antiphons.extra.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IaculaSectionHeader(title: 'Antífonas'),
            const SizedBox(height: IaculaSpacing.sm),
            if (!hasAntiphons)
              const _Line(
                label: 'Antífonas',
                text: 'Não há antífonas disponíveis.',
              )
            else ...[
              if (day.antiphons.entry != null)
                _Line(label: 'Entrada', text: day.antiphons.entry!),
              if (day.antiphons.communion != null)
                _Line(label: 'Comunhão', text: day.antiphons.communion!),
              for (final extra in day.antiphons.extra)
                _Line(label: 'Extra', text: extra),
            ],
          ],
        );
    }
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $text',
        style: IaculaText.secondary.copyWith(color: IaculaColors.textPrimary),
      ),
    );
  }
}

class _CalendarModal extends StatefulWidget {
  const _CalendarModal({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_CalendarModal> createState() => _CalendarModalState();
}

class _CalendarModalState extends State<_CalendarModal> {
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
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
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

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 460,
        padding: const EdgeInsets.all(IaculaSpacing.md),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      onTap: () => setState(() => _selectedDate = cellDate),
                      child: Center(
                        child: Container(
                          key: ValueKey<String>('calendar-day-$dayNumber'),
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
                onPressed: () => Navigator.of(context).pop(_selectedDate),
                child: const Text('Aplicar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
