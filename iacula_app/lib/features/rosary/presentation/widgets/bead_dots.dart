import 'package:flutter/cupertino.dart';

class BeadDots extends StatelessWidget {
  const BeadDots({super.key, required this.currentBeadIndex});

  final int currentBeadIndex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: List<Widget>.generate(13, (index) {
        final isCompleted = index < currentBeadIndex;
        final isCurrent = index == currentBeadIndex;
        final size = switch (index) {
          0 => 6.0,
          11 => 5.0,
          _ => 4.0,
        };

        return Semantics(
          label: _beadSemanticsLabel(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(
                0xFFFFFFFF,
              ).withValues(alpha: isCompleted || isCurrent ? 1 : 0.3),
              boxShadow: isCurrent
                  ? const [
                      BoxShadow(
                        color: Color(0x66FFFFFF),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  String _beadSemanticsLabel(int index) {
    if (index == 0) return 'Pai Nosso';
    if (index >= 1 && index <= 10) return 'Ave Maria $index de 10';
    if (index == 11) return 'Gloria ao Pai';
    return 'Oracao de Fatima';
  }
}
