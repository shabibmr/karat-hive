import 'package:flutter/material.dart';

/// Admin design token colors matching Karat_Hive_UI_Design_Context.md §4.1.
/// Sapphire/Gold/Cream palette with admin-density styling.
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

  // Semantic token accessors
  Color get backgroundPrimary => sapphire900;
  Color get backgroundElevated => sapphire800;
  Color get backgroundSurface => sapphire700;
  Color get surface => backgroundElevated;

  Color get textPrimary => cream100;
  Color get textSecondary => cream200;
  Color get textMuted => mutedGold;

  Color get goldPrimary => gold400;
  Color get accentPrimary => gold400;
  Color get accentHighlight => gold200;
  Color get accentSpecular => gold100;

  Color get borderSubtle => gold400.withValues(alpha: 0.18);
  Color get borderStandard => gold400.withValues(alpha: 0.35);
  Color get borderStrong => gold200.withValues(alpha: 0.65);
  Color get border => borderSubtle;

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
    );
  }
}
