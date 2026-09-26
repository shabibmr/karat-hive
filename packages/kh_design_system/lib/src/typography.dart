import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';

/// Font families bundled in `packages/kh_design_system/fonts/` (§3.1).
///
/// Latin locales use Cormorant Garamond (serif) + DM Sans (sans); Arabic swaps
/// to Noto Naskh Arabic + IBM Plex Sans Arabic so Latin metrics never set the
/// line height of an Arabic run.
class KhFonts {
  const KhFonts._({required this.serif, required this.sans, required this.isArabic});

  factory KhFonts.forLocale(Locale? locale) =>
      locale?.languageCode == 'ar' ? arabic : latin;

  static const _package = 'kh_design_system';

  static const latin = KhFonts._(
    serif: 'CormorantGaramond',
    sans: 'DMSans',
    isArabic: false,
  );

  static const arabic = KhFonts._(
    serif: 'NotoNaskhArabic',
    sans: 'IBMPlexSansArabic',
    isArabic: true,
  );

  final String serif;
  final String sans;

  /// Arabic has no case and takes no tracking (§3.4 rule 2).
  final bool isArabic;

  /// Display face — never below 16 px, never in form values or data (§3.1).
  TextStyle serifStyle(double size, FontWeight weight, {double? height}) => TextStyle(
        fontFamily: serif,
        package: _package,
        fontSize: size,
        fontWeight: weight,
        height: height,
      );

  TextStyle sansStyle(
    double size,
    FontWeight weight, {
    double? height,
    double trackingEm = 0,
  }) =>
      TextStyle(
        fontFamily: sans,
        package: _package,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: isArabic ? 0 : size * trackingEm,
      );
}

/// Specialist 1a text styles that have no Material `TextTheme` role (§3.2–§3.3).
///
/// Read via `context.typography.eyebrow`. Uppercase styles (`fieldLabel`,
/// `eyebrow`, `segmentDirection`) carry tracking only; callers upper-case the
/// string themselves, and never for Arabic.
@immutable
class KhTypography extends ThemeExtension<KhTypography> {
  const KhTypography({
    required this.displayGuest,
    required this.statNumber,
    required this.heroLead,
    required this.blockTitle,
    required this.heroBody,
    required this.accordionTitle,
    required this.purityChip,
    required this.buttonPrimary,
    required this.segmentDirection,
    required this.bodyLoose,
    required this.link,
    required this.linkSmall,
    required this.chip,
    required this.denomChip,
    required this.statLabel,
    required this.stepLabel,
    required this.fieldLabel,
    required this.fieldInlineLabel,
    required this.eyebrow,
    required this.badge,
    required this.numberBadge,
    required this.tabular,
  });

  factory KhTypography.from(KhFonts f, KhTokens t) => KhTypography(
        displayGuest: f.serifStyle(30, FontWeight.w600, height: 1.10).copyWith(color: t.ink),
        statNumber: f.serifStyle(28, FontWeight.w700, height: 1.0).copyWith(color: t.ink),
        heroLead: f.serifStyle(23, FontWeight.w600, height: 1.15).copyWith(color: t.gold),
        blockTitle: f.serifStyle(22, FontWeight.w600).copyWith(color: t.ink),
        heroBody: f.serifStyle(20, FontWeight.w500, height: 1.20).copyWith(color: t.surface),
        accordionTitle: f.serifStyle(19, FontWeight.w600).copyWith(color: t.ink),
        purityChip: f.serifStyle(16, FontWeight.w600).copyWith(color: t.ink),
        buttonPrimary: f.sansStyle(15, FontWeight.w700).copyWith(color: t.ink),
        segmentDirection:
            f.sansStyle(14, FontWeight.w700, trackingEm: 0.06).copyWith(color: t.ink),
        bodyLoose: f.sansStyle(14, FontWeight.w400, height: 1.5).copyWith(color: t.inkSecondary),
        link: f.sansStyle(14, FontWeight.w600).copyWith(color: t.goldDark),
        linkSmall: f.sansStyle(13, FontWeight.w600).copyWith(color: t.goldDark),
        chip: f.sansStyle(13, FontWeight.w500).copyWith(color: t.ink),
        denomChip: f.sansStyle(12.5, FontWeight.w500).copyWith(color: t.ink),
        statLabel: f.sansStyle(12, FontWeight.w400).copyWith(color: t.inkSecondary),
        stepLabel: f.sansStyle(11.5, FontWeight.w600, height: 1.2).copyWith(color: t.ink),
        // §2.5 deviation: text at ink@0.62, not the handoff's 0.55.
        fieldLabel:
            f.sansStyle(10.5, FontWeight.w600, trackingEm: 0.08).copyWith(color: t.inkSecondary),
        fieldInlineLabel: f.sansStyle(10.5, FontWeight.w400).copyWith(color: t.inkSecondary),
        eyebrow: f.sansStyle(10, FontWeight.w600, trackingEm: 0.10).copyWith(color: t.goldDark),
        badge: f.sansStyle(10, FontWeight.w600, height: 1.6).copyWith(color: t.surface),
        numberBadge: f.sansStyle(11, FontWeight.w700).copyWith(color: t.goldDark),
        tabular: f.sansStyle(14, FontWeight.w400).copyWith(
          color: t.ink,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );

  final TextStyle displayGuest;
  final TextStyle statNumber;
  final TextStyle heroLead;

  /// "My activity" row header, serif 22/600 (§3.2).
  final TextStyle blockTitle;
  final TextStyle heroBody;
  final TextStyle accordionTitle;
  final TextStyle purityChip;
  final TextStyle buttonPrimary;
  final TextStyle segmentDirection;
  final TextStyle bodyLoose;
  final TextStyle link;
  final TextStyle linkSmall;
  final TextStyle chip;
  final TextStyle denomChip;
  final TextStyle statLabel;
  final TextStyle stepLabel;
  final TextStyle fieldLabel;
  final TextStyle fieldInlineLabel;
  final TextStyle eyebrow;
  final TextStyle badge;
  final TextStyle numberBadge;

  /// Numbers users compare — weights, AED, counts (§3.4 rule 3).
  final TextStyle tabular;

  @override
  KhTypography copyWith() => this;

  @override
  KhTypography lerp(ThemeExtension<KhTypography>? other, double t) => this;
}

extension KhTypographyX on BuildContext {
  KhTypography get typography =>
      Theme.of(this).extension<KhTypography>() ??
      KhTypography.from(KhFonts.latin, KhTokens.light);
}
