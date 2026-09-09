import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Banner reminding operators that audit log views are self-audited. Was the
/// private `_SelfViewAuditNotice` in `audit_screen.dart` (TR-S2-13).
class AuditSelfViewNotice extends StatelessWidget {
  const AuditSelfViewNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;

    return Container(
      key: const Key('audit-self-view-notice'),
      padding: EdgeInsets.symmetric(
        horizontal: kh.spacing.md,
        vertical: kh.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.accentHighlight.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(
          color: colors.accentHighlight.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: colors.accentHighlight,
          ),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Text(
              'Audit access log: Viewing this log generates an immutable AUDIT_VIEWED entry.',
              style: kh.typography.bodySmall.copyWith(
                color: colors.accentHighlight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
