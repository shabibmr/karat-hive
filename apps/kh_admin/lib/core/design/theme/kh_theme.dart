import 'package:flutter/material.dart';
import 'package:kh_admin/core/design/theme/kh_colors.dart';
import 'package:kh_admin/core/design/theme/kh_shapes.dart';
import 'package:kh_admin/core/design/theme/kh_spacing.dart';
import 'package:kh_admin/core/design/theme/kh_typography.dart';

/// Aggregated design theme extension.
/// Exposes `context.kh.colors`, `context.kh.typography`, `context.kh.spacing`, `context.kh.shapes`.
@immutable
class KhThemeExtension extends ThemeExtension<KhThemeExtension> {
  const KhThemeExtension({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.shapes,
  });

  final KhColors colors;
  final KhTypography typography;
  final KhSpacing spacing;
  final KhShapes shapes;

  static final dark = KhThemeExtension(
    colors: KhColors.dark,
    typography: KhTypography.dark,
    spacing: KhSpacing.admin,
    shapes: KhShapes.standard,
  );

  static final light = KhThemeExtension(
    colors: KhColors.light,
    typography: KhTypography.light,
    spacing: KhSpacing.admin,
    shapes: KhShapes.standard,
  );

  @override
  KhThemeExtension copyWith({
    KhColors? colors,
    KhTypography? typography,
    KhSpacing? spacing,
    KhShapes? shapes,
  }) {
    return KhThemeExtension(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      shapes: shapes ?? this.shapes,
    );
  }

  @override
  KhThemeExtension lerp(ThemeExtension<KhThemeExtension>? other, double t) {
    if (other is! KhThemeExtension) return this;
    return KhThemeExtension(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      spacing: spacing.lerp(other.spacing, t),
      shapes: shapes.lerp(other.shapes, t),
    );
  }
}

/// Convenience extension on [BuildContext] to access Karat Hive design tokens.
extension KhThemeContext on BuildContext {
  KhThemeExtension get kh =>
      Theme.of(this).extension<KhThemeExtension>() ?? KhThemeExtension.light;
}

/// Builds the Karat Hive Admin Portal Material 3 theme.
///
/// Defaults to [Brightness.light]. Pass [Brightness.dark] for the sapphire canvas.
ThemeData buildKhAdminTheme([Brightness brightness = Brightness.light]) {
  final isDark = brightness == Brightness.dark;
  final colors = isDark ? KhColors.dark : KhColors.light;
  final typography = isDark ? KhTypography.dark : KhTypography.light;
  const shapes = KhShapes.standard;
  const spacing = KhSpacing.admin;
  final extension = isDark ? KhThemeExtension.dark : KhThemeExtension.light;

  final baseTheme = isDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);

  return baseTheme.copyWith(
    brightness: brightness,
    scaffoldBackgroundColor: colors.backgroundPrimary,
    canvasColor: colors.backgroundPrimary,
    cardColor: colors.backgroundElevated,
    dividerColor: colors.borderSubtle,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary: colors.gold400,
            onPrimary: colors.onAccent,
            secondary: colors.gold300,
            onSecondary: colors.onAccent,
            surface: colors.backgroundElevated,
            onSurface: colors.textPrimary,
            error: colors.error,
            onError: colors.cream100,
          )
        : ColorScheme.light(
            primary: colors.gold400,
            onPrimary: colors.onAccent,
            secondary: colors.gold300,
            onSecondary: colors.onAccent,
            surface: colors.backgroundElevated,
            onSurface: colors.textPrimary,
            error: colors.error,
            onError: colors.cream100,
          ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.backgroundElevated,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: typography.title,
    ),
    cardTheme: CardThemeData(
      color: colors.backgroundElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: shapes.roundedMd,
        side: BorderSide(
          color: colors.borderSubtle,
          width: shapes.cardBorderWidth,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.backgroundElevated,
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      labelStyle: typography.bodySmall.copyWith(color: colors.textSecondary),
      hintStyle: typography.bodySmall.copyWith(color: colors.textMuted),
      border: OutlineInputBorder(
        borderRadius: shapes.roundedSm,
        borderSide: BorderSide(color: colors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: shapes.roundedSm,
        borderSide: BorderSide(color: colors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: shapes.roundedSm,
        borderSide: BorderSide(
          color: colors.gold400,
          width: shapes.focusBorderWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: shapes.roundedSm,
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: shapes.roundedSm,
        borderSide: BorderSide(
          color: colors.error,
          width: shapes.focusBorderWidth,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.gold400,
        foregroundColor: colors.onAccent,
        textStyle: typography.body.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: shapes.roundedSm,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.sm,
        ),
        minimumSize: Size(64, spacing.buttonHeight),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.gold400,
        side: BorderSide(color: colors.gold400),
        textStyle: typography.body.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: shapes.roundedSm,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.lg,
          vertical: spacing.sm,
        ),
        minimumSize: Size(64, spacing.buttonHeight),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.gold400,
        textStyle: typography.body.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: shapes.roundedSm,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.backgroundElevated,
      titleTextStyle: typography.title,
      contentTextStyle: typography.body,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: colors.backgroundElevated,
    ),
    extensions: [
      extension,
      colors,
      typography,
      KhSpacing.admin,
      KhShapes.standard,
    ],
  );
}
