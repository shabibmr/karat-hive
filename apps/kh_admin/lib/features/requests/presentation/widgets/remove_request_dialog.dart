import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Result of the remove-request dialog. Null return from
/// [showRemoveRequestDialog] means the admin cancelled.
class RemoveRequestOutcome {
  const RemoveRequestOutcome({
    required this.reasonCode,
    required this.reasonText,
    required this.policyClause,
  });

  final String reasonCode;
  final String reasonText;
  final String policyClause;
}

/// Confirmation dialog for `FR-ADM-019` request removal. Was
/// `RequestDetailScreen._showRemoveDialog` (its UI half); the actual
/// `removeRequest` call stays with the screen.
Future<RemoveRequestOutcome?> showRemoveRequestDialog(
  BuildContext context,
  RequestDetail detail,
) async {
  final kh = context.kh;
  final l10n = AppLocalizations.of(context);
  final formKey = GlobalKey<FormState>();
  var selectedReasonCode = 'POLICY_VIOLATION';
  final policyClauseController =
      TextEditingController(text: 'Terms of Service §4.2');
  final reasonController = TextEditingController();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(
        l10n?.requestsDetailRemoveDialogTitle ?? 'Remove Request',
        style: kh.typography.title,
      ),
      content: SizedBox(
        width: 480.0,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.requestsDetailRemoveDialogBody(
                      detail.reference ?? detail.id,
                    ) ??
                    'Removing "${detail.reference ?? detail.id}" sets status to REMOVED, withdraws all pending offers, and notifies both parties.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
              SizedBox(height: kh.spacing.md),
              DropdownButtonFormField<String>(
                key: const Key('remove-reason-code-field'),
                initialValue: selectedReasonCode,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText:
                      l10n?.requestsDetailRemoveReasonCode ?? 'Reason Code',
                  isDense: true,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'POLICY_VIOLATION',
                    child: Text(
                        l10n?.requestsDetailRemoveReasonPolicyViolation ??
                            'Policy violation'),
                  ),
                  DropdownMenuItem(
                    value: 'PROHIBITED_ITEM',
                    child: Text(
                        l10n?.requestsDetailRemoveReasonProhibitedItem ??
                            'Prohibited item / Contraband'),
                  ),
                  DropdownMenuItem(
                    value: 'FRAUDULENT_LISTING',
                    child: Text(l10n?.requestsDetailRemoveReasonFraudulent ??
                        'Fraudulent or misleading listing'),
                  ),
                  DropdownMenuItem(
                    value: 'CUSTOMER_REQUESTED',
                    child: Text(
                        l10n?.requestsDetailRemoveReasonCustomerRequested ??
                            'Customer requested cancellation'),
                  ),
                  DropdownMenuItem(
                    value: 'OTHER',
                    child: Text(l10n?.requestsDetailRemoveReasonOther ??
                        'Other administrative reason'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) selectedReasonCode = val;
                },
              ),
              SizedBox(height: kh.spacing.md),
              TextFormField(
                key: const Key('remove-policy-clause-field'),
                controller: policyClauseController,
                decoration: InputDecoration(
                  labelText: l10n?.requestsDetailRemovePolicyClauseLabel ??
                      'Policy Clause (cited to customer)',
                  hintText: l10n?.requestsDetailRemovePolicyClauseHint ??
                      'e.g. Terms of Service §4.2',
                  isDense: true,
                ),
              ),
              SizedBox(height: kh.spacing.md),
              TextFormField(
                key: const Key('remove-reason-text-field'),
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n?.requestsDetailRemoveJustificationLabel ??
                      'Detailed Justification & Notes',
                  hintText: l10n?.requestsDetailRemoveJustificationHint ??
                      'State reason for audit log…',
                  isDense: true,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? (l10n?.requestsDetailRemoveJustificationRequired ??
                        'Detailed justification is required.')
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(false),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          key: const Key('confirm-remove-button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kh.colors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.of(dialogCtx).pop(true);
            }
          },
          child: Text(l10n?.requestsDetailConfirmRemoval ?? 'Confirm Removal'),
        ),
      ],
    ),
  );

  if (confirmed != true) return null;
  return RemoveRequestOutcome(
    reasonCode: selectedReasonCode,
    reasonText: reasonController.text.trim(),
    policyClause: policyClauseController.text.trim(),
  );
}
