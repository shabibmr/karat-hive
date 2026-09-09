import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';

/// Account-lifecycle controls card. Was
/// `_CustomerDetailScreenState._buildLifecycleActionsCard` (TR-S2-12). Dialogs
/// and controller calls stay in the screen.
class CustomerLifecycleActionsCard extends StatelessWidget {
  const CustomerLifecycleActionsCard({
    super.key,
    required this.detail,
    required this.isProcessing,
    required this.onReactivate,
    required this.onSuspend,
    required this.onErasure,
  });

  final CustomerDetail detail;
  final bool isProcessing;
  final VoidCallback onReactivate;
  final VoidCallback onSuspend;
  final VoidCallback onErasure;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final isSuspended = detail.accountState == CustomerAccountState.suspended;
    final isDeactivated =
        detail.accountState == CustomerAccountState.deactivated;

    return Container(
      key: const Key('customer-lifecycle-card'),
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
          const KhSectionLabel('ADMIN ACTIONS'),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Account Lifecycle Controls',
            style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Administrative actions modify account access and are logged to the platform audit trail.',
            style: kh.typography.caption.copyWith(color: kh.colors.textSecondary),
          ),
          SizedBox(height: kh.spacing.lg),
          if (isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            if (isSuspended)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('customer-reactivate-button'),
                  onPressed: onReactivate,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reactivate Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kh.colors.success,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: kh.spacing.sm),
                  ),
                ),
              )
            else if (!isDeactivated)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('customer-suspend-button'),
                  onPressed: onSuspend,
                  icon: const Icon(Icons.block, size: 18),
                  label: const Text('Suspend Customer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kh.colors.warning,
                    side: BorderSide(color: kh.colors.warning),
                    padding: EdgeInsets.symmetric(vertical: kh.spacing.sm),
                  ),
                ),
              ),
            SizedBox(height: kh.spacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('customer-erasure-button'),
                onPressed: onErasure,
                icon: const Icon(Icons.delete_forever, size: 18),
                label: const Text('Request data erasure'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kh.colors.error,
                  side: BorderSide(color: kh.colors.error),
                  padding: EdgeInsets.symmetric(vertical: kh.spacing.sm),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
