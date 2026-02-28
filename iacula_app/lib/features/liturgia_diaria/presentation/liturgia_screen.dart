import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_calendar_modal.dart';
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
      backgroundColor: context.colors.background,
      child: SafeArea(
        child: asyncDays.when(
          data: (days) {
            if (days.isEmpty) {
              return Center(
                child: Text(
                  'A liturgia não está disponível agora.',
                  style: context.textStyles.secondary,
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
                        child: Text(
                          'Calendário',
                          style: TextStyle(
                            color: context.colors.primaryButton,
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
                                  : context.colors.background,
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
                                    ? context.colors.textPrimary
                                    : context.colors.textSecondary,
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
                  Text(selected.title, style: context.textStyles.sectionTitle),
                  const SizedBox(height: IaculaSpacing.sm),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom +
                            IaculaSpacing.md,
                      ),
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
              style: context.textStyles.secondary,
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
      builder: (context) => IaculaCalendarModal(initialDate: selectedDate),
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
            if (day.prayers.collect.isNotEmpty)
              _LabeledBlock(label: 'Coleta', text: day.prayers.collect),
            if (day.prayers.offering.isNotEmpty)
              _LabeledBlock(label: 'Oferendas', text: day.prayers.offering),
            if (day.prayers.communion.isNotEmpty)
              _LabeledBlock(label: 'Comunhão', text: day.prayers.communion),
            for (final extra in day.prayers.extra)
              if (extra.isNotEmpty) _LabeledBlock(label: 'Extra', text: extra),
          ],
        );
      case _LiturgySegment.readings:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IaculaSectionHeader(title: 'Leituras'),
            const SizedBox(height: IaculaSpacing.sm),
            if (day.readings.isEmpty)
              _LabeledBlock(
                label: 'Leituras',
                text: 'Não há leituras disponíveis.',
              )
            else
              for (final reading in day.readings) ...[
                Text(reading.title, style: context.textStyles.cardTitle),
                if (reading.reference.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    reading.reference,
                    style: context.textStyles.secondary.copyWith(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  reading.text,
                  style: context.textStyles.secondary.copyWith(
                    color: context.colors.textPrimary,
                    height: 1.55,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.start,
                ),
                if (reading.response != null &&
                    reading.response!.isNotEmpty) ...[
                  const SizedBox(height: IaculaSpacing.sm),
                  _ResponseBlock(
                    label: reading.kind == LiturgyReadingKind.psalm
                        ? 'Refrão'
                        : 'Resposta',
                    text: reading.response!,
                  ),
                ],
                const SizedBox(height: IaculaSpacing.md),
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
              const _LabeledBlock(
                label: 'Antífonas',
                text: 'Não há antífonas disponíveis.',
              )
            else ...[
              if (day.antiphons.entry != null && day.antiphons.entry!.isNotEmpty)
                _LabeledBlock(
                    label: 'Entrada', text: day.antiphons.entry!),
              if (day.antiphons.communion != null &&
                  day.antiphons.communion!.isNotEmpty)
                _LabeledBlock(
                    label: 'Comunhão', text: day.antiphons.communion!),
              for (final extra in day.antiphons.extra)
                if (extra.isNotEmpty)
                  _LabeledBlock(label: 'Extra', text: extra),
            ],
          ],
        );
    }
  }
}

class _LabeledBlock extends StatelessWidget {
  const _LabeledBlock({required this.label, required this.text});

  final String label;
  final String text;

  static TextStyle _labelStyle(BuildContext context) {
    return context.textStyles.cardTitle.copyWith(
      fontSize: 13,
      color: context.colors.textSecondary,
    );
  }

  static TextStyle _bodyStyle(BuildContext context) {
    return context.textStyles.secondary.copyWith(
      color: context.colors.textPrimary,
      height: 1.55,
      fontSize: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle(context)),
          const SizedBox(height: 4),
          Text(
            text,
            style: _bodyStyle(context),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}

class _ResponseBlock extends StatelessWidget {
  const _ResponseBlock({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textStyles.cardTitle.copyWith(
              fontSize: 13,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: context.textStyles.secondary.copyWith(
              color: context.colors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.45,
              fontSize: 15,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}

