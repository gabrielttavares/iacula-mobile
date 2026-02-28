import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class IaculaColorScheme {
  final Color background;
  final Color card;
  final Color title;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryButton;
  final Color success;
  final Color warning;
  final Color error;
  final Color separator;
  final Color placeholder;
  final Color systemGray6;
  final Color secondaryButton;
  final Color bannerBackground;
  final Color bannerForeground;
  final Color homeWarmBackground;
  final Color homeSacredAccent;
  final Color homeHeroTop;
  final Color homeHeroBottom;
  final Color homeHeroText;
  final Color homeHeroSubtext;
  final Color homeHeroLabel;
  final Color homeHeroFallback;

  const IaculaColorScheme._({
    required this.background,
    required this.card,
    required this.title,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryButton,
    required this.success,
    required this.warning,
    required this.error,
    required this.separator,
    required this.placeholder,
    required this.systemGray6,
    required this.secondaryButton,
    required this.bannerBackground,
    required this.bannerForeground,
    required this.homeWarmBackground,
    required this.homeSacredAccent,
    required this.homeHeroTop,
    required this.homeHeroBottom,
    required this.homeHeroText,
    required this.homeHeroSubtext,
    required this.homeHeroLabel,
    required this.homeHeroFallback,
  });

  static const dark = IaculaColorScheme._(
    background: Color(0xFF01060F),
    card: Color(0xFF050D1C),
    title: Color(0xFFF7F5EC),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9AA9CD),
    primaryButton: Color(0xFFF7F5EC),
    success: Color(0xFF34C759),
    warning: Color(0xFFFF9500),
    error: Color(0xFFFF3B30),
    separator: Color(0x33FFFFFF), // Changed from 0x33000000
    placeholder: Color(0xFF0E1422),
    systemGray6: Color(0xFF0F0F10),
    secondaryButton: Color(0x33FFFFFF),
    bannerBackground: Color(0xFF0F0D00),
    bannerForeground: Color(0xFFFFE082),
    homeWarmBackground: Color(0xFF01060F),
    homeSacredAccent: Color(0xFFF7F5EC),
    homeHeroTop: Color(0x4D000000), // 0.3 opacity black
    homeHeroBottom: Color(0xDB000000), // 0.86 opacity black
    homeHeroText: Color(0xFFF6F6F8),
    homeHeroSubtext: Color(0x99F6F6F8),
    homeHeroLabel: Color(0x47FFFFFF),
    homeHeroFallback: Color(0xFF1A1610),
  );

  static const light = IaculaColorScheme._(
    background: Color(0xFFF5F3EF),
    card: Color(0xFFFFFFFF),
    title: Color(0xFF030D22),
    textPrimary: Color(0xFF030D22),
    textSecondary: Color(0xFF5A6478),
    primaryButton: Color(0xFF0975C8),
    success: Color(0xFF34C759),
    warning: Color(0xFFFF9500),
    error: Color(0xFFFF3B30),
    separator: Color(0x1A000000),
    placeholder: Color(0xFFE7E7EC),
    systemGray6: Color(0xFFF2F2F7),
    secondaryButton: Color(0x1A000000),
    bannerBackground: Color(0xFFFFF3CD),
    bannerForeground: Color(0xFF856404),
    homeWarmBackground: Color(0xFFF5F3EF),
    homeSacredAccent: Color(0xFF0975C8),
    homeHeroTop: Color(0x4D000000),
    homeHeroBottom: Color(0xDB000000),
    homeHeroText: Color(0xFFF6F6F8),
    homeHeroSubtext: Color(0x99F6F6F8),
    homeHeroLabel: Color(0x47FFFFFF),
    homeHeroFallback: Color(0xFF3D3125),
  );
}

/// Deprecated: use `context.colors` instead.
@Deprecated('Use context.colors instead')
final class IaculaColors {
  IaculaColors._();

  static const background = Color(0xFF01060F);
  static const card = Color(0xFF050D1C);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9AA9CD);
  static const primaryButton = Color(0xFFF7F5EC);
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);
  static const separator = Color(0x33000000);
  static const homeWarmBackground = Color(0xFF01060F);
  static const homeSacredAccent = Color(0xFFF7F5EC);
  static const homeHeroTop = Color(0xFF01060F);
  static const homeHeroBottom = Color(0xFF020A14);
}

class IaculaTextScheme {
  final TextStyle largeTitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitle;
  final TextStyle secondary;
  final TextStyle tabLabel;

  const IaculaTextScheme._({
    required this.largeTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.secondary,
    required this.tabLabel,
  });

  factory IaculaTextScheme.from(BuildContext context, IaculaColorScheme colors) {
    final scaler = MediaQuery.textScalerOf(context);
    return IaculaTextScheme._(
      largeTitle: GoogleFonts.lora(
        fontSize: scaler.scale(34),
        fontWeight: FontWeight.w700,
        color: colors.title,
      ),
      sectionTitle: GoogleFonts.lora(
        fontSize: scaler.scale(22),
        fontWeight: FontWeight.w600,
        color: colors.title,
      ),
      cardTitle: GoogleFonts.lora(
        fontSize: scaler.scale(17),
        fontWeight: FontWeight.w600,
        color: colors.title,
      ),
      secondary: GoogleFonts.lora(
        fontSize: scaler.scale(15),
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      tabLabel: GoogleFonts.lora(
        fontSize: scaler.scale(11),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  factory IaculaTextScheme.fromColors(IaculaColorScheme colors) =>
      IaculaTextScheme._(
        largeTitle: GoogleFonts.lora(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: colors.title,
        ),
        sectionTitle: GoogleFonts.lora(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors.title,
        ),
        cardTitle: GoogleFonts.lora(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colors.title,
        ),
        secondary: GoogleFonts.lora(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
        ),
        tabLabel: GoogleFonts.lora(fontSize: 11, fontWeight: FontWeight.w500),
      );
}

/// Deprecated: use `context.textStyles` instead.
@Deprecated('Use context.textStyles instead')
final class IaculaText {
  IaculaText._();

  static final largeTitle = GoogleFonts.lora(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: const Color(0xFFF7F5EC),
  );

  static final sectionTitle = GoogleFonts.lora(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFF7F5EC),
  );

  static final cardTitle = GoogleFonts.lora(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFF7F5EC),
  );

  static final secondary = GoogleFonts.lora(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: IaculaColorScheme.dark.textSecondary,
  );

  static final tabLabel = GoogleFonts.lora(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}

extension IaculaThemeX on BuildContext {
  IaculaColorScheme get colors {
    final brightness = CupertinoTheme.brightnessOf(this);
    return brightness == Brightness.dark
        ? IaculaColorScheme.dark
        : IaculaColorScheme.light;
  }

  IaculaTextScheme get textStyles => IaculaTextScheme.from(this, colors);
}

final class IaculaShadows {
  IaculaShadows._();

  static const card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8)),
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
  static const card = 24.0;
  static const banner = 24.0;
}

final class IaculaMetrics {
  IaculaMetrics._();

  static const inputHeight = 44.0;
  static const modalCornerRadius = 24.0;
  static const minTapTarget = 44.0;
}
