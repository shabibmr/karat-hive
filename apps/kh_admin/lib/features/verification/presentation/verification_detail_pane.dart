import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/design/theme/kh_theme.dart';
import '../../../core/design/widgets/kh_status_chip.dart';
import '../../../core/platform/open_url.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/verification_controller.dart';
import '../model/vendor_verification_detail.dart';
import '../repository/verification_repository.dart';
import 'verification_dialogs.dart';

/// Right-hand detail pane for ADM-S07 displaying vendor credentials,
/// uploaded KYC documents with signed URL viewer, and verification actions.
class VerificationDetailPane extends ConsumerStatefulWidget {
  const VerificationDetailPane({
    super.key,
    required this.vendorId,
    this.onDecisionMade,
  });

  final String? vendorId;
  final VoidCallback? onDecisionMade;

  @override
  ConsumerState<VerificationDetailPane> createState() =>
      _VerificationDetailPaneState();
}

class _VerificationDetailPaneState
    extends ConsumerState<VerificationDetailPane> {
  String? _loadingDocId;
  String? _docError;
  String? _openedDocId;
  String? _openedDocUrl;

  String _formatDocType(AppLocalizations? l10n, String type) {
    return switch (type) {
      'TRADE_LICENCE' => l10n?.documentTypeTradeLicence ?? 'Trade Licence',
      'EMIRATES_ID' => l10n?.documentTypeEmiratesId ?? 'Emirates ID',
      'VAT_CERT' => l10n?.documentTypeVatCert ?? 'VAT Certificate',
      'TRADING_PERMIT' => l10n?.documentTypeTradingPermit ?? 'Trading Permit',
      'TENANCY' => l10n?.documentTypeTenancy ?? 'Tenancy Contract',
      _ => type.replaceAll('_', ' '),
    };
  }

  Future<void> _viewDocument(VendorDocumentDetail doc) async {
    if (widget.vendorId == null) return;
    setState(() {
      _loadingDocId = doc.id;
      _docError = null;
    });

    try {
      final repository = ref.read(verificationRepositoryProvider);
      final res = await repository.fetchDocumentUrl(
        vendorId: widget.vendorId!,
        documentId: doc.id,
      );

      if (mounted) {
        setState(() {
          _loadingDocId = null;
          _openedDocId = doc.id;
          _openedDocUrl = res.url;
        });
        openUrlInNewTab(res.url);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingDocId = null;
          _docError = e is ApiException ? e.message : e.toString();
        });
      }
    }
  }

  Future<void> _onApproveTapped(VendorVerificationDetail detail) async {
    final success = await showApproveVerificationDialog(
      context: context,
      vendorId: detail.id,
      vendorName: detail.legalBusinessName,
    );
    if (success == true && mounted) {
      widget.onDecisionMade?.call();
    }
  }

  Future<void> _onRejectTapped(VendorVerificationDetail detail) async {
    final success = await showRejectVerificationDialog(
      context: context,
      vendorId: detail.id,
      vendorName: detail.legalBusinessName,
    );
    if (success == true && mounted) {
      widget.onDecisionMade?.call();
    }
  }

  Future<void> _onRequestInfoTapped(VendorVerificationDetail detail) async {
    final success = await showRequestInfoDialog(
      context: context,
      vendorId: detail.id,
      vendorName: detail.legalBusinessName,
    );
    if (success == true && mounted) {
      widget.onDecisionMade?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    if (widget.vendorId == null || widget.vendorId!.isEmpty) {
      return Center(
        key: const Key('verification-no-selection'),
        child: Container(
          padding: EdgeInsets.all(spacing.xxl),
          decoration: BoxDecoration(
            color: colors.backgroundElevated,
            borderRadius: shapes.roundedMd,
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, size: 48, color: colors.goldPrimary),
              SizedBox(height: spacing.md),
              Text(
                'No Vendor Selected',
                style: typography.title.copyWith(color: colors.cream100),
              ),
              SizedBox(height: spacing.xs),
              Text(
                'Select a vendor from the queue to view their profile, inspect documents, and make a decision.',
                textAlign: TextAlign.center,
                style: typography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final detailAsync =
        ref.watch(verificationDetailControllerProvider(widget.vendorId!));

    return detailAsync.when(
      loading: () => const Center(
        key: Key('verification-detail-loading'),
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        key: const Key('verification-detail-error'),
        child: Container(
          padding: EdgeInsets.all(spacing.xl),
          decoration: BoxDecoration(
            color: colors.backgroundElevated,
            borderRadius: shapes.roundedMd,
            border: Border.all(color: colors.error.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40, color: colors.error),
              SizedBox(height: spacing.sm),
              Text(
                'Failed to load vendor details',
                style: typography.title.copyWith(color: colors.cream100),
              ),
              SizedBox(height: spacing.xs),
              Text(
                error.toString(),
                style: typography.bodySmall.copyWith(color: colors.textMuted),
              ),
              SizedBox(height: spacing.md),
              OutlinedButton(
                onPressed: () {
                  ref
                      .read(verificationDetailControllerProvider(widget.vendorId!)
                          .notifier)
                      .reload();
                },
                child: Text(l10n?.tryAgain ?? 'Try Again'),
              ),
            ],
          ),
        ),
      ),
      data: (detail) {
        final dateFormat = DateFormat.yMMMd();

        return Container(
          key: Key('verification-detail-pane-${detail.id}'),
          decoration: BoxDecoration(
            color: colors.backgroundElevated,
            borderRadius: shapes.roundedMd,
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Panel header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.lg,
                  vertical: spacing.md,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.borderSubtle)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.legalBusinessName,
                            style: typography.title.copyWith(
                              color: colors.cream100,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (detail.tradingName != null &&
                              detail.tradingName!.isNotEmpty)
                            Text(
                              detail.tradingName!,
                              style: typography.caption
                                  .copyWith(color: colors.goldPrimary),
                            ),
                        ],
                      ),
                    ),
                    KhStatusChip(
                      label: l10n?.statusPendingVerification ?? 'PENDING',
                      tone: KhStatusTone.pending,
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Business Profile Section
                      _buildProfileSection(context, detail, dateFormat, l10n),
                      SizedBox(height: spacing.lg),

                      // Uploaded KYC Documents Section
                      _buildDocumentsSection(context, detail, l10n),
                    ],
                  ),
                ),
              ),

              // Bottom Actions Bar
              Container(
                padding: EdgeInsets.all(spacing.lg),
                decoration: BoxDecoration(
                  color: colors.sapphire900.withValues(alpha: 0.5),
                  border: Border(top: BorderSide(color: colors.borderSubtle)),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(shapes.roundedMd.bottomLeft.x),
                  ),
                ),
                child: Wrap(
                  spacing: spacing.md,
                  runSpacing: spacing.sm,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Request More Info: outline/neutral tone
                    OutlinedButton.icon(
                      key: const Key('verification-request-info-button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.cream100,
                        side: BorderSide(color: colors.borderStandard),
                      ),
                      onPressed: () => _onRequestInfoTapped(detail),
                      icon: const Icon(Icons.mail_outline, size: 18),
                      label: Text(
                        l10n?.requestInfoButton ?? 'Request More Info',
                      ),
                    ),

                    // Reject Verification: error/danger tone
                    ElevatedButton.icon(
                      key: const Key('verification-reject-button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: colors.cream100,
                      ),
                      onPressed: () => _onRejectTapped(detail),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(
                        l10n?.rejectVendorButton ?? 'Reject Verification',
                      ),
                    ),

                    // Approve Verification: success tone
                    ElevatedButton.icon(
                      key: const Key('verification-approve-button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.success,
                        foregroundColor: colors.cream100,
                      ),
                      onPressed: () => _onApproveTapped(detail),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(
                        l10n?.confirmApprove ?? 'Approve Verification',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    VendorVerificationDetail detail,
    DateFormat dateFormat,
    AppLocalizations? l10n,
  ) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colors.sapphire700.withValues(alpha: 0.3),
        borderRadius: shapes.roundedSm,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.business, size: 18, color: colors.goldPrimary),
              SizedBox(width: spacing.xs),
              Text(
                l10n?.declaredBusinessProfile ?? 'Declared Business Profile',
                style: typography.label.copyWith(
                  color: colors.goldPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          _ProfileRow(
            label: l10n?.legalNameLabel ?? 'Legal Name',
            value: detail.legalBusinessName,
          ),
          _ProfileRow(
            label: l10n?.tradeLicenceLabel ?? 'Licence Number',
            value: detail.tradeLicenceNumber,
          ),
          _ProfileRow(
            label: l10n?.licenceExpiryLabel ?? 'Licence Expiry',
            value: dateFormat.format(detail.licenceExpiryDate),
          ),
          _ProfileRow(
            label: l10n?.businessAddressLabel ?? 'Business Address',
            value: detail.businessAddress,
          ),
          _ProfileRow(
            label: l10n?.contactPersonLabel ?? 'Contact Person',
            value: [
              detail.contactPersonName,
              if (detail.mobileNumber != null && detail.mobileNumber!.isNotEmpty)
                detail.mobileNumber,
            ].where((s) => s != null && s.isNotEmpty).join(' · '),
          ),
          _ProfileRow(
            label: 'Business Email',
            value: detail.businessEmail,
          ),
          if (detail.categories.isNotEmpty)
            _ProfileRow(
              label: 'Categories',
              value: detail.categories.join(', '),
            ),
          if (detail.regions.isNotEmpty)
            _ProfileRow(
              label: l10n?.emirateLabel ?? 'Regions',
              value: detail.regions.join(', '),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(
    BuildContext context,
    VendorVerificationDetail detail,
    AppLocalizations? l10n,
  ) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colors.sapphire700.withValues(alpha: 0.3),
        borderRadius: shapes.roundedSm,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.folder_shared_outlined,
                  size: 18, color: colors.goldPrimary),
              SizedBox(width: spacing.xs),
              Text(
                'Uploaded KYC Documents (${detail.documents.length})',
                style: typography.label.copyWith(
                  color: colors.goldPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          if (_docError != null) ...[
            Container(
              padding: EdgeInsets.all(spacing.sm),
              margin: EdgeInsets.only(bottom: spacing.sm),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.15),
                borderRadius: shapes.roundedSm,
                border: Border.all(color: colors.error.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: colors.error),
                  SizedBox(width: spacing.xs),
                  Expanded(
                    child: Text(
                      _docError!,
                      style: typography.caption.copyWith(color: colors.cream100),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (detail.documents.isEmpty)
            Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Text(
                l10n?.noDocumentsUploaded ?? 'No KYC documents uploaded.',
                style: typography.bodySmall.copyWith(color: colors.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.documents.length,
              separatorBuilder: (_, __) => SizedBox(height: spacing.sm),
              itemBuilder: (context, index) {
                final doc = detail.documents[index];
                final isOpening = _loadingDocId == doc.id;
                final isLastOpened = _openedDocId == doc.id;

                return Container(
                  key: Key('document-row-${doc.id}'),
                  padding: EdgeInsets.all(spacing.sm),
                  decoration: BoxDecoration(
                    color: colors.sapphire800,
                    borderRadius: shapes.roundedSm,
                    border: Border.all(
                      color: isLastOpened
                          ? colors.goldPrimary
                          : colors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        doc.mimeType == 'application/pdf'
                            ? Icons.picture_as_pdf_outlined
                            : Icons.description_outlined,
                        color: colors.goldPrimary,
                        size: 24,
                      ),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDocType(l10n, doc.documentType),
                              style: typography.bodySmall.copyWith(
                                color: colors.cream100,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (doc.fileName != null && doc.fileName!.isNotEmpty)
                              Text(
                                doc.fileName!,
                                style: typography.caption
                                    .copyWith(color: colors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      KhStatusChip(
                        label: doc.verified ? 'VERIFIED' : 'SUBMITTED',
                        tone: doc.verified
                            ? KhStatusTone.success
                            : KhStatusTone.pending,
                        dense: true,
                      ),
                      SizedBox(width: spacing.sm),
                      OutlinedButton.icon(
                        key: Key('view-doc-${doc.id}'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.sm,
                            vertical: spacing.xs,
                          ),
                          minimumSize: const Size(40, 32),
                        ),
                        onPressed: isOpening ? null : () => _viewDocument(doc),
                        icon: isOpening
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.open_in_new, size: 14),
                        label: Text(
                          isOpening ? 'Loading...' : 'View',
                          style: typography.caption
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          if (_openedDocUrl != null) ...[
            SizedBox(height: spacing.md),
            Container(
              key: const Key('verification-document-viewer'),
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                color: colors.sapphire900,
                borderRadius: shapes.roundedSm,
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 16, color: colors.goldPrimary),
                  SizedBox(width: spacing.xs),
                  Expanded(
                    child: Text(
                      'Document opened: $_openedDocUrl',
                      style: typography.caption
                          .copyWith(color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => openUrlInNewTab(_openedDocUrl!),
                    child: const Text('Re-open'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: typography.caption.copyWith(color: colors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: typography.bodySmall.copyWith(
                color: colors.cream100,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
