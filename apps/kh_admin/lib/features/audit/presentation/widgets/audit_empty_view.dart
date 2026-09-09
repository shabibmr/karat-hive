import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Empty state for the audit log. Was `_AuditScreenState._buildEmptyView`
/// (TR-S2-13).
class AuditEmptyView extends StatelessWidget {
  const AuditEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Center(
      key: const Key('audit-empty-view'),
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.shield_outlined,
              size: 48,
              color: kh.colors.textMuted,
            ),
            SizedBox(height: kh.spacing.md),
            Text(
              'No audit records found',
              style: kh.typography.title,
            ),
            SizedBox(height: kh.spacing.xs),
            Text(
              'No log events match your current filter criteria.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
