import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_feedback_banner.dart';
import 'package:kh_admin/features/vendors/controller/vendor_detail_controller.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_detail_error_view.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_detail_formatters.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_detail_header.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_kyc_documents_card.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_lifecycle_actions_card.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_profile_card.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_taxonomy_card.dart';

/// ADM-S06 · Vendor detail — full business profile, KYC document inspection,
/// taxonomy subscriptions, and admin lifecycle controls (suspend, reactivate, deactivate).
///
/// Composition root only: each section lives in `presentation/widgets/`
/// (TR-S2-10). Screen state owns the lifecycle-action dialogs and feedback.
class VendorDetailScreen extends ConsumerStatefulWidget {
  const VendorDetailScreen({
    super.key,
    required this.vendorId,
    this.verificationState,
  });

  final String vendorId;
  final VendorVerificationState? verificationState;

  @override
  ConsumerState<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends ConsumerState<VendorDetailScreen> {
  bool _isProcessingAction = false;
  String? _actionFeedback;
  bool _actionSuccess = true;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final detailAsync = ref.watch(vendorDetailControllerProvider(widget.vendorId));

    return Material(
      color: kh.colors.backgroundSurface,
      child: detailAsync.when(
        loading: () => const Center(
          key: Key('vendor-detail-loading'),
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => SingleChildScrollView(
          padding: EdgeInsets.all(kh.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VendorDetailBackButton(),
              SizedBox(height: kh.spacing.lg),
              VendorDetailErrorView(
                message: err.toString(),
                onRetry: () => ref
                    .read(vendorDetailControllerProvider(widget.vendorId).notifier)
                    .reload(),
              ),
            ],
          ),
        ),
        data: (detail) => SingleChildScrollView(
          padding: EdgeInsets.all(kh.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VendorDetailBackButton(),
              SizedBox(height: kh.spacing.md),
              VendorDetailHeader(detail: detail),
              if (_actionFeedback != null) ...[
                SizedBox(height: kh.spacing.md),
                KhFeedbackBanner(
                  key: const Key('vendor-action-feedback-banner'),
                  message: _actionFeedback!,
                  isSuccess: _actionSuccess,
                  onDismiss: () => setState(() => _actionFeedback = null),
                ),
              ],
              SizedBox(height: kh.spacing.xl),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final lifecycleCard = VendorLifecycleActionsCard(
                    detail: detail,
                    isProcessing: _isProcessingAction,
                    onSuspend: () => _promptSuspendDialog(context, kh, detail),
                    onReactivate: () =>
                        _promptReactivateDialog(context, kh, detail),
                    onDeactivate: () =>
                        _promptDeactivateDialog(context, kh, detail),
                  );
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              VendorProfileCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              VendorTaxonomyCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              VendorKycDocumentsCard(detail: detail),
                            ],
                          ),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          flex: 2,
                          child: lifecycleCard,
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      VendorProfileCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      VendorTaxonomyCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      VendorKycDocumentsCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      lifecycleCard,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dialogs ---

  Future<void> _promptSuspendDialog(
    BuildContext context,
    KhThemeExtension kh,
    VendorDetail detail,
  ) async {
    final formKey = GlobalKey<FormState>();
    var selectedReasonCode = 'COMPLIANCE_BREACH';
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Suspend Vendor Account', style: kh.typography.title),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suspending ${detail.legalBusinessName} will block login and all new matching activity.',
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
                ),
                SizedBox(height: kh.spacing.md),
                DropdownButtonFormField<String>(
                  key: const Key('suspend-reason-code-field'),
                  initialValue: selectedReasonCode,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Reason Code',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'COMPLIANCE_BREACH',
                      child: Text('Compliance breach / Document issue'),
                    ),
                    DropdownMenuItem(
                      value: 'CUSTOMER_COMPLAINT',
                      child: Text('Multiple Customer Complaints'),
                    ),
                    DropdownMenuItem(
                      value: 'SUSPICIOUS_ACTIVITY',
                      child: Text('Suspicious Transaction Activity'),
                    ),
                    DropdownMenuItem(
                      value: 'ADMIN_DISCRETION',
                      child: Text('Administrative Discretion'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedReasonCode = val;
                  },
                ),
                SizedBox(height: kh.spacing.md),
                TextFormField(
                  key: const Key('suspend-reason-text-field'),
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Rationale & Notes',
                    hintText: 'Provide detailed justification for suspension…',
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Rationale is required.' : null,
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
            key: const Key('confirm-suspend-button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kh.colors.warning,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: const Text('Confirm Suspension'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeLifecycleAction(
        actionName: 'suspend',
        task: () => ref
            .read(vendorDetailControllerProvider(detail.id).notifier)
            .suspendVendor(
              reasonCode: selectedReasonCode,
              reasonText: reasonController.text.trim(),
            ),
        successMessage: 'Vendor account suspended successfully.',
      );
    }
  }

  Future<void> _promptReactivateDialog(
    BuildContext context,
    KhThemeExtension kh,
    VendorDetail detail,
  ) async {
    // 1. Confirm unexpired KYC rule
    if (detail.isLicenceExpired) {
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: kh.colors.error, size: 24),
              SizedBox(width: kh.spacing.xs),
              Text('Cannot Reactivate Vendor', style: kh.typography.title),
            ],
          ),
          content: Text(
            'The trade licence for ${detail.legalBusinessName} expired on ${vendorFormatDate(detail.licenceExpiryDate)}.\n\nPer platform policy (FR-ADM-016), a suspended vendor cannot be reactivated with an expired KYC trade licence. The vendor must submit updated documents before reactivation.',
            style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Unexpired KYC confirmed — prompt reactivation confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Confirm Vendor Reactivation', style: kh.typography.title),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reactivating ${detail.legalBusinessName} will restore their login and permit participation in matching requests.',
                style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
              ),
              SizedBox(height: kh.spacing.md),
              Container(
                padding: EdgeInsets.all(kh.spacing.sm),
                decoration: BoxDecoration(
                  color: kh.colors.success.withValues(alpha: 0.1),
                  borderRadius: kh.shapes.roundedMd,
                  border: Border.all(color: kh.colors.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_outlined, color: kh.colors.success, size: 20),
                    SizedBox(width: kh.spacing.xs),
                    Expanded(
                      child: Text(
                        'KYC Trade Licence is valid until ${vendorFormatDate(detail.licenceExpiryDate)}.',
                        style: kh.typography.caption.copyWith(
                          color: kh.colors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm-reactivate-button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kh.colors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Reactivate Vendor'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeLifecycleAction(
        actionName: 'reactivate',
        task: () => ref
            .read(vendorDetailControllerProvider(detail.id).notifier)
            .reactivateVendor(
              reasonCode: 'KYC_CONFIRMED',
              reasonText: 'Trade licence verified valid until ${vendorFormatDate(detail.licenceExpiryDate)}',
            ),
        successMessage: 'Vendor account reactivated successfully.',
      );
    }
  }

  Future<void> _promptDeactivateDialog(
    BuildContext context,
    KhThemeExtension kh,
    VendorDetail detail,
  ) async {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: kh.colors.error, size: 24),
            SizedBox(width: kh.spacing.xs),
            Text('Deactivate Vendor Account', style: kh.typography.title),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(kh.spacing.sm),
                  decoration: BoxDecoration(
                    color: kh.colors.error.withValues(alpha: 0.12),
                    borderRadius: kh.shapes.roundedMd,
                    border: Border.all(color: kh.colors.error.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'TERMINAL TRANSITION WARNING: Deactivation is irreversible. The vendor will be permanently eliminated from request matching and will lose access to the portal.',
                    style: kh.typography.caption.copyWith(
                      color: kh.colors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                TextFormField(
                  key: const Key('deactivate-reason-text-field'),
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deactivation Reason',
                    hintText: 'Document the permanent closure reason…',
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Reason is required for audit.' : null,
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
            key: const Key('confirm-deactivate-button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kh.colors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: const Text('Confirm Permanent Deactivation'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeLifecycleAction(
        actionName: 'deactivate',
        task: () => ref
            .read(vendorDetailControllerProvider(detail.id).notifier)
            .deactivateVendor(
              reasonCode: 'TERMINAL_CLOSURE',
              reasonText: reasonController.text.trim(),
            ),
        successMessage: 'Vendor account permanently deactivated.',
      );
    }
  }

  Future<void> _executeLifecycleAction({
    required String actionName,
    required Future<void> Function() task,
    required String successMessage,
  }) async {
    setState(() {
      _isProcessingAction = true;
      _actionFeedback = null;
    });

    try {
      await task();
      if (mounted) {
        setState(() {
          _isProcessingAction = false;
          _actionSuccess = true;
          _actionFeedback = successMessage;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingAction = false;
          _actionSuccess = false;
          _actionFeedback = 'Failed to $actionName vendor: $e';
        });
      }
    }
  }
}
