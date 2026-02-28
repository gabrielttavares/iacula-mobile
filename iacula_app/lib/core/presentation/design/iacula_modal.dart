import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

final class IaculaModal {
  IaculaModal._();

  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String actionLabel = 'OK',
  }) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  static Future<bool> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) async {
    final value = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: destructive,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return value ?? false;
  }

  static Future<T?> showSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double? maxHeightFraction,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) {
        Widget child = Container(
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(IaculaMetrics.modalCornerRadius),
            ),
          ),
          child: SafeArea(top: false, child: builder(context)),
        );

        if (maxHeightFraction != null) {
          child = ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * maxHeightFraction,
            ),
            child: child,
          );
        }

        return Align(alignment: Alignment.bottomCenter, child: child);
      },
    );
  }
}
