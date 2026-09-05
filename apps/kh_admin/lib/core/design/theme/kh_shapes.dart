import 'package:flutter/material.dart';

/// Admin-density shape tokens matching Karat_Hive_UI_Design_Context.md §10.
/// Editorial soft rectangles with precise corner radii and border configurations.
@immutable
class KhShapes extends ThemeExtension<KhShapes> {
  const KhShapes({
    required this.radiusXs,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusPill,
    required this.cardBorderWidth,
    required this.focusBorderWidth,
  });

  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusPill;

  final double cardBorderWidth;
  final double focusBorderWidth;

  BorderRadius get roundedXs => BorderRadius.circular(radiusXs);
  BorderRadius get roundedSm => BorderRadius.circular(radiusSm);
  BorderRadius get roundedMd => BorderRadius.circular(radiusMd);
  BorderRadius get roundedLg => BorderRadius.circular(radiusLg);
  BorderRadius get roundedXl => BorderRadius.circular(radiusXl);
  BorderRadius get pill => BorderRadius.circular(radiusPill);

  static const standard = KhShapes(
    radiusXs: 4.0,
    radiusSm: 6.0,
    radiusMd: 8.0,
    radiusLg: 12.0,
    radiusXl: 16.0,
    radiusPill: 999.0,
    cardBorderWidth: 1.0,
    focusBorderWidth: 1.5,
  );

  @override
  KhShapes copyWith({
    double? radiusXs,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusPill,
    double? cardBorderWidth,
    double? focusBorderWidth,
  }) {
    return KhShapes(
      radiusXs: radiusXs ?? this.radiusXs,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusPill: radiusPill ?? this.radiusPill,
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      focusBorderWidth: focusBorderWidth ?? this.focusBorderWidth,
    );
  }

  @override
  KhShapes lerp(ThemeExtension<KhShapes>? other, double t) {
    if (other is! KhShapes) return this;
    return KhShapes(
      radiusXs: _lerpDouble(radiusXs, other.radiusXs, t),
      radiusSm: _lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: _lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: _lerpDouble(radiusLg, other.radiusLg, t),
      radiusXl: _lerpDouble(radiusXl, other.radiusXl, t),
      radiusPill: _lerpDouble(radiusPill, other.radiusPill, t),
      cardBorderWidth: _lerpDouble(cardBorderWidth, other.cardBorderWidth, t),
      focusBorderWidth: _lerpDouble(focusBorderWidth, other.focusBorderWidth, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
