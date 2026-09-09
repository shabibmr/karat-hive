import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Key-value detail row used across admin detail screens.
///
/// Provides a unified label/value row primitive (TR-S2-01 / ADM-SMP-11) to
/// replace divergent inline row implementations across request, offer, vendor,
/// customer, and connection detail screens.
///
/// Accepts either a [label] string or custom [labelWidget], and either a [value]
/// string or custom [valueWidget]. Uses Karat Hive tokens via `context.kh`.
class KhDetailRow extends StatelessWidget {
  const KhDetailRow({
    super.key,
    this.label,
    this.labelWidget,
    this.value,
    this.valueWidget,
    this.labelStyle,
    this.valueStyle,
    this.labelWidth = 160.0,
    this.padding = const EdgeInsets.symmetric(vertical: 6.0),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : assert(
          label != null || labelWidget != null,
          'Either label or labelWidget must be provided.',
        );

  /// Text content for the row label.
  final String? label;

  /// Custom widget for the label slot. Overrides [label] when provided.
  final Widget? labelWidget;

  /// Text content for the row value.
  final String? value;

  /// Custom widget for the value slot. Overrides [value] when provided.
  final Widget? valueWidget;

  /// Optional style override for the label text.
  final TextStyle? labelStyle;

  /// Optional style override for the value text.
  final TextStyle? valueStyle;

  /// Fixed width allocated to the label column. Defaults to 160.0.
  /// If set to null, the label takes its intrinsic width.
  final double? labelWidth;

  /// Padding around the row. Defaults to `EdgeInsets.symmetric(vertical: 6.0)`.
  final EdgeInsetsGeometry padding;

  /// Cross axis alignment of the row children. Defaults to [CrossAxisAlignment.start].
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    final effectiveLabelStyle = kh.typography.caption
        .copyWith(
          color: kh.colors.textSecondary,
          fontWeight: FontWeight.w500,
        )
        .merge(labelStyle);

    final effectiveValueStyle = kh.typography.bodySmall
        .copyWith(
          color: kh.colors.textPrimary,
        )
        .merge(valueStyle);

    final Widget renderedLabel = labelWidget ??
        Text(
          label ?? '',
          style: effectiveLabelStyle,
        );

    final Widget labelContainer = labelWidth != null
        ? SizedBox(width: labelWidth, child: renderedLabel)
        : renderedLabel;

    final Widget renderedValue;
    if (valueWidget != null) {
      renderedValue = valueWidget!;
    } else if (value != null) {
      renderedValue = Text(
        value!,
        style: effectiveValueStyle,
      );
    } else {
      renderedValue = const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          labelContainer,
          Expanded(
            child: renderedValue,
          ),
        ],
      ),
    );
  }
}
