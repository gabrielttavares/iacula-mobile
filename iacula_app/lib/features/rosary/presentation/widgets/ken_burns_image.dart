import 'package:flutter/cupertino.dart';

class KenBurnsImage extends StatefulWidget {
  const KenBurnsImage({
    super.key,
    required this.imagePath,
    this.child,
    this.duration = const Duration(seconds: 60),
  });

  final String? imagePath;
  final Widget? child;
  final Duration duration;

  @override
  State<KenBurnsImage> createState() => _KenBurnsImageState();
}

class _KenBurnsImageState extends State<KenBurnsImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
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
        final t = _controller.value;
        final scale = 1.0 + (0.12 * t);
        final alignment = Alignment(-0.08 + (0.16 * t), -0.06 + (0.12 * t));

        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.scale(
              scale: scale,
              child: Align(alignment: alignment, child: _buildImage()),
            ),
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }

  Widget _buildImage() {
    final path = widget.imagePath;
    if (path == null || path.isEmpty) {
      return _fallback();
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF111111),
      alignment: Alignment.center,
      child: const Icon(
        CupertinoIcons.xmark,
        color: Color(0x80FFFFFF),
        size: 26,
      ),
    );
  }
}
