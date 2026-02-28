import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaTextInput extends StatelessWidget {
  const IaculaTextInput({
    super.key,
    this.controller,
    this.placeholder,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      maxLines: maxLines,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border.all(color: context.colors.separator),
        borderRadius: BorderRadius.circular(IaculaRadius.small),
      ),
      onChanged: onChanged,
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

  @override
  Widget build(BuildContext context) {
    return IaculaTextInput(
      controller: controller,
      placeholder: placeholder,
      keyboardType: TextInputType.datetime,
      onChanged: onChanged,
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
