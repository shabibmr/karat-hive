import 'package:flutter/material.dart';

import '../theme/kh_theme.dart';

/// Uppercase gold eyebrow that sits above a screen heading.
///
/// Port of `.section-label` in `ui-mock/css/components.css` (L287): 0.7rem,
/// 0.14em tracking, uppercase, gold. The mock is light-themed, so the colour
/// resolves through [KhColors.goldPrimary] rather than the mock's `--gold-700`.
class KhSectionLabel extends StatelessWidget {
  const KhSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Text(
      text.toUpperCase(),
      style: kh.typography.caption.copyWith(
        color: kh.colors.goldPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      ),
    );
  }
}
