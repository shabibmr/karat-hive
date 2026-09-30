import 'package:flutter/material.dart';

/// Design tokens exposed through a ThemeExtension so feature code reads
/// `context.tokens.space.md`, never a raw value (Architecture-Frontend §8.1).
///
/// Values follow the Modern Luxury Jewellery Editorial system
/// (`apps/kh_mobile/karat_hive/docs/UI-Design-Context.md` §2, §4).
@immutable
class KhTokens extends ThemeExtension<KhTokens> {
  const KhTokens({
    required this.gold,
    required this.goldDark,
    required this.ctaFill,
    required this.formSurface,
    required this.ink,
    required this.surface,
    required this.paper,
    required this.navBackground,
    required this.danger,
    required this.success,
    required this.warning,
    required this.info,
    required this.radius,
    required this.space,
  });

  /// Accent signal: Home icons, carousel, tile arrows, selected nav.
  /// Never text on ivory (~2.1:1) — icons ≥ 24 px or fills only (§2.5).
  final Color gold;

  /// Links, eyebrows, small labels, glyphs inside soft-gold circles.
  final Color goldDark;

  /// Primary button / selected-chip / card CTA fill. Label is [ink].
  final Color ctaFill;

  /// [ctaFill] pressed/hover — a relative darken (10% toward [ink]) so it
  /// follows any [ctaFill] override.
  Color get ctaFillPressed => Color.lerp(ctaFill, ink, 0.10)!;

  /// Create and review scaffold background (Home keeps [surface]).
  final Color formSurface;

  /// All text, dark surfaces (hero), labels on gold fills.
  final Color ink;

  /// Ivory Home / shell background; also text on ink.
  final Color surface;

  /// White raised-on-ivory panels (stats strip, Guest accordion).
  final Color paper;

  /// Bottom navigation bar fill.
  final Color navBackground;

  final Color danger;
  final Color success;
  final Color warning;
  final Color info;
  final KhRadius radius;
  final KhSpace space;

  static const light = KhTokens(
    gold: Color(0xFFD8A858),
    goldDark: Color(0xFF8A6A1F),
    ctaFill: Color(0xFFD8C0A8),
    formSurface: Color(0xFFF0E8E0),
    ink: Color(0xFF1C1B1A),
    surface: Color(0xFFFDFBF7),
    paper: Color(0xFFFFFFFF),
    navBackground: Color(0xFFF6F1E6),
    danger: Color(0xFFB3261E),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFD9A441),
    info: Color(0xFF6D9BCB),
    radius: KhRadius(),
    space: KhSpace(),
  );

  /// Alias of [surface] under its palette name.
  Color get ivory => surface;

  // Ink tints (§2.3). Use these named levels; don't invent new ones.
  Color get inkFill => ink.withValues(alpha: 0.06);
  Color get inkHairline => ink.withValues(alpha: 0.08);
  Color get inkBorderSoft => ink.withValues(alpha: 0.12);
  Color get inkBorderControl => ink.withValues(alpha: 0.15);
  Color get inkBorderChip => ink.withValues(alpha: 0.18);
  Color get inkBorderField => ink.withValues(alpha: 0.20);
  Color get inkBorderButton => ink.withValues(alpha: 0.25);
  Color get inkBorderCheck => ink.withValues(alpha: 0.40);

  /// Icons and chevrons only — fails AA for small text (§2.5).
  Color get inkMuted => ink.withValues(alpha: 0.55);

  /// Lowest alpha allowed for text (~4.7:1 on ivory).
  Color get inkSecondary => ink.withValues(alpha: 0.62);
  Color get inkNavIdle => ink.withValues(alpha: 0.70);

  // Gold tints (§2.3).
  Color get goldWash => gold.withValues(alpha: 0.06);
  Color get goldPanel => gold.withValues(alpha: 0.09);
  Color get goldTile => gold.withValues(alpha: 0.12);
  Color get goldIconCircle => gold.withValues(alpha: 0.14);
  Color get goldNumber => gold.withValues(alpha: 0.16);
  Color get goldStepperPlus => gold.withValues(alpha: 0.22);
  Color get goldRing => gold.withValues(alpha: 0.50);
  Color get goldDashed => gold.withValues(alpha: 0.70);

  /// Inactive carousel dot on ink.
  Color get ivoryDotIdle => surface.withValues(alpha: 0.45);

  @override
  KhTokens copyWith({
    Color? gold,
    Color? goldDark,
    Color? ctaFill,
    Color? formSurface,
    Color? ink,
    Color? surface,
    Color? paper,
    Color? navBackground,
    Color? danger,
    Color? success,
    Color? warning,
    Color? info,
    KhRadius? radius,
    KhSpace? space,
  }) =>
      KhTokens(
        gold: gold ?? this.gold,
        goldDark: goldDark ?? this.goldDark,
        ctaFill: ctaFill ?? this.ctaFill,
        formSurface: formSurface ?? this.formSurface,
        ink: ink ?? this.ink,
        surface: surface ?? this.surface,
        paper: paper ?? this.paper,
        navBackground: navBackground ?? this.navBackground,
        danger: danger ?? this.danger,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        info: info ?? this.info,
        radius: radius ?? this.radius,
        space: space ?? this.space,
      );

  @override
  KhTokens lerp(ThemeExtension<KhTokens>? other, double t) => this;
}

/// Spacing scale (§4.1). `md` (16) is the screen side gutter.
class KhSpace {
  const KhSpace();
  double get xxs => 2;
  double get xs => 4;
  double get s6 => 6;
  double get sm => 8;
  double get s10 => 10;
  double get s12 => 12;
  double get s14 => 14;
  double get md => 16;
  double get s22 => 22;
  double get lg => 24;
  double get xl => 32;
}

/// Corner radii (§4.3).
class KhRadius {
  const KhRadius();

  /// Checkbox.
  double get chipSm => 5;
  double get sm => 8;

  /// Denomination chips, segmented track, service icon badge.
  double get chipMd => 10;

  /// Primary filled / outlined buttons (48 px height, flat rectangle).
  double get button => 10;

  /// Inputs, purity chips, thumbnails.
  double get md => 12;

  /// Alias of [md] for fields.
  double get field => 12;

  /// Cards, tiles, hero, panels, ornament chips.
  double get card => 16;

  /// Kept for existing callers.
  double get lg => 20;

  /// Fully rounded chips and legacy callers. Primary buttons use [button].
  double get pill => 24;

  /// Circles, dots, badges.
  double get full => 999;
}

extension KhTokensX on BuildContext {
  KhTokens get tokens => Theme.of(this).extension<KhTokens>() ?? KhTokens.light;
}
