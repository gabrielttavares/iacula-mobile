import 'package:flutter/cupertino.dart';

/// A wrapper widget that provides true staggered entrance animation for a list
/// of children. Each child fades in and slides up with a configurable per-item
/// delay, creating a cascading entrance effect.
///
/// Animation triggers once on first build and does not re-animate on parent
/// rebuilds.
class IaculaStaggerEntrance extends StatefulWidget {
  const IaculaStaggerEntrance({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 60),
    this.itemDuration = const Duration(milliseconds: 280),
    this.curve = Curves.easeOut,
  });

  /// The widgets to animate in with a staggered entrance.
  final List<Widget> children;

  /// Delay between each child's animation start. Defaults to 60ms.
  final Duration staggerDelay;

  /// Duration of each individual child's animation. Defaults to 280ms.
  final Duration itemDuration;

  /// The curve applied to each child's animation. Defaults to [Curves.easeOut].
  final Curve curve;

  @override
  State<IaculaStaggerEntrance> createState() => _IaculaStaggerEntranceState();
}

class _IaculaStaggerEntranceState extends State<IaculaStaggerEntrance>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    if (_hasAnimated || widget.children.isEmpty) return;

    final totalDuration = widget.itemDuration +
        widget.staggerDelay * (widget.children.length - 1);

    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    _hasAnimated = true;
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[],
      );
    }

    final controller = _controller!;
    final totalMs = controller.duration!.inMicroseconds;
    final staggerMs = widget.staggerDelay.inMicroseconds;
    final itemMs = widget.itemDuration.inMicroseconds;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < widget.children.length; i++)
          _buildAnimatedChild(
            index: i,
            controller: controller,
            totalUs: totalMs,
            staggerUs: staggerMs,
            itemUs: itemMs,
            child: widget.children[i],
          ),
      ],
    );
  }

  Widget _buildAnimatedChild({
    required int index,
    required AnimationController controller,
    required int totalUs,
    required int staggerUs,
    required int itemUs,
    required Widget child,
  }) {
    final start = (staggerUs * index) / totalUs;
    final end = (staggerUs * index + itemUs) / totalUs;

    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: widget.curve,
      ),
    );

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 20.0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, _) {
        return Opacity(
          opacity: curvedAnimation.value,
          child: Transform.translate(
            offset: offsetAnimation.value,
            child: child,
          ),
        );
      },
    );
  }
}
