import 'dart:async';

import 'package:flutter/cupertino.dart';

/// An animated overlay toast that slides up and fades in, then auto-dismisses.
///
/// Usage:
/// ```dart
/// IaculaToast.show(context, 'Texto copiado.');
/// IaculaToast.show(context, 'Salvo!', icon: CupertinoIcons.checkmark);
/// ```
class IaculaToast {
  IaculaToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;
  // ignore: unused_field — set via onControllerReady, read in _dismissImmediately
  // ignore: unused_field
  static AnimationController? _currentController;

  /// Shows an animated toast near the bottom of the screen.
  ///
  /// If a toast is already visible it is dismissed immediately before the new
  /// one is inserted.
  ///
  /// [message] – the text to display.
  /// [icon] – an optional icon shown before the text.
  /// [duration] – how long the toast stays visible (default 2 s).
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Dismiss any toast that is already on screen.
    _dismissImmediately();

    final overlay = Navigator.of(context).overlay;
    if (overlay == null) return;

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _IaculaToastOverlay(
        message: message,
        icon: icon,
        duration: duration,
        onDismissed: () {
          entry.remove();
          if (_currentEntry == entry) {
            _currentEntry = null;
            _currentController = null;
          }
        },
        onControllerReady: (controller) {
          _currentController = controller;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// Immediately removes the current toast without playing the exit animation.
  static void _dismissImmediately() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    // Don't dispose the controller here — the widget's own dispose() handles
    // that. We just remove the overlay entry which triggers unmount → dispose.
    _currentController = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _IaculaToastOverlay extends StatefulWidget {
  const _IaculaToastOverlay({
    required this.message,
    required this.duration,
    required this.onDismissed,
    required this.onControllerReady,
    this.icon,
  });

  final String message;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismissed;
  final ValueChanged<AnimationController> onControllerReady;

  @override
  State<_IaculaToastOverlay> createState() => _IaculaToastOverlayState();
}

class _IaculaToastOverlayState extends State<_IaculaToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _autoDismissTimer;

  // Enter: 300ms easeOut. Exit (reverse): 200ms easeIn.
  static const _enterDuration = Duration(milliseconds: 300);
  static const _exitDuration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _enterDuration,
      reverseDuration: _exitDuration,
    );

    widget.onControllerReady(_controller);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    // Slide from 20 px below to 0 on enter; reverse on exit.
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    // Play the enter animation then schedule auto-dismiss.
    _controller.forward().then((_) {
      if (!mounted) return;
      _autoDismissTimer = Timer(widget.duration, _dismiss);
    });
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
