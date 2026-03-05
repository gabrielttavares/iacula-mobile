import 'package:flutter/cupertino.dart';

class MysteryProgressBar extends StatelessWidget {
  const MysteryProgressBar({
    super.key,
    required this.currentIndex,
    required this.currentProgress,
    this.totalSegments = 5,
  });

  final int currentIndex;
  final double currentProgress;
  final int totalSegments;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(totalSegments, (index) {
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;
        final progress = isCurrent ? currentProgress.clamp(0.0, 1.0) : 0.0;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < totalSegments - 1 ? 2 : 0),
            child: MysteryProgressSegment(
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              progress: progress,
            ),
          ),
        );
      }),
    );
  }
}

class MysteryProgressSegment extends StatelessWidget {
  const MysteryProgressSegment({
    super.key,
    required this.isCompleted,
    required this.isCurrent,
    required this.progress,
  });

  final bool isCompleted;
  final bool isCurrent;
  final double progress;

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0x4DFFFFFF);
    const fillColor = Color(0xFFFFFFFF);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 3,
            child: ColoredBox(
              color: baseColor,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: isCompleted ? 1 : (isCurrent ? progress : 0),
                  child: const ColoredBox(color: fillColor),
                ),
              ),
            ),
          ),
        ),
        if (isCompleted)
          const Positioned(
            right: 0,
            top: -8,
            child: Icon(CupertinoIcons.check_mark, color: fillColor, size: 9),
          ),
      ],
    );
  }
}
