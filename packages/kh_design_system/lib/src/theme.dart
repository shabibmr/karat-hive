import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';

/// Karat Hive mobile theme — Direction 1a "Classic"
/// (`apps/kh_mobile/karat_hive/docs/UI-Design-Context.md`).
///
/// Warm, light and flat: ivory paper, ink type, gold as a signal. Depth comes
/// from borders and tint, never Material elevation (§4.4), so every surface
/// sets `surfaceTintColor: Colors.transparent` and elevation 0.
///
/// ```dart
/// MaterialApp(theme: KhTheme.light(locale: locale));
/// ```
abstract final class KhTheme {
  /// Builds the theme for [locale]; Arabic swaps font families and drops
  /// tracking (§9).
  static ThemeData light({Locale? locale}) {
    const t = KhTokens.light;
    final fonts = KhFonts.forLocale(locale);
    final type = KhTypography.from(fonts, t);
    final textTheme = _textTheme(fonts, t);

    final scheme = ColorScheme.fromSeed(seedColor: t.gold).copyWith(
      primary: t.gold,
      onPrimary: t.ink,
      secondary: t.ink,
      onSecondary: t.surface,
      surface: t.surface,
      onSurface: t.ink,
      onSurfaceVariant: t.inkMuted,
      surfaceContainerLowest: t.paper,
      surfaceContainer: t.navBackground,
      outline: t.inkBorderField,
      outlineVariant: t.inkHairline,
      error: t.danger,
      onError: t.surface,
      surfaceTint: Colors.transparent,
    );

    final pill = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radius.pill),
    );
    const buttonSize = Size(64, 48);

    OutlineInputBorder field(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.radius.field),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamily: fonts.sans,
      package: 'kh_design_system',
      scaffoldBackgroundColor: t.surface,
      canvasColor: t.surface,
      dividerColor: t.inkHairline,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [t, type],
      iconTheme: IconThemeData(color: t.ink, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: t.surface,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: t.ink),
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radius.card),
          side: BorderSide(color: t.inkBorderSoft),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radius.card),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(t.radius.card)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: t.surface),
        actionTextColor: t.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radius.md),
        ),
      ),
      dividerTheme: DividerThemeData(color: t.inkHairline, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.gold),

      // §6.1 Buttons — 48 px pills; gold CTAs carry ink text.
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonSize),
          shape: WidgetStatePropertyAll(pill),
          elevation: const WidgetStatePropertyAll(0),
          textStyle: WidgetStatePropertyAll(type.buttonPrimary),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return t.gold.withValues(alpha: 0.4);
            if (s.contains(WidgetState.pressed) || s.contains(WidgetState.hovered)) {
              return t.goldPressed;
            }
            return t.gold;
          }),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? t.inkBorderCheck : t.ink,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonSize,
          shape: pill,
          elevation: 0,
          backgroundColor: t.gold,
          foregroundColor: t.ink,
          disabledBackgroundColor: t.gold.withValues(alpha: 0.4),
          disabledForegroundColor: t.inkBorderCheck,
          textStyle: type.buttonPrimary,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: pill,
          foregroundColor: t.ink,
          disabledForegroundColor: t.inkBorderCheck,
          side: BorderSide(color: t.inkBorderButton),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.goldDark,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: type.link,
        ),
      ),

      // §6.3 Form field — 48 px row, radius 12, 1 px ink@0.20, gold focus.
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: type.fieldInlineLabel,
        floatingLabelStyle: type.fieldInlineLabel,
        hintStyle: textTheme.bodyMedium?.copyWith(color: t.inkSecondary),
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: t.danger),
        suffixStyle: textTheme.bodyMedium?.copyWith(color: t.inkSecondary),
        prefixIconColor: t.inkMuted,
        suffixIconColor: t.inkMuted,
        border: field(t.inkBorderField),
        enabledBorder: field(t.inkBorderField),
        disabledBorder: field(t.inkHairline),
        focusedBorder: field(t.gold, 1.5),
        errorBorder: field(t.danger, 1.5),
        focusedErrorBorder: field(t.danger, 1.5),
      ),

      // §6.4 Chips — no checkmark, ink fill when selected.
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: t.ink,
        disabledColor: t.inkFill,
        showCheckmark: false,
        labelStyle: type.chip,
        secondaryLabelStyle: type.chip.copyWith(
          color: t.surface,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: BorderSide(color: t.inkBorderChip),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radius.card),
        ),
        elevation: 0,
        pressElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // §6.5 Toggle — gold track on, ink@0.15 off, ivory knob, no outline.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(t.surface),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.gold : t.inkBorderControl,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      // §6.6 Checkbox — 18 px, radius 5, gold fill with ink check.
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.gold : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(t.ink),
        side: BorderSide(color: t.inkBorderCheck, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radius.chipSm),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.gold : t.inkBorderCheck,
        ),
      ),

      // §6.16 Bottom navigation — 80 px, gold@0.28 stadium pill.
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: t.navBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: t.goldNavPill,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? textTheme.labelMedium!.copyWith(color: t.ink, fontWeight: FontWeight.w700)
              : textTheme.labelMedium!.copyWith(color: t.inkNavIdle),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? t.ink : t.inkNavIdle,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: t.ink,
        unselectedLabelColor: t.inkSecondary,
        indicatorColor: t.gold,
        dividerColor: t.inkHairline,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.inkMuted,
        textColor: t.ink,
        subtitleTextStyle: textTheme.bodySmall,
      ),
    );
  }

  /// Material roles mapped onto the 1a scale (§3.3). Serif for titles, sans
  /// for everything read or typed.
  static TextTheme _textTheme(KhFonts f, KhTokens t) {
    TextStyle ink(TextStyle s) => s.copyWith(color: t.ink);
    return TextTheme(
      displayLarge: ink(f.serifStyle(40, FontWeight.w600, height: 1.10)),
      displayMedium: ink(f.serifStyle(34, FontWeight.w600, height: 1.10)),
      displaySmall: ink(f.serifStyle(30, FontWeight.w600, height: 1.10)),
      headlineLarge: ink(f.serifStyle(26, FontWeight.w600, height: 1.15)),
      headlineMedium: ink(f.serifStyle(24, FontWeight.w600, height: 1.15)),
      headlineSmall: ink(f.serifStyle(21, FontWeight.w600, height: 1.10)),
      titleLarge: ink(f.serifStyle(20, FontWeight.w600)),
      titleMedium: ink(f.serifStyle(17, FontWeight.w600, height: 1.10)),
      titleSmall: ink(f.sansStyle(14, FontWeight.w600)),
      bodyLarge: ink(f.sansStyle(14, FontWeight.w400)),
      bodyMedium: ink(f.sansStyle(13, FontWeight.w400, height: 1.45)),
      // §2.5 deviation: small text renders at ink@0.62, not the handoff's 0.55.
      bodySmall: f.sansStyle(11, FontWeight.w400).copyWith(color: t.inkSecondary),
      labelLarge: ink(f.sansStyle(14, FontWeight.w600)),
      labelMedium: ink(f.sansStyle(12, FontWeight.w500)),
      labelSmall: f
          .sansStyle(10.5, FontWeight.w600, trackingEm: 0.08)
          .copyWith(color: t.inkSecondary),
    );
  }
}

/// Motion constants (§8). Honour `MediaQuery.disableAnimationsOf` at call sites.
abstract final class KhMotion {
  static const carouselInterval = Duration(milliseconds: 4200);
  static const carouselSlide = Duration(milliseconds: 600);
  static const carouselCurve = Cubic(0.2, 0.7, 0.2, 1);
  static const cardPress = Duration(milliseconds: 200);
  static const select = Duration(milliseconds: 150);
  static const reveal = Duration(milliseconds: 200);
}

/// Pre-1a entry point, kept so existing tests and goldens keep compiling.
/// New code uses [KhTheme.light].
ThemeData khTheme({Locale? locale}) => KhTheme.light(locale: locale);
