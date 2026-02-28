import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// A card wrapper that animates scale, shadow depth, and vertical position
/// on press to create a "floating layer sinks toward surface" effect.
class IaculaTouchableCard extends StatefulWidget {
  const IaculaTouchableCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.92,
    this.pressTranslateY = 2.0,
    this.enableHaptics = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final double pressTranslateY;
  final bool enableHaptics;

  @override
  State<IaculaTouchableCard> createState() => _IaculaTouchableCardState();
}

class _IaculaTouchableCardState extends State<IaculaTouchableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _translateAnimation;
  late final Animation<double> _shadowBlurAnimation;
  late final Animation<double> _shadowOffsetAnimation;
  late final Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 280),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOutBack,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(curvedAnimation);

    _translateAnimation = Tween<double>(
      begin: 0.0,
      end: widget.pressTranslateY,
    ).animate(curvedAnimation);

    // Shadow: blur 20 -> 4
    _shadowBlurAnimation = Tween<double>(
      begin: 20.0,
      end: 4.0,
    ).animate(curvedAnimation);

    // Shadow: offset Y 8 -> 1
    _shadowOffsetAnimation = Tween<double>(
      begin: 8.0,
      end: 1.0,
    ).animate(curvedAnimation);

    // Shadow: opacity 0x0A (10) -> 0x07 (7), normalized 0-255
    _shadowOpacityAnimation = Tween<double>(
      begin: 10.0 / 255.0,
      end: 7.0 / 255.0,
    ).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    _controller.forward();
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(
                        0, 0, 0, _shadowOpacityAnimation.value,
                      ),
                      blurRadius: _shadowBlurAnimation.value,
                      offset: Offset(0, _shadowOffsetAnimation.value),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
