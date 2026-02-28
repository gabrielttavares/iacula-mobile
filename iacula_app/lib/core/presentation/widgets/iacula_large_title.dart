import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaLargeTitle extends StatelessWidget {
  const IaculaLargeTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: context.textStyles.largeTitle);
  }
}
