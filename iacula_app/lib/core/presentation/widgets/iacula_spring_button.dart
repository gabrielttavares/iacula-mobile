import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// A button wrapper that animates scale and shadow on press to create
/// a spring-compression "real button" effect.
class IaculaSpringButton extends StatefulWidget {
  const IaculaSpringButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.90,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  @override
  State<IaculaSpringButton> createState() => _IaculaSpringButtonState();
}

class _IaculaSpringButtonState extends State<IaculaSpringButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shadowBlurAnimation;
  late final Animation<double> _shadowOffsetAnimation;
  late final Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
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

    // Shadow: blur 12 -> 2
    _shadowBlurAnimation = Tween<double>(
      begin: 12.0,
      end: 2.0,
    ).animate(curvedAnimation);

    // Shadow: offset Y 4 -> 1
    _shadowOffsetAnimation = Tween<double>(
      begin: 4.0,
      end: 1.0,
    ).animate(curvedAnimation);

    // Shadow: opacity 0x14 (20) -> 0x0A (10), normalized 0-255
    _shadowOpacityAnimation = Tween<double>(
      begin: 20.0 / 255.0,
      end: 10.0 / 255.0,
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
    HapticFeedback.lightImpact();
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
          return Transform.scale(
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
          );
        },
        child: widget.child,
      ),
    );
  }
}
