import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_feedback_banner.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/vendors/controller/vendor_detail_controller.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';

/// ADM-S06 · Vendor detail — full business profile, KYC document inspection,
/// taxonomy subscriptions, and admin lifecycle controls (suspend, reactivate, deactivate).
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
    final l10n = AppLocalizations.of(context);
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
              _buildBackButton(context, kh),
              SizedBox(height: kh.spacing.lg),
              _buildErrorView(
                context,
                kh,
                l10n,
                err.toString(),
                () => ref
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
              _buildBackButton(context, kh),
              SizedBox(height: kh.spacing.md),
              _buildHeader(context, kh, l10n, detail),
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
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProfileCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildTaxonomyCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildKycDocumentsCard(kh, detail),
                            ],
                          ),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          flex: 2,
                          child: _buildLifecycleActionsCard(context, kh, detail),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildTaxonomyCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildKycDocumentsCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildLifecycleActionsCard(context, kh, detail),
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

  Widget _buildBackButton(BuildContext context, KhThemeExtension kh) {
    return TextButton.icon(
      key: const Key('vendor-detail-back-button'),
      onPressed: () => context.go('/vendors'),
      icon: const Icon(Icons.arrow_back, size: 18),
      label: const Text('Back to Vendors'),
      style: TextButton.styleFrom(
        foregroundColor: kh.colors.goldPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: kh.spacing.sm,
          vertical: kh.spacing.xs,
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    KhThemeExtension kh,
    AppLocalizations? l10n,
    VendorDetail detail,
  ) {
    return KhScreenHeader(
      eyebrow: detail.tradingName != null && detail.tradingName!.isNotEmpty
          ? '${detail.tradingName!.toUpperCase()} · ${detail.id}'
          : 'VENDOR ID: ${detail.id}',
      heading: detail.legalBusinessName,
      supportingText: 'Registered business profile & admin lifecycle controls',
      trailing: Wrap(
        spacing: kh.spacing.xs,
        runSpacing: kh.spacing.xs,
        children: [
          KhStatusChip(
            label: _verificationLabel(l10n, detail.verificationState),
            tone: _verificationTone(detail.verificationState),
          ),
          KhStatusChip(
            label: _accountLabel(l10n, detail.accountState),
            tone: _accountTone(detail.accountState),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(KhThemeExtension kh, VendorDetail detail) {
    final isExpired = detail.isLicenceExpired;
    final expiryFormatted = _formatDate(detail.licenceExpiryDate);

    return Container(
      key: const Key('vendor-profile-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('Business Profile'),
          SizedBox(height: kh.spacing.md),
          _buildFieldRow(kh, 'Legal Business Name', detail.legalBusinessName),
          _buildFieldRow(kh, 'Trading Name', detail.tradingName ?? '—'),
          _buildFieldRow(
            kh,
            'Trade Licence Number',
            detail.tradeLicenceNumber,
            badge: isExpired
                ? KhStatusChip(label: 'EXPIRED', tone: KhStatusTone.error, dense: true)
                : KhStatusChip(label: 'VALID', tone: KhStatusTone.success, dense: true),
          ),
          _buildFieldRow(kh, 'Licence Expiry Date', expiryFormatted),
          _buildFieldRow(kh, 'Primary Address', detail.businessAddress),
          _buildFieldRow(kh, 'Authorised Contact Person', detail.contactPersonName),
          _buildFieldRow(kh, 'Business Email', detail.businessEmail),
          _buildFieldRow(kh, 'Mobile Number', detail.mobileNumber ?? '—'),
          if (detail.submittedAt != null)
            _buildFieldRow(kh, 'Registration Date', _formatDate(detail.submittedAt!)),
        ],
      ),
    );
  }

  Widget _buildFieldRow(
    KhThemeExtension kh,
    String label,
    String value, {
    Widget? badge,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: kh.spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(
              label,
              style: kh.typography.caption.copyWith(
                color: kh.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: kh.typography.bodySmall.copyWith(
                      color: kh.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  SizedBox(width: kh.spacing.xs),
                  badge,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxonomyCard(KhThemeExtension kh, VendorDetail detail) {
    return Container(
      key: const Key('vendor-taxonomy-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('Taxonomy & Coverage'),
          SizedBox(height: kh.spacing.md),
          Text(
            'Categories Served',
            style: kh.typography.caption.copyWith(
              color: kh.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: kh.spacing.xs),
          if (detail.categories.isEmpty)
            Text(
              'No categories declared.',
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
            )
          else
            Wrap(
              spacing: kh.spacing.xs,
              runSpacing: kh.spacing.xs,
              children: [
                for (final category in detail.categories)
                  Container(
                    key: Key('category-chip-$category'),
                    padding: EdgeInsets.symmetric(
                      horizontal: kh.spacing.sm,
                      vertical: kh.spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: kh.colors.goldPrimary.withValues(alpha: 0.1),
                      borderRadius: kh.shapes.pill,
                      border: Border.all(
                        color: kh.colors.goldPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      category,
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.goldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          SizedBox(height: kh.spacing.md),
          Text(
            'Regions Served',
            style: kh.typography.caption.copyWith(
              color: kh.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: kh.spacing.xs),
          if (detail.regions.isEmpty)
            Text(
              'No regions declared.',
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
            )
          else
            Wrap(
              spacing: kh.spacing.xs,
              runSpacing: kh.spacing.xs,
              children: [
                for (final region in detail.regions)
                  Container(
                    key: Key('region-chip-$region'),
                    padding: EdgeInsets.symmetric(
                      horizontal: kh.spacing.sm,
                      vertical: kh.spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: kh.colors.borderSubtle.withValues(alpha: 0.3),
                      borderRadius: kh.shapes.pill,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Text(
                      region,
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildKycDocumentsCard(KhThemeExtension kh, VendorDetail detail) {
    return Container(
      key: const Key('vendor-kyc-documents-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const KhSectionLabel('KYC Documents'),
              Text(
                '${detail.documents.length} Uploaded',
                style: kh.typography.caption.copyWith(
                  color: kh.colors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          if (detail.documents.isEmpty)
            Padding(
              padding: EdgeInsets.all(kh.spacing.md),
              child: Center(
                child: Text(
                  'No KYC documents uploaded for this vendor.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textMuted,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                for (final doc in detail.documents)
                  Container(
                    key: Key('vendor-doc-${doc.id}'),
                    margin: EdgeInsets.only(bottom: kh.spacing.sm),
                    padding: EdgeInsets.all(kh.spacing.md),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundSurface,
                      borderRadius: kh.shapes.roundedMd,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: kh.colors.goldPrimary,
                          size: 28,
                        ),
                        SizedBox(width: kh.spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.documentType.replaceAll('_', ' ').toUpperCase(),
                                style: kh.typography.caption.copyWith(
                                  color: kh.colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (doc.fileName != null)
                                Text(
                                  doc.fileName!,
                                  style: kh.typography.caption.copyWith(
                                    color: kh.colors.textSecondary,
                                  ),
                                ),
                              Text(
                                'Uploaded: ${_formatDate(doc.uploadedAt)}${doc.expiryDate != null ? ' · Expires: ${_formatDate(doc.expiryDate!)}' : ''}',
                                style: kh.typography.caption.copyWith(
                                  color: kh.colors.textMuted,
                                  fontSize: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        KhStatusChip(
                          label: doc.verified ? 'VERIFIED' : 'PENDING',
                          tone: doc.verified
                              ? KhStatusTone.success
                              : KhStatusTone.pending,
                          dense: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLifecycleActionsCard(
    BuildContext context,
    KhThemeExtension kh,
    VendorDetail detail,
  ) {
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
          if (_isProcessingAction)
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
                  onPressed: () => _promptSuspendDialog(context, kh, detail),
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
                  onPressed: () => _promptReactivateDialog(context, kh, detail),
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
                  onPressed: () => _promptDeactivateDialog(context, kh, detail),
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
            'The trade licence for ${detail.legalBusinessName} expired on ${_formatDate(detail.licenceExpiryDate)}.\n\nPer platform policy (FR-ADM-016), a suspended vendor cannot be reactivated with an expired KYC trade licence. The vendor must submit updated documents before reactivation.',
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
                        'KYC Trade Licence is valid until ${_formatDate(detail.licenceExpiryDate)}.',
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
              reasonText: 'Trade licence verified valid until ${_formatDate(detail.licenceExpiryDate)}',
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

  Widget _buildErrorView(
    BuildContext context,
    KhThemeExtension kh,
    AppLocalizations? l10n,
    String message,
    VoidCallback onRetry,
  ) {
    return Container(
      key: const Key('vendor-detail-error-view'),
      width: double.infinity,
      padding: EdgeInsets.all(kh.spacing.xl),
      decoration: BoxDecoration(
        color: kh.colors.error.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            'Unable to load vendor profile',
            style: kh.typography.title.copyWith(color: kh.colors.error),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
          ),
          SizedBox(height: kh.spacing.md),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _verificationLabel(AppLocalizations? l10n, VendorVerificationState state) {
    switch (state) {
      case VendorVerificationState.registered:
        return l10n?.vendorsVerificationRegistered ?? 'REGISTERED';
      case VendorVerificationState.pendingVerification:
        return l10n?.vendorsVerificationPending ?? 'PENDING VERIFICATION';
      case VendorVerificationState.verified:
        return l10n?.vendorsVerificationVerified ?? 'VERIFIED';
      case VendorVerificationState.rejected:
        return l10n?.vendorsVerificationRejected ?? 'REJECTED';
    }
  }

  String _accountLabel(AppLocalizations? l10n, VendorAccountState state) {
    switch (state) {
      case VendorAccountState.active:
        return l10n?.vendorsAccountActive ?? 'ACTIVE';
      case VendorAccountState.suspended:
        return l10n?.vendorsAccountSuspended ?? 'SUSPENDED';
      case VendorAccountState.deactivated:
        return l10n?.vendorsAccountDeactivated ?? 'DEACTIVATED';
    }
  }

  KhStatusTone _verificationTone(VendorVerificationState state) {
    switch (state) {
      case VendorVerificationState.verified:
        return KhStatusTone.success;
      case VendorVerificationState.pendingVerification:
        return KhStatusTone.pending;
      case VendorVerificationState.rejected:
        return KhStatusTone.error;
      case VendorVerificationState.registered:
        return KhStatusTone.neutral;
    }
  }

  KhStatusTone _accountTone(VendorAccountState state) {
    switch (state) {
      case VendorAccountState.active:
        return KhStatusTone.success;
      case VendorAccountState.suspended:
        return KhStatusTone.pending;
      case VendorAccountState.deactivated:
        return KhStatusTone.error;
    }
  }
}
