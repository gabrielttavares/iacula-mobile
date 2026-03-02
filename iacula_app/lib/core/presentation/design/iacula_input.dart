import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaTextInput extends StatefulWidget {
  const IaculaTextInput({
    super.key,
    this.controller,
    this.placeholder,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final int maxLines;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  @override
  State<IaculaTextInput> createState() => _IaculaTextInputState();
}

class _IaculaTextInputState extends State<IaculaTextInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        _isFocused ? context.colors.primaryButton : context.colors.separator;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(IaculaRadius.small),
      ),
      child: CupertinoTextField(
        controller: widget.controller,
        placeholder: widget.placeholder,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        autofocus: widget.autofocus,
        maxLines: widget.maxLines,
        readOnly: widget.readOnly,
        focusNode: _focusNode,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: null,
        onChanged: widget.onChanged,
      ),
    );
  }
}

class IaculaTimeInput extends StatelessWidget {
  const IaculaTimeInput({
    super.key,
    this.controller,
    this.placeholder = 'HH:MM',
    this.onChanged,
  });

  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;

  void _showPicker(BuildContext context) {
    final now = DateTime.now();
    DateTime initialDate = now;

    if (controller != null && controller!.text.isNotEmpty) {
      final parts = controller!.text.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        initialDate = DateTime(now.year, now.month, now.day, hour, minute);
      }
    }

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: context.colors.card,
        child: Column(
          children: [
            Container(
              height: 44,
              color: context.colors.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: initialDate,
                onDateTimeChanged: (DateTime newDate) {
                  final hh = newDate.hour.toString().padLeft(2, '0');
                  final mm = newDate.minute.toString().padLeft(2, '0');
                  final time = '$hh:$mm';
                  controller?.text = time;
                  onChanged?.call(time);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: IaculaTextInput(
        controller: controller,
        placeholder: placeholder,
        keyboardType: TextInputType.datetime,
        readOnly: true,
      ),
    );
  }
}

class IaculaValidatedInput extends StatelessWidget {
  const IaculaValidatedInput({
    super.key,
    required this.label,
    required this.child,
    this.errorText,
  });

  final String label;
  final Widget child;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyles.secondary),
        const SizedBox(height: 6),
        child,
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: context.textStyles.secondary.copyWith(color: context.colors.error),
          ),
        ],
      ],
    );
  }
}
