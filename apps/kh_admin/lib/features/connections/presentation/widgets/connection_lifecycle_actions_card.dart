import 'package:flutter/material.dart' hide ConnectionState;

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/connections/model/connection_detail.dart';
import 'package:kh_admin/features/connections/model/connection_enums.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_detail_formatters.dart';

/// Lifecycle-management card. Was
/// `_ConnectionDetailScreenState._buildLifecycleActionsCard` (TR-S2-14). The
/// close-connection modal stays in the screen.
class ConnectionLifecycleActionsCard extends StatelessWidget {
  const ConnectionLifecycleActionsCard({
    super.key,
    required this.detail,
    required this.onClose,
  });

  final ConnectionDetail detail;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final isClosed = detail.state == ConnectionState.closed;

    return Container(
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(
          color: kh.colors.borderSubtle,
          width: kh.shapes.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: kh.colors.goldPrimary, size: 20),
              SizedBox(width: kh.spacing.xs),
              Text('Lifecycle Management', style: kh.typography.title),
            ],
          ),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.lg * 2),
          if (isClosed) ...[
            Container(
              padding: EdgeInsets.all(kh.spacing.md),
              decoration: BoxDecoration(
                color: kh.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kh.colors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline, color: kh.colors.error, size: 18),
                      SizedBox(width: kh.spacing.xs),
                      Text(
                        'Connection Closed',
                        style: kh.typography.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kh.colors.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: kh.spacing.xs),
                  Text(
                    'Closed on ${connectionFormatDate(detail.closedAt)}${detail.closedBy != null ? " by ${detail.closedBy}" : ""}.',
                    style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'If the introduction has failed, unfulfilled commitments were made, or an abusive interaction was reported, administrators may terminate the connection.',
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
            ),
            SizedBox(height: kh.spacing.md),
            FilledButton.icon(
              key: const Key('close-connection-button'),
              style: FilledButton.styleFrom(
                backgroundColor: kh.colors.error,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Close Connection'),
            ),
          ],
        ],
      ),
    );
  }
}
