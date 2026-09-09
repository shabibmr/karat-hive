import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Error state for the audit log. Was `_AuditScreenState._buildErrorView`
/// (TR-S2-13).
class AuditErrorView extends StatelessWidget {
  const AuditErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;

    return Container(
      key: const Key('audit-error-view'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.error),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Text(
              'Failed to load audit trail: $error',
              style: kh.typography.body.copyWith(color: colors.error),
            ),
          ),
          SizedBox(width: kh.spacing.md),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
