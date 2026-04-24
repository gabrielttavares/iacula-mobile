import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/settings/domain/jaculatoria_interval.dart';
import '../design/iacula_modal.dart';
import '../../theme/cupertino_tokens.dart';

/// Seletor de intervalo com botões para opções comuns e picker para valores personalizados.
class IntervalSelector extends StatelessWidget {
  const IntervalSelector({
    super.key,
    required this.selectedMinutes,
    required this.onChanged,
    this.showCustomLabel = true,
  });

  final int selectedMinutes;
  final ValueChanged<int> onChanged;
  final bool showCustomLabel;

  @override
  Widget build(BuildContext context) {
    final commonPresets = kIntervalPresets.where((p) => p.isCommon).toList();
    final isCustom = !commonPresets.any((p) => p.minutes == selectedMinutes);

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: commonPresets.length + (showCustomLabel ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (showCustomLabel && index == commonPresets.length) {
                return _IntervalButton(
                  label: 'Personalizado',
                  isSelected: isCustom,
                  onPressed: () => _showCustomPicker(context),
                );
              }
              final preset = commonPresets[index];
              return _IntervalButton(
                label: preset.label,
                isSelected: preset.minutes == selectedMinutes,
                onPressed: () => onChanged(preset.minutes),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCustomPicker(BuildContext context) async {
    int selectedHours = selectedMinutes ~/ 60;
    int selectedMins = selectedMinutes % 60;

    final result = await IaculaModal.showSheet<int>(
      context: context,
      builder: (modalContext) => _CustomIntervalPickerModal(
        initialHours: selectedHours,
        initialMinutes: selectedMins,
        onHoursChanged: (h) => selectedHours = h,
        onMinutesChanged: (m) => selectedMins = m,
      ),
    );

    if (result != null) {
      onChanged(result);
    }
  }
}

class _IntervalButton extends StatelessWidget {
  const _IntervalButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryButton
              : context.colors.card,
          borderRadius: BorderRadius.circular(20),
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

class _CustomIntervalPickerModal extends ConsumerStatefulWidget {
  const _CustomIntervalPickerModal({
    required this.initialHours,
    required this.initialMinutes,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  final int initialHours;
  final int initialMinutes;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;

  @override
  ConsumerState<_CustomIntervalPickerModal> createState() =>
      _CustomIntervalPickerModalState();
}

class _CustomIntervalPickerModalState
    extends ConsumerState<_CustomIntervalPickerModal> {
  late int _hours;
  late int _minutes;
  static const _hourOptions = [0, 1, 2, 3, 4, 5, 6];
  static const _minuteOptions = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

  @override
  void initState() {
    super.initState();
    _hours = widget.initialHours;
    _minutes = widget.initialMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = _hours * 60 + _minutes;
    final isValid = totalMinutes >= kJaculatoriaIntervalMin;

    return Container(
      color: context.colors.background,
      padding: const EdgeInsets.only(top: 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  Text(
                    _formatPreview(totalMinutes),
                    style: context.textStyles.cardTitle.copyWith(
                      fontSize: 16,
                      color: isValid
                          ? context.colors.textPrimary
                          : context.colors.warning,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: isValid
                        ? () => Navigator.of(context).pop(totalMinutes)
                        : null,
                    child: Text(
                      'Confirmar',
                      style: TextStyle(
                        color: isValid
                            ? context.colors.primaryButton
                            : context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: context.colors.separator),
            SizedBox(
              height: 216,
              child: Row(
                children: [
                  Expanded(
                    child: _PickerColumn(
                      items: _hourOptions.map((h) => '$h').toList(),
                      selectedIndex: _hours,
                      onChanged: (index) {
                        setState(() {
                          _hours = _hourOptions[index];
                          widget.onHoursChanged(_hours);
                        });
                      },
                      suffix: 'h',
                    ),
                  ),
                  Expanded(
                    child: _PickerColumn(
                      items: _minuteOptions
                          .map((m) => '${m.toString().padLeft(2, '0')}')
                          .toList(),
                      selectedIndex: _minuteOptions.indexOf(
                        _minutes.clamp(0, 55),
                      ),
                      onChanged: (index) {
                        setState(() {
                          _minutes = _minuteOptions[index];
                          widget.onMinutesChanged(_minutes);
                        });
                      },
                      suffix: 'min',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPreview(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes min';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (m == 0) return '$h ${h == 1 ? 'hora' : 'horas'}';
    return '${h}h${m.toString().padLeft(2, '0')}';
  }
}

class _PickerColumn extends StatelessWidget {
  const _PickerColumn({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    required this.suffix,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      itemExtent: 32,
      scrollController: FixedExtentScrollController(
        initialItem: selectedIndex.clamp(0, items.length - 1),
      ),
      onSelectedItemChanged: onChanged,
      children: items
          .map(
            (item) => Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 2),
                  Text(suffix, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
