import 'package:flutter/material.dart';
import 'package:kh_admin/core/design/theme/kh_colors.dart';

/// Admin-density typography tokens matching Karat_Hive_UI_Design_Context.md §12.
/// Clear, legible typography hierarchy tailored for data-dense admin workflows.
@immutable
class KhTypography extends ThemeExtension<KhTypography> {
  const KhTypography({
    required this.displayL,
    required this.headline,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.caption,
  });

  final TextStyle displayL;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle label;
  final TextStyle caption;

  static const standard = KhTypography(
    displayL: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: KhColors.cCream100,
      height: 1.25,
    ),
    headline: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      color: KhColors.cCream100,
      height: 1.3,
    ),
    title: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: KhColors.cCream100,
      height: 1.35,
    ),
    subtitle: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: KhColors.cCream200,
      height: 1.4,
    ),
    body: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: KhColors.cCream100,
      height: 1.45,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: KhColors.cCream200,
      height: 1.4,
    ),
    label: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: KhColors.cCream200,
      height: 1.2,
    ),
    caption: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: KhColors.cMutedGold,
      height: 1.25,
    ),
  );

  @override
  KhTypography copyWith({
    TextStyle? displayL,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? subtitle,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return KhTypography(
      displayL: displayL ?? this.displayL,
      headline: headline ?? this.headline,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      label: label ?? this.label,
      caption: caption ?? this.caption,
    );
  }

  @override
  KhTypography lerp(ThemeExtension<KhTypography>? other, double t) {
    if (other is! KhTypography) return this;
    return KhTypography(
      displayL: TextStyle.lerp(displayL, other.displayL, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      subtitle: TextStyle.lerp(subtitle, other.subtitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}
