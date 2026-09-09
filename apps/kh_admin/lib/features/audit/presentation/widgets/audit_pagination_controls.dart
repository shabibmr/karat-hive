import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/audit/controller/audit_controller.dart';

/// Pagination row under the audit table. Was
/// `_AuditScreenState._buildPaginationControls` (TR-S2-13).
class AuditPaginationControls extends StatelessWidget {
  const AuditPaginationControls({
    super.key,
    required this.state,
    required this.controller,
  });

  final AuditState state;
  final AuditController controller;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page ${state.page} · Showing ${state.items.length} records',
          style: kh.typography.bodySmall.copyWith(
            color: kh.colors.textSecondary,
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              key: const Key('audit-prev-page-button'),
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('Previous'),
              onPressed: state.canGoPrevious ? controller.previousPage : null,
            ),
            SizedBox(width: kh.spacing.sm),
            OutlinedButton.icon(
              key: const Key('audit-next-page-button'),
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text('Next'),
              onPressed: state.canGoNext ? controller.nextPage : null,
            ),
          ],
        ),
      ],
    );
  }
}
