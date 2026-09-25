import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';

/// Editable Type Subscription ("Services") card for ADM-S06 — lets an admin
/// grant or revoke a Vendor's per-`RequestType` entitlement post-approval
/// (`FR-VEN-031`, `BR-002`). Verification alone does not grant a Vendor any
/// Request type; this is the only place that can be changed after approval.
class VendorServicesCard extends StatelessWidget {
  const VendorServicesCard({
    super.key,
    required this.detail,
    required this.isBusy,
    required this.onGrant,
    required this.onRevoke,
  });

  final VendorDetail detail;
  final bool isBusy;
  final ValueChanged<RequestType> onGrant;
  final void Function(RequestType type, String reasonText) onRevoke;

  Future<void> _confirmRevoke(BuildContext context, KhThemeExtension kh, RequestType type) async {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Revoke ${type.label}', style: kh.typography.title),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This vendor will no longer be matched against "${type.label}" requests.',
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
                ),
                SizedBox(height: kh.spacing.md),
                TextFormField(
                  key: const Key('revoke-subscription-reason-field'),
                  controller: reasonController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Why is this entitlement being revoked?',
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Reason is required.' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm-revoke-subscription-button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kh.colors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onRevoke(type, reasonController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final entitled = detail.entitledTypes;

    return Container(
      key: const Key('vendor-services-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('Services'),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Request types this vendor is entitled to receive Offers on (BR-002).',
            style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
          ),
          SizedBox(height: kh.spacing.md),
          Wrap(
            spacing: kh.spacing.sm,
            runSpacing: kh.spacing.xs,
            children: [
              for (final type in RequestType.values)
                FilterChip(
                  key: Key('service-chip-${type.apiValue}'),
                  label: Text(type.label),
                  selected: entitled.contains(type),
                  onSelected: isBusy
                      ? null
                      : (selected) {
                          if (selected) {
                            onGrant(type);
                          } else {
                            _confirmRevoke(context, kh, type);
                          }
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
