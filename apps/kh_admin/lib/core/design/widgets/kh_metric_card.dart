import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Dashboard metric tile: large value, uppercase gold label, and a drill-down
/// link that navigates to the matching management screen.
///
/// Port of `.metric-card` (`ui-mock/css/components.css` L381) including its
/// hover lift (`transform: translateY(-2px)` plus a raised shadow). The mock's
/// `.gold-light` specular sweep is *not* ported — it is a one-shot animation
/// there; [emphasized] instead renders the stronger gold treatment those cards
/// carry at rest.
class KhMetricCard extends StatefulWidget {
  const KhMetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.linkText,
    this.onTap,
    this.emphasized = false,
    this.valueColor,
  });

  final String value;
  final String label;
  final String linkText;
  final VoidCallback? onTap;

  /// The mock's `gold-light` cards (Customers, Vendors) sit slightly forward.
  final bool emphasized;

  /// Overrides the value colour — the mock tints Platform Statistics `gold-200`.
  final Color? valueColor;

  @override
  State<KhMetricCard> createState() => _KhMetricCardState();
}

class _KhMetricCardState extends State<KhMetricCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;
    final spacing = kh.spacing;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          padding: EdgeInsets.all(spacing.lg),
          decoration: BoxDecoration(
            color: widget.emphasized
                ? colors.gold400.withValues(alpha: 0.07)
                : colors.backgroundElevated,
            borderRadius: kh.shapes.roundedLg,
            border: Border.all(
              color: _hovered || widget.emphasized
                  ? colors.borderStandard
                  : colors.borderSubtle,
              width: kh.shapes.cardBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.35 : 0.18),
                blurRadius: _hovered ? 18 : 8,
                offset: Offset(0, _hovered ? 6 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.value,
                style: kh.typography.displayL.copyWith(
                  color: widget.valueColor ?? colors.goldPrimary,
                  height: 1.1,
                ),
              ),
              SizedBox(height: spacing.xxs),
              Text(
                widget.label.toUpperCase(),
                style: kh.typography.caption.copyWith(
                  color: colors.goldPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
              SizedBox(height: spacing.md),
              Text(
                widget.linkText,
                style: kh.typography.bodySmall.copyWith(
                  color: colors.gold300,
                  fontWeight: FontWeight.w600,
                  decoration:
                      _hovered ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: colors.gold300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
