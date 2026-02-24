import 'package:flutter/cupertino.dart';

import 'cupertino_tokens.dart';

final class AppTheme {
  AppTheme._();

  static CupertinoThemeData light() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: IaculaColors.background,
      primaryColor: IaculaColors.primaryButton,
      textTheme: CupertinoTextThemeData(
        textStyle: IaculaText.secondary,
        navLargeTitleTextStyle: IaculaText.largeTitle,
        navTitleTextStyle: IaculaText.cardTitle,
        navActionTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: IaculaColors.primaryButton,
        ),
        tabLabelTextStyle: IaculaText.tabLabel,
      ),
    );
  }
}
