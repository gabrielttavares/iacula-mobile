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
  JaculatoriaCadencePreset.maisFrequente: 'Mais frequente',
};

/// A 2×2 grid of selectable preset buttons for jaculatória notification cadence.
///
/// Mirrors the visual language of `_IntervalButton` in `interval_selector.dart`:
/// animated container with selected highlight, haptic feedback on tap.
///
/// Presets are laid out in density order (left-to-right, top-to-bottom):
/// Suave | Regular
/// Frequente | Mais frequente
class CadencePresetSelector extends StatelessWidget {
  const CadencePresetSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final JaculatoriaCadencePreset selected;
  final ValueChanged<JaculatoriaCadencePreset> onChanged;

  static const int _columnsPerRow = 2;
  static const double _columnGap = 8;
  static const double _rowGap = 8;

  @override
  Widget build(BuildContext context) {
    final allPresets = JaculatoriaCadencePreset.values;

    // Chunk the flat list into rows of [_columnsPerRow].
    final presetRows = <List<JaculatoriaCadencePreset>>[];
    for (var startIndex = 0; startIndex < allPresets.length; startIndex += _columnsPerRow) {
      final endIndex = (startIndex + _columnsPerRow).clamp(0, allPresets.length);
      presetRows.add(allPresets.sublist(startIndex, endIndex));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: presetRows.indexed.map((indexedRow) {
        final rowIndex = indexedRow.$1;
        final rowPresets = indexedRow.$2;
        final isLastRow = rowIndex == presetRows.length - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLastRow ? 0 : _rowGap),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowPresets.indexed.map((indexedPreset) {
                final columnIndex = indexedPreset.$1;
                final preset = indexedPreset.$2;
                final isLastColumn = columnIndex == rowPresets.length - 1;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLastColumn ? 0 : _columnGap),
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
          ),
        );
      }).toList(),
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
