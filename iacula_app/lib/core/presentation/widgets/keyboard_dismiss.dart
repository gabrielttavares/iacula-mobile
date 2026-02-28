import 'package:flutter/cupertino.dart';

class IaculaKeyboardDismiss extends StatelessWidget {
  const IaculaKeyboardDismiss({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.unfocus();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
