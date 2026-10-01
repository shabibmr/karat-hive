import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';

/// Home / Guest app-bar wordmark (visual pass H03 / Home-1).
///
/// Tracked Cormorant “KARAT HIVE” in gold. Latin labels are uppercased with
/// letter-spacing; Arabic keeps the localised form with no tracking. A clover
/// glyph may sit ahead of the wordmark when an asset exists — its absence does
/// not block this mark. Pink logo PNGs are never used here.
class KhBrandMark extends StatelessWidget {
  const KhBrandMark({
    super.key,
    required this.label,
  });

  /// Localised brand name (e.g. `guest.title`). Latin is shown uppercased.
  final String label;

  /// Absolute tracking for Latin wordmarks at [_fontSize] (Home-1).
  static const double _letterSpacing = 3.2;
  static const double _fontSize = 18;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fonts = KhFonts.forLocale(Localizations.localeOf(context));
    final display = fonts.isArabic ? label : label.toUpperCase();

    return Text(
      display,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: label,
      style: fonts.serifStyle(_fontSize, FontWeight.w600, height: 1.0).copyWith(
            color: tokens.gold,
            letterSpacing: fonts.isArabic ? 0 : _letterSpacing,
          ),
    );
  }
}
