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

/// Ordered list of cadence chips, gentlest → tightest.
///
/// Each entry pairs a display label with the representative [intervalMinutes]
/// that maps to a [JaculatoriaCadencePreset] via
/// [JaculatoriaCadencePreset.fromIntervalMinutes]. One chip per distinct preset
/// so no two chips collide to the same bucket.
const List<_CadenceChipDefinition> _orderedChips = [
  _CadenceChipDefinition(label: '3h', intervalMinutes: 180),
  _CadenceChipDefinition(label: '2h', intervalMinutes: 120),
  _CadenceChipDefinition(label: '1h30', intervalMinutes: 90),
  _CadenceChipDefinition(label: '1h', intervalMinutes: 60),
  _CadenceChipDefinition(label: '30min', intervalMinutes: 30),
  _CadenceChipDefinition(label: '15min', intervalMinutes: 15),
  _CadenceChipDefinition(label: '10min', intervalMinutes: 10),
];

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
          final chip = _orderedChips[index];
          final chipPreset =
              JaculatoriaCadencePreset.fromIntervalMinutes(chip.intervalMinutes);
          final isSelected = chipPreset == selected;
          return _CadenceChip(
            label: chip.label,
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

class _CadenceChipDefinition {
  const _CadenceChipDefinition({
    required this.label,
    required this.intervalMinutes,
  });

  final String label;
  final int intervalMinutes;
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
