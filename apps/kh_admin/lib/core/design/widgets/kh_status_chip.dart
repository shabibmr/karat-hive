import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart' show KhStatusTone;

import 'package:kh_admin/core/design/theme/kh_colors.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';

export 'package:kh_design_system/kh_design_system.dart' show KhStatusTone;

/// Pill-shaped status badge with a leading dot.
///
/// Port of `.status-chip` and its `::before` dot (`ui-mock/css/components.css`
/// L195–L215). The label is always rendered as text: state is never carried by
/// colour alone (`Karat_Hive_UI_Design_Context.md` §40/§56).
class KhStatusChip extends StatelessWidget {
  const KhStatusChip({
    super.key,
    required this.label,
    this.tone = KhStatusTone.neutral,
    this.icon,
    this.dense = false,
  });

  final String label;
  final KhStatusTone tone;

  /// Replaces the leading dot when a more specific glyph reads better
  /// (the taxonomy tree uses a pause glyph for deactivated nodes).
  final IconData? icon;

  /// Tightens padding and type for use inside data-dense table and tree rows.
  final bool dense;

  Color _toneColor(KhColors colors) {
    switch (tone) {
      case KhStatusTone.neutral:
        return colors.textMuted;
      case KhStatusTone.success:
        return colors.success;
      case KhStatusTone.warning:
        return colors.warning;
      case KhStatusTone.danger:
        return colors.error;
      case KhStatusTone.info:
        return colors.info;
      case KhStatusTone.accent:
        return colors.gold400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final tint = _toneColor(kh.colors);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? kh.spacing.xs + 2 : kh.spacing.sm,
        vertical: dense ? kh.spacing.xxs : kh.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.15),
        borderRadius: kh.shapes.pill,
        border: Border.all(color: tint.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: dense ? 10 : 12, color: tint)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            ),
          SizedBox(width: dense ? 3 : kh.spacing.xs),
          // Rendered verbatim rather than upper-cased: the taxonomy tree's
          // "Inactive" badge is a localised string, and `toUpperCase()` is a
          // no-op in Arabic while mangling the English asserted by tests.
          // Callers that mirror the mock's `text-transform` pass upper case.
          //
          // Flexible keeps a long status ("HIGH PRIORITY") from overflowing a
          // narrow table cell; it ellipsises instead of painting a stripe.
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: kh.typography.caption.copyWith(
                color: tint,
                fontSize: dense ? 10 : 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
