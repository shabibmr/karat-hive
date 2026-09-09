import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Standardized inline feedback banner replacing the hand-rolled
/// `_buildFeedbackBanner` methods on the request / vendor / customer detail
/// screens.
///
/// Visual spec (TR-S2-03 — winner: the vendor-detail treatment, with the
/// softer translucent border two of the three call sites already used):
/// - padding: `EdgeInsets.all(kh.spacing.md)`
/// - shape: `kh.shapes.roundedMd`
/// - fill: tone color at alpha 0.12
/// - border: tone color at alpha 0.4
/// - icon: outline (`check_circle_outline` / `error_outline`), size 20
/// - text: `kh.typography.bodySmall` in the tone color, `FontWeight.w600`
/// - tone: [KhColors.success] when [isSuccess], else [KhColors.error]
/// - dismiss: trailing close button, shown only when [onDismiss] is provided
class KhFeedbackBanner extends StatelessWidget {
  const KhFeedbackBanner({
    super.key,
    required this.message,
    required this.isSuccess,
    this.onDismiss,
  });

  /// The feedback text.
  final String message;

  /// Whether this is a success (`true`) or error (`false`) banner.
  final bool isSuccess;

  /// When non-null, a trailing close button is rendered that invokes this.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final color = isSuccess ? kh.colors.success : kh.colors.error;

    return Container(
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: color,
            size: 20.0,
          ),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Text(
              message,
              style: kh.typography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16.0),
              color: color,
              splashRadius: 16.0,
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
