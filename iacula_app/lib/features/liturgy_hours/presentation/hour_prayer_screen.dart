import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_modal.dart';
import '../../../core/presentation/widgets/iacula_progress_bar.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/biblical_reading_text.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayer_activity/domain/entities/prayer_activity_entry.dart';
import '../domain/entities/liturgical_hour.dart';

class HourPrayerScreen extends ConsumerStatefulWidget {
  const HourPrayerScreen({super.key, required this.hour});

  final LiturgicalHour hour;

  @override
  ConsumerState<HourPrayerScreen> createState() => _HourPrayerScreenState();
}

class _HourPrayerScreenState extends ConsumerState<HourPrayerScreen> {
  int _currentSection = 0;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  int get _totalSections => widget.hour.sections.length;
  HourSection get _current => widget.hour.sections[_currentSection];

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentSection < _totalSections - 1) {
      setState(() => _currentSection++);
    } else {
      _complete();
    }
  }

  void _previous() {
    if (_currentSection > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentSection--);
    }
  }

  void _complete() {
    final elapsed = DateTime.now().difference(_startedAt).inSeconds;
    ref.read(prayerActivityLoggerProvider).logActivity(
          type: PrayerActivityType.liturgyOfHours,
          durationSeconds: elapsed,
          featureSlug: 'liturgy_${widget.hour.type.name}',
        );

    IaculaModal.showAlert(
      context: context,
      title: '${widget.hour.type.label} concluída',
      message: 'Tempo: ${(elapsed / 60).ceil()} minutos.',
      actionLabel: 'Fechar',
    ).then((_) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text(
          widget.hour.type.label,
          style: context.textStyles.cardTitle,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _current.title,
                    style: context.textStyles.secondary.copyWith(fontSize: 13),
                  ),
                  Text(
                    '${_currentSection + 1}/$_totalSections',
                    style: context.textStyles.secondary.copyWith(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: IaculaProgressBar(
                  value: (_currentSection + 1) / _totalSections,
                  backgroundColor: context.colors.systemGray6,
                  color: context.colors.primaryButton,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: IaculaSpacing.lg),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: IaculaSoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _current.title,
                          style: context.textStyles.sectionTitle,
                        ),
                        if (_current.reference != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _current.reference!,
                            style: context.textStyles.secondary.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (_current.antiphon != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.colors.primaryButton
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ant. ',
                                  style: context.textStyles.secondary.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: context.colors.primaryButton,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _current.antiphon!,
                                    style:
                                        context.textStyles.secondary.copyWith(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        BiblicalReadingText(
                          text: _current.content,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: IaculaSpacing.md),

              // Navigation
              Row(
                children: [
                  if (_currentSection > 0) ...[
                    Expanded(
                      child: CupertinoButton(
                        color: context.colors.secondaryButton,
                        borderRadius: BorderRadius.circular(24),
                        onPressed: _previous,
                        child: Text(
                          'Anterior',
                          style: TextStyle(color: context.colors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: CupertinoButton(
                      color: context.colors.primaryButton,
                      borderRadius: BorderRadius.circular(24),
                      onPressed: _next,
                      child: Text(
                        _currentSection < _totalSections - 1
                            ? 'Continuar'
                            : 'Concluir',
                        style: const TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
