import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/entities/daily_liturgy.dart';

final _liturgyPeriodProvider = FutureProvider<List<LiturgyDay>>((ref) {
  return ref.watch(getLiturgyPeriodUseCaseProvider).call(days: 7);
});

class LiturgiaScreen extends ConsumerStatefulWidget {
  const LiturgiaScreen({super.key});

  static const routeName = '/liturgia-diaria';

  @override
  ConsumerState<LiturgiaScreen> createState() => _LiturgiaScreenState();
}

class _LiturgiaScreenState extends ConsumerState<LiturgiaScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final asyncDays = ref.watch(_liturgyPeriodProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Liturgia Diária')),
      body: asyncDays.when(
        data: (days) {
          if (days.isEmpty) {
            return const Center(
              child: Text('Liturgia indisponível no momento.'),
            );
          }

          if (_selectedIndex >= days.length) {
            _selectedIndex = 0;
          }
          final selected = days[_selectedIndex];
          final accent = _accentColor(selected.color);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final selectedChip = index == _selectedIndex;
                    return ChoiceChip(
                      label: Text(_dayLabel(day.date)),
                      selected: selectedChip,
                      selectedColor: accent.withValues(alpha: 0.22),
                      side: BorderSide(
                        color: selectedChip
                            ? accent
                            : colorScheme.outline.withValues(alpha: 0.24),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  children: [
                    Text(
                      selected.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(height: 3, color: accent),
                    const SizedBox(height: 16),
                    _SectionHeader(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'Orações',
                      accent: accent,
                    ),
                    _PrayerBlock(day: selected),
                    const SizedBox(height: 16),
                    _SectionHeader(
                      icon: Icons.menu_book_outlined,
                      title: 'Leituras',
                      accent: accent,
                    ),
                    _ReadingsBlock(day: selected, accent: accent),
                    const SizedBox(height: 16),
                    _SectionHeader(
                      icon: Icons.auto_awesome,
                      title: 'Antífonas',
                      accent: accent,
                    ),
                    _AntiphonsBlock(day: selected),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, _) => Center(
          child: Text(
            'Erro ao carregar liturgia: $error',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Color _accentColor(LiturgyColor color) {
    switch (color) {
      case LiturgyColor.red:
        return Colors.red;
      case LiturgyColor.purple:
        return Colors.purple;
      case LiturgyColor.pink:
        return Colors.pink;
      case LiturgyColor.white:
        return Colors.amber;
      case LiturgyColor.green:
        return Colors.green;
    }
  }

  String _dayLabel(DateTime date) {
    final weekdays = <String>['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final weekday = weekdays[(date.weekday - 1).clamp(0, 6)];
    return '$weekday ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PrayerBlock extends StatelessWidget {
  const _PrayerBlock({required this.day});

  final LiturgyDay day;

  @override
  Widget build(BuildContext context) {
    final extras = day.prayers.extra;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Line(label: 'Coleta', text: day.prayers.collect),
          _Line(label: 'Oferendas', text: day.prayers.offering),
          _Line(label: 'Comunhão', text: day.prayers.communion),
          for (final extra in extras) _Line(label: 'Extra', text: extra),
        ],
      ),
    );
  }
}

class _ReadingsBlock extends StatelessWidget {
  const _ReadingsBlock({required this.day, required this.accent});

  final LiturgyDay day;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (day.readings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: _Line(label: 'Leituras', text: 'Sem leituras disponíveis.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final reading in day.readings) ...[
            Text(
              reading.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            _Line(
              label: reading.reference.isEmpty ? 'Texto' : reading.reference,
              text: reading.text,
            ),
            if (reading.response != null && reading.response!.isNotEmpty)
              _Line(label: 'Resposta', text: reading.response!),
            const SizedBox(height: 8),
            Divider(color: accent.withValues(alpha: 0.35)),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _AntiphonsBlock extends StatelessWidget {
  const _AntiphonsBlock({required this.day});

  final LiturgyDay day;

  @override
  Widget build(BuildContext context) {
    final lines = <_Line>[
      if (day.antiphons.entry != null)
        _Line(label: 'Entrada', text: day.antiphons.entry!),
      if (day.antiphons.communion != null)
        _Line(label: 'Comunhão', text: day.antiphons.communion!),
      for (final extra in day.antiphons.extra)
        _Line(label: 'Extra', text: extra),
    ];

    if (lines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: _Line(label: 'Antífonas', text: 'Sem antífonas disponíveis.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines,
      ),
    );
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
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
