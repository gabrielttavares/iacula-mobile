import 'package:flutter/material.dart';

class AnimatedCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: value ? const Color(0xFFD6BA8E) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: value ? const Color(0xFFD6BA8E) : const Color(0xFF837562),
            width: 2,
          ),
        ),
        child: AnimatedOpacity(
          opacity: value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: const Icon(
            Icons.check,
            size: 18,
            color: Color(0xFF1E1A17), // Dark background color for the check mark
          ),
        ),
      ),
    );
  }
}
