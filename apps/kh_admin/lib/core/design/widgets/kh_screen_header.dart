import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';

/// Standard admin screen header: gold eyebrow, display heading, optional
/// supporting line, and a trailing slot for a status chip or primary action.
///
/// Port of the `.screen-block` header used at the top of every admin screen in
/// `ui-mock/screens/admin/` — `.section-label` above `h1.screen-heading`, with
/// the trailing element pushed to the far edge by `justify-content:space-between`.
class KhScreenHeader extends StatelessWidget {
  const KhScreenHeader({
    super.key,
    required this.eyebrow,
    required this.heading,
    this.supportingText,
    this.trailing,
  });

  final String eyebrow;
  final String heading;
  final String? supportingText;

  /// Status chip (dashboard) or primary action button (taxonomy screens).
  final Widget? trailing;

  /// Below this width the trailing action squeezes the heading down to one
  /// word per line, so it moves underneath the title block instead.
  static const double stackBelowWidth = 620;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        KhSectionLabel(eyebrow),
        SizedBox(height: kh.spacing.xxs),
        Text(heading, style: kh.typography.displayL),
        if (supportingText != null) ...[
          SizedBox(height: kh.spacing.xxs),
          Text(
            supportingText!,
            style: kh.typography.bodySmall.copyWith(
              color: kh.colors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (trailing == null) return titleBlock;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < stackBelowWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              titleBlock,
              SizedBox(height: kh.spacing.md),
              trailing!,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            SizedBox(width: kh.spacing.md),
            trailing!,
          ],
        );
      },
    );
  }
}
