import 'package:flutter/cupertino.dart';

class IaculaProgressBar extends StatelessWidget {
  const IaculaProgressBar({
    super.key,
    required this.value,
    this.backgroundColor,
    this.color,
    this.minHeight = 4.0,
  });

  final double value;
  final Color? backgroundColor;
  final Color? color;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              Container(
                width: width,
                height: minHeight,
                decoration: BoxDecoration(
                  color: backgroundColor ?? CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(minHeight / 2),
                ),
              ),
              Container(
                width: width * value.clamp(0.0, 1.0),
                height: minHeight,
                decoration: BoxDecoration(
                  color: color ?? CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(minHeight / 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
