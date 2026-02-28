import 'package:flutter/cupertino.dart';

import 'cupertino_tokens.dart';

final class AppTheme {
  AppTheme._();

  static CupertinoThemeData dark() {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: IaculaColors.background,
      primaryColor: IaculaColors.primaryButton,
      textTheme: CupertinoTextThemeData(
        primaryColor: IaculaColors.primaryButton,
        textStyle: IaculaText.secondary,
        navLargeTitleTextStyle: IaculaText.largeTitle,
        navTitleTextStyle: IaculaText.cardTitle,
        navActionTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: IaculaColors.primaryButton,
        ),
        tabLabelTextStyle: IaculaText.tabLabel,
      ),
    );
  }
}
