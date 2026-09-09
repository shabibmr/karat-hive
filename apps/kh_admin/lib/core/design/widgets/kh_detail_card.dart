import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Standardized card container widget replacing repetitive `Container` +
/// `BoxDecoration` literals across Karat Hive admin detail screens.
///
/// Styled with Karat Hive design tokens:
/// - Background: [KhColors.surface]
/// - Border: [KhColors.border] with [KhShapes.cardBorderWidth]
/// - Corners: [KhShapes.roundedLg]
/// - Default padding: 16.0 (`EdgeInsets.all(16.0)`)
///
/// When [title] or [titleTrailing] are specified, a standardized card header
/// row is automatically rendered above [child].
class KhDetailCard extends StatelessWidget {
  const KhDetailCard({
    super.key,
    required this.child,
    this.title,
    this.titleTrailing,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.titleStyle,
    this.width,
    this.height,
  });

  /// The primary content of the card.
  final Widget child;

  /// Optional card section title rendered in the card header.
  final String? title;

  /// Optional widget displayed on the trailing side of the card header
  /// (e.g. action buttons, status chips, or reference links).
  final Widget? titleTrailing;

  /// Inner padding of the card container. Defaults to `const EdgeInsets.all(16.0)`.
  final EdgeInsetsGeometry padding;

  /// Outer margin surrounding the card container.
  final EdgeInsetsGeometry? margin;

  /// Cross-axis alignment when header and child are arranged in a column.
  /// Defaults to [CrossAxisAlignment.start].
  final CrossAxisAlignment crossAxisAlignment;

  /// Optional background color override. Defaults to [KhColors.surface].
  final Color? color;

  /// Optional border color override. Defaults to [KhColors.border].
  final Color? borderColor;

  /// Optional border radius override. Defaults to [KhShapes.roundedLg].
  final BorderRadiusGeometry? borderRadius;

  /// Optional text style override for the [title].
  final TextStyle? titleStyle;

  /// Optional explicit width for the card container.
  final double? width;

  /// Optional explicit height for the card container.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;
    final shapes = kh.shapes;
    final spacing = kh.spacing;
    final typography = kh.typography;

    final hasHeader = title != null || titleTrailing != null;

    final Widget content;
    if (hasHeader) {
      content = Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: titleStyle ??
                        typography.title.copyWith(
                          color: colors.textPrimary,
                        ),
                  ),
                )
              else
                const Spacer(),
              if (titleTrailing != null) ...[
                if (title != null) SizedBox(width: spacing.sm),
                titleTrailing!,
              ],
            ],
          ),
          SizedBox(height: spacing.md),
          child,
        ],
      );
    } else {
      content = child;
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: borderRadius ?? shapes.roundedLg,
        border: Border.all(
          color: borderColor ?? colors.border,
          width: shapes.cardBorderWidth,
        ),
      ),
      child: content,
    );
  }
}
