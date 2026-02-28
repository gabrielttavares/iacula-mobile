import 'package:flutter/cupertino.dart';

import 'cupertino_tokens.dart';

final class AppTheme {
  AppTheme._();

  static CupertinoThemeData dark() {
    const colors = IaculaColorScheme.dark;
    final texts = IaculaTextScheme.from(colors);
    return CupertinoThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primaryButton,
      textTheme: CupertinoTextThemeData(
        primaryColor: colors.primaryButton,
        textStyle: texts.secondary,
        navLargeTitleTextStyle: texts.largeTitle,
        navTitleTextStyle: texts.cardTitle,
        navActionTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colors.primaryButton,
        ),
        tabLabelTextStyle: texts.tabLabel,
      ),
    );
  }

  static CupertinoThemeData light() {
    const colors = IaculaColorScheme.light;
    final texts = IaculaTextScheme.from(colors);
    return CupertinoThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primaryButton,
      textTheme: CupertinoTextThemeData(
        primaryColor: colors.primaryButton,
        textStyle: texts.secondary,
        navLargeTitleTextStyle: texts.largeTitle,
        navTitleTextStyle: texts.cardTitle,
        navActionTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colors.primaryButton,
        ),
        tabLabelTextStyle: texts.tabLabel,
      ),
    );
  }
}
