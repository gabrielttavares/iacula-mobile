import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaSectionHeader extends StatelessWidget {
  const IaculaSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: context.textStyles.sectionTitle)),
        if (trailing != null) trailing!,
      ],
    );
  }
}
