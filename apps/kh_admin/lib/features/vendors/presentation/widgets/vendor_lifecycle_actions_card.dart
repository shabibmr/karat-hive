import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';

/// Account-lifecycle controls card. Was
/// `_VendorDetailScreenState._buildLifecycleActionsCard` (TR-S2-10). The
/// dialogs and controller calls stay in the screen; this widget only renders
/// the buttons and invokes the callbacks.
class VendorLifecycleActionsCard extends StatelessWidget {
  const VendorLifecycleActionsCard({
    super.key,
    required this.detail,
    required this.isProcessing,
    required this.onSuspend,
    required this.onReactivate,
    required this.onDeactivate,
  });

  final VendorDetail detail;
  final bool isProcessing;
  final VoidCallback onSuspend;
  final VoidCallback onReactivate;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final isActive = detail.accountState == VendorAccountState.active;
    final isSuspended = detail.accountState == VendorAccountState.suspended;
    final isDeactivated = detail.accountState == VendorAccountState.deactivated;

    return Container(
      key: const Key('vendor-lifecycle-actions-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('Account Lifecycle'),
          SizedBox(height: kh.spacing.sm),
          Text(
            'Admin state transitions require a documented reason code, are recorded in the immutable audit log, and notify the vendor.',
            style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
          ),
          SizedBox(height: kh.spacing.lg),
          if (isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // 1. Suspend Vendor (if ACTIVE)
            if (isActive) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('vendor-suspend-button'),
                  onPressed: onSuspend,
                  icon: const Icon(Icons.pause_circle_outline, size: 18),
                  label: const Text('Suspend Vendor'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kh.colors.warning,
                    side: BorderSide(color: kh.colors.warning.withValues(alpha: 0.7)),
                    padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
                  ),
                ),
              ),
              SizedBox(height: kh.spacing.xs),
              Text(
                'Immediately blocks new requests and offers; active connections remain open.',
                style: kh.typography.caption.copyWith(color: kh.colors.textMuted, fontSize: 10.0),
              ),
              SizedBox(height: kh.spacing.md),
            ],

            // 2. Reactivate Vendor (if SUSPENDED)
            if (isSuspended) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('vendor-reactivate-button'),
                  onPressed: onReactivate,
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Reactivate Vendor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kh.colors.success,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
                  ),
                ),
              ),
              SizedBox(height: kh.spacing.xs),
              Text(
                'Restores full marketplace access without re-verification if KYC trade licence is unexpired.',
                style: kh.typography.caption.copyWith(color: kh.colors.textMuted, fontSize: 10.0),
              ),
              SizedBox(height: kh.spacing.md),
            ],

            // 3. Deactivate Vendor (unless already DEACTIVATED)
            if (!isDeactivated) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('vendor-deactivate-button'),
                  onPressed: onDeactivate,
                  icon: const Icon(Icons.delete_forever_outlined, size: 18),
                  label: const Text('Deactivate Vendor'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kh.colors.error,
                    side: BorderSide(color: kh.colors.error.withValues(alpha: 0.6)),
                    padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
                  ),
                ),
              ),
              SizedBox(height: kh.spacing.xs),
              Text(
                'Permanent, terminal action. Vendor is removed from future matching and cannot be reinstated.',
                style: kh.typography.caption.copyWith(color: kh.colors.textMuted, fontSize: 10.0),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(kh.spacing.md),
                decoration: BoxDecoration(
                  color: kh.colors.error.withValues(alpha: 0.1),
                  borderRadius: kh.shapes.roundedMd,
                  border: Border.all(color: kh.colors.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.block, color: kh.colors.error, size: 18),
                    SizedBox(width: kh.spacing.xs),
                    Expanded(
                      child: Text(
                        'This vendor account is permanently deactivated.',
                        style: kh.typography.caption.copyWith(
                          color: kh.colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
