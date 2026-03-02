import 'package:flutter/cupertino.dart';

/// A wrapper widget that animates its child in (fade + slide up) when it is
/// first built.
/// 
/// When used inside a [ListView.builder] or [SliverList], this automatically
/// creates a scroll-driven entrance effect because items are only built
/// when they scroll into the viewport.
class IaculaScrollItemEntrance extends StatefulWidget {
  const IaculaScrollItemEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutCubic,
    this.offsetY = 20.0,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offsetY;

  @override
  State<IaculaScrollItemEntrance> createState() =>
      _IaculaScrollItemEntranceState();
}

class _IaculaScrollItemEntranceState extends State<IaculaScrollItemEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.offsetY),
      end: Offset.zero,
    ).animate(curved);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
