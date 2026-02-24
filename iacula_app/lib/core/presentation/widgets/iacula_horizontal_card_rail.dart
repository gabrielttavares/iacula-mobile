import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';

class IaculaHorizontalCardRail extends StatelessWidget {
  const IaculaHorizontalCardRail({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.7;
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: IaculaSpacing.sm),
        itemBuilder: (context, index) =>
            SizedBox(width: width, child: itemBuilder(context, index)),
      ),
    );
  }
}
