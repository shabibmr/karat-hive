import 'package:flutter/material.dart';

/// Admin design token colors matching Karat_Hive_UI_Design_Context.md §4.1.
/// Sapphire/Gold/Cream palette with admin-density styling.
///
/// Semantic fields (`backgroundPrimary`, `textPrimary`, …) differ between
/// [dark] and [light]; primitive palette constants keep the same hex values.
@immutable
class KhColors extends ThemeExtension<KhColors> {
  // Const color primitives
  static const Color cSapphire900 = Color(0xFF0A1128);
  static const Color cSapphire800 = Color(0xFF111A36);
  static const Color cSapphire700 = Color(0xFF182344);
  static const Color cGold400 = Color(0xFFD4AF37);
  static const Color cGold300 = Color(0xFFE3C65A);
  static const Color cGold200 = Color(0xFFF1E5AC);
  static const Color cGold100 = Color(0xFFFFF4C7);
  static const Color cCream100 = Color(0xFFFDFBF7);
  static const Color cCream200 = Color(0xFFEDE8DC);
  static const Color cMutedGold = Color(0xFFA58A2A);
  static const Color cSuccess = Color(0xFF5FAF7B);
  static const Color cWarning = Color(0xFFD9A441);
  static const Color cError = Color(0xFFC96A6A);
  static const Color cInfo = Color(0xFF6D9BCB);
  static const Color cDarkGold = Color(0xFF8F731B);
  static const Color cDeepGold = Color(0xFF9B7B20);
  static const Color cWhite = Color(0xFFFFFFFF);
  static const Color cInkSecondary = Color(0xFF3A4566);

  const KhColors({
    required this.sapphire900,
    required this.sapphire800,
    required this.sapphire700,
    required this.gold400,
    required this.gold300,
    required this.gold200,
    required this.gold100,
    required this.cream100,
    required this.cream200,
    required this.mutedGold,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.darkGold,
    required this.deepGold,
    required this.backgroundPrimary,
    required this.backgroundElevated,
    required this.backgroundSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderSubtle,
    required this.borderStandard,
    required this.borderStrong,
  });

  // Primitive tokens
  final Color sapphire900;
  final Color sapphire800;
  final Color sapphire700;
  final Color gold400;
  final Color gold300;
  final Color gold200;
  final Color gold100;
  final Color cream100;
  final Color cream200;
  final Color mutedGold;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color darkGold;
  final Color deepGold;

  // Semantic tokens
  final Color backgroundPrimary;
  final Color backgroundElevated;
  final Color backgroundSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color borderSubtle;
  final Color borderStandard;
  final Color borderStrong;

  Color get surface => backgroundElevated;

  Color get goldPrimary => gold400;
  Color get accentPrimary => gold400;
  Color get accentHighlight => gold200;
  Color get accentSpecular => gold100;

  Color get border => borderSubtle;

  /// Dark ink for text/icons on gold primary buttons (same in both themes).
  Color get onAccent => sapphire900;

  LinearGradient get goldMetallicGradient => LinearGradient(
        colors: [
          darkGold,
          gold400,
          gold200,
          gold400,
          deepGold,
        ],
      );

  static const dark = KhColors(
    sapphire900: cSapphire900,
    sapphire800: cSapphire800,
    sapphire700: cSapphire700,
    gold400: cGold400,
    gold300: cGold300,
    gold200: cGold200,
    gold100: cGold100,
    cream100: cCream100,
    cream200: cCream200,
    mutedGold: cMutedGold,
    success: cSuccess,
    warning: cWarning,
    error: cError,
    info: cInfo,
    darkGold: cDarkGold,
    deepGold: cDeepGold,
    backgroundPrimary: cSapphire900,
    backgroundElevated: cSapphire800,
    backgroundSurface: cSapphire700,
    textPrimary: cCream100,
    textSecondary: cCream200,
    textMuted: cMutedGold,
    borderSubtle: Color(0x2ED4AF37), // gold400 @ 18%
    borderStandard: Color(0x59D4AF37), // gold400 @ 35%
    borderStrong: Color(0xA6F1E5AC), // gold200 @ 65%
  );

