import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// An animated icon widget that performs a scale-bounce transition when
/// the displayed [icon] changes.
///
/// When a new [icon] value is provided, the widget:
/// 1. Scales down to 0 (120ms, easeIn)
/// 2. Swaps the icon at the midpoint
/// 3. Scales back up to 1.0 (200ms, easeOutBack — overshoot bounce)
class IaculaAnimatedIcon extends StatefulWidget {
  const IaculaAnimatedIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 22.0,
    this.enableHaptics = true,
  });

  /// The current [IconData] to display.
  final IconData icon;

  /// The color of the icon.
  final Color color;

  /// The size of the icon. Defaults to 22.0.
  final double size;

  /// Whether to fire [HapticFeedback.selectionClick] on icon change.
  final bool enableHaptics;

  @override
  State<IaculaAnimatedIcon> createState() => _IaculaAnimatedIconState();
}

class _IaculaAnimatedIconState extends State<IaculaAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  /// The icon currently being rendered. Swapped at the animation midpoint
  /// so the old icon scales out and the new icon scales in.
  late IconData _displayedIcon;

  @override
  void initState() {
    super.initState();
    _displayedIcon = widget.icon;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Two-phase scale animation:
    //   Phase 1 (weight 37.5 → 0-120ms): scale 1.0 → 0.0 with easeIn
    //   Phase 2 (weight 62.5 → 120-320ms): scale 0.0 → 1.0 with easeOutBack
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 37.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 62.5,
      ),
    ]).animate(_controller);

    // Swap the displayed icon at the midpoint (when scale reaches 0).
    _controller.addListener(() {
      if (_controller.value >= 0.375 && _displayedIcon != widget.icon) {
        _displayedIcon = widget.icon;
      }
    });
  }

  @override
  void didUpdateWidget(IaculaAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.icon != oldWidget.icon) {
      _controller.forward(from: 0.0);
      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            _displayedIcon,
            color: widget.color,
            size: widget.size,
          ),
        );
      },
    );
  }
}
