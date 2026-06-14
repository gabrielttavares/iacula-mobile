import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../features/settings/domain/jaculatoria_cadence_preset.dart';
import '../../theme/cupertino_tokens.dart';

/// Honest, platform-specific explanation of what happens to a short cadence
/// (see [JaculatoriaCadencePreset.isClosedAppCapConstrained]) while the app
/// stays closed. iOS holds a hard cap on pending notifications, so the tight
/// spacing only fully applies while the app is in use; closed, the day receives
/// a reduced number spread out. Android keeps delivering at the chosen cadence
/// for a few days, then at half cadence until reopened. Shared by Settings and
/// Onboarding so both surfaces tell the user the same thing.
String closedAppCadenceNotePtBr() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'Você recebe nessa frequência mesmo com o app fechado por alguns '
        'dias; depois disso, a frequência diminui pela metade até você abrir '
        'o app de novo.';
  }
  return 'No iPhone, essa frequência vale enquanto você usa o app. Com ele '
      'fechado, você recebe algumas jaculatórias por dia, espalhadas ao '
      'longo do dia.';
}

/// Ordered list of cadence chips, gentlest → tightest — one chip per preset.
///
/// Each chip IS a [JaculatoriaCadencePreset]; its label is that preset's real
/// delivered cadence ([JaculatoriaCadencePreset.todayCadenceMinutes]). There is
/// deliberately no "3h" chip: the gentlest preset (`suave`) delivers every 2h,
/// so advertising 3h would be a cadence the scheduler never produces. Driving
/// chips off the enum (instead of arbitrary minute values run back through
/// `fromIntervalMinutes`) guarantees each chip selects exactly itself with no
/// two chips collapsing into the same bucket.
final List<JaculatoriaCadencePreset> _orderedChips = [
  JaculatoriaCadencePreset.suave, // a cada 3h
  JaculatoriaCadencePreset.moderado, // a cada 2h
  JaculatoriaCadencePreset.regular, // a cada 1h30
  JaculatoriaCadencePreset.frequente, // a cada hora
  JaculatoriaCadencePreset.maisFrequente, // a cada 30min
  JaculatoriaCadencePreset.intenso, // a cada 15min
  JaculatoriaCadencePreset.muitoIntenso, // a cada 10min
];

/// Short chip label for a preset, e.g. "2h", "1h30", "30min". Built from the
/// preset's real delivered cadence. Deliberately renders a whole-hour cadence
/// as "2h" (not "2h00" like the badge formatter) so the chip stays compact.
String _chipLabel(JaculatoriaCadencePreset preset) {
  final cadenceMinutes = preset.todayCadenceMinutes;
  if (cadenceMinutes < 60) return '${cadenceMinutes}min';
  final hours = cadenceMinutes ~/ 60;
  final minutes = cadenceMinutes % 60;
  return minutes == 0
      ? '${hours}h'
      : '${hours}h${minutes.toString().padLeft(2, '0')}';
}

/// A horizontal, scrollable row of minute chips for selecting jaculatória
/// notification cadence. One chip per distinct preset (3h / 2h / 1h30 / 1h /
/// 30min / 15min / 10min), ordered gentlest → tightest.
///
/// Visual language mirrors [_IntervalButton] in `interval_selector.dart`:
/// animated container, selected highlight uses primaryButton background with
/// background-colored text, haptic feedback on tap.
class CadenceChipSelector extends StatelessWidget {
  const CadenceChipSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final JaculatoriaCadencePreset selected;
  final ValueChanged<JaculatoriaCadencePreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _orderedChips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chipPreset = _orderedChips[index];
          final isSelected = chipPreset == selected;
          return _CadenceChip(
            label: _chipLabel(chipPreset),
            isSelected: isSelected,
            onPressed: () {
              HapticFeedback.selectionClick();
              onChanged(chipPreset);
            },
          );
        },
      ),
    );
  }
}

class _CadenceChip extends StatelessWidget {
  const _CadenceChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryButton
              : context.colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? context.colors.primaryButton
                : context.colors.separator,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? context.colors.background
                : context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
