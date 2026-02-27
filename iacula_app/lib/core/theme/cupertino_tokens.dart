import 'package:flutter/cupertino.dart';

final class IaculaColors {
  IaculaColors._();

  static const background = Color(0xFFF2F2F7);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF6E6E73);
  static const primaryButton = Color(0xFF0975C8);
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);
  static const separator = Color(0x1A000000);
  static const homeWarmBackground = Color(0xFFFFFAF3);
  static const homeSacredAccent = Color(0xFFB08A57);
  static const homeHeroTop = Color(0xFFF6EFE3);
  static const homeHeroBottom = Color(0xFFFDF9F2);
}

final class IaculaShadows {
  IaculaShadows._();

  static const card = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
}

final class IaculaSpacing {
  IaculaSpacing._();

  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

final class IaculaRadius {
  IaculaRadius._();

  static const small = 12.0;
  static const card = 20.0;
  static const banner = 24.0;
}

final class IaculaMetrics {
  IaculaMetrics._();

  static const inputHeight = 44.0;
  static const modalCornerRadius = 24.0;
  static const minTapTarget = 44.0;
}

final class IaculaText {
  IaculaText._();

  static const largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: IaculaColors.textPrimary,
  );

  static const sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: IaculaColors.textPrimary,
  );

  static const cardTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: IaculaColors.textPrimary,
  );

  static const secondary = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: IaculaColors.textSecondary,
  );

  static const tabLabel = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
}