  /// Cream canvas with sapphire ink — default admin look.
  static const light = KhColors(
    sapphire900: cSapphire900,
    sapphire800: cSapphire800,
    sapphire700: cSapphire700,
    gold400: cGold400,
    gold300: cGold300,
    gold200: cGold200,
    gold100: cGold100,
    cream100: cCream100,
    cream200: cCream200,
    mutedGold: cMutedGold,
    success: cSuccess,
    warning: cWarning,
    error: cError,
    info: cInfo,
    darkGold: cDarkGold,
    deepGold: cDeepGold,
    backgroundPrimary: cCream100,
    backgroundElevated: cWhite,
    backgroundSurface: cCream200,
    textPrimary: cSapphire900,
    textSecondary: cInkSecondary,
    textMuted: cMutedGold,
    borderSubtle: Color(0x2E0A1128), // sapphire900 @ 18%
    borderStandard: Color(0x590A1128), // sapphire900 @ 35%
    borderStrong: Color(0xA60A1128), // sapphire900 @ 65%
  );

  @override
  KhColors copyWith({
    Color? sapphire900,
    Color? sapphire800,
    Color? sapphire700,
    Color? gold400,
    Color? gold300,
    Color? gold200,
    Color? gold100,
    Color? cream100,
    Color? cream200,
    Color? mutedGold,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? darkGold,
    Color? deepGold,
    Color? backgroundPrimary,
    Color? backgroundElevated,
    Color? backgroundSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? borderSubtle,
    Color? borderStandard,
    Color? borderStrong,
  }) {
    return KhColors(
      sapphire900: sapphire900 ?? this.sapphire900,
      sapphire800: sapphire800 ?? this.sapphire800,
      sapphire700: sapphire700 ?? this.sapphire700,
      gold400: gold400 ?? this.gold400,
      gold300: gold300 ?? this.gold300,
      gold200: gold200 ?? this.gold200,
      gold100: gold100 ?? this.gold100,
      cream100: cream100 ?? this.cream100,
      cream200: cream200 ?? this.cream200,
      mutedGold: mutedGold ?? this.mutedGold,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      darkGold: darkGold ?? this.darkGold,
      deepGold: deepGold ?? this.deepGold,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      backgroundSurface: backgroundSurface ?? this.backgroundSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStandard: borderStandard ?? this.borderStandard,
      borderStrong: borderStrong ?? this.borderStrong,
    );
  }

  @override
  KhColors lerp(ThemeExtension<KhColors>? other, double t) {
    if (other is! KhColors) return this;
    return KhColors(
      sapphire900: Color.lerp(sapphire900, other.sapphire900, t)!,
      sapphire800: Color.lerp(sapphire800, other.sapphire800, t)!,
      sapphire700: Color.lerp(sapphire700, other.sapphire700, t)!,
      gold400: Color.lerp(gold400, other.gold400, t)!,
      gold300: Color.lerp(gold300, other.gold300, t)!,
      gold200: Color.lerp(gold200, other.gold200, t)!,
      gold100: Color.lerp(gold100, other.gold100, t)!,
      cream100: Color.lerp(cream100, other.cream100, t)!,
      cream200: Color.lerp(cream200, other.cream200, t)!,
      mutedGold: Color.lerp(mutedGold, other.mutedGold, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      darkGold: Color.lerp(darkGold, other.darkGold, t)!,
      deepGold: Color.lerp(deepGold, other.deepGold, t)!,
      backgroundPrimary:
          Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundElevated:
          Color.lerp(backgroundElevated, other.backgroundElevated, t)!,
      backgroundSurface:
          Color.lerp(backgroundSurface, other.backgroundSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStandard: Color.lerp(borderStandard, other.borderStandard, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
    );
  }
}
