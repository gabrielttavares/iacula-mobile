import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../features/settings/domain/jaculatoria_cadence_preset.dart';
import '../../theme/cupertino_tokens.dart';

/// Display names shown to the user for each cadence preset. The cadence
/// subtitle ("A cada 2 horas" …) lives on the enum ([cadenceLabelPtBr]).
const _presetLabels = {
  JaculatoriaCadencePreset.suave: 'Suave',
  JaculatoriaCadencePreset.regular: 'Regular',
  JaculatoriaCadencePreset.frequente: 'Frequente',
};

/// A row of 3 selectable preset buttons for jaculatória notification cadence.
///
/// Mirrors the visual language of `_IntervalButton` in `interval_selector.dart`:
/// animated container with selected highlight, haptic feedback on tap.
class CadencePresetSelector extends StatelessWidget {
  const CadencePresetSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final JaculatoriaCadencePreset selected;
  final ValueChanged<JaculatoriaCadencePreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: JaculatoriaCadencePreset.values.map((preset) {
        final isLastItem =
            preset == JaculatoriaCadencePreset.values.last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLastItem ? 0 : 8),
            child: _CadencePresetButton(
              label: _presetLabels[preset]!,
              subtitle: preset.cadenceLabelPtBr,
              isSelected: preset == selected,
              onPressed: () {
                HapticFeedback.selectionClick();
                onChanged(preset);
              },
            ),
          ),
        );
      }).toList(),
    ),
    );
  }
}

class _CadencePresetButton extends StatelessWidget {
  const _CadencePresetButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryButton
              : context.colors.card,
          borderRadius: BorderRadius.circular(IaculaRadius.small),
          border: Border.all(
            color: isSelected
                ? context.colors.primaryButton
                : context.colors.separator,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? context.colors.background
                    : context.colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected
                    ? context.colors.background.withValues(alpha: 0.75)
                    : context.colors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
