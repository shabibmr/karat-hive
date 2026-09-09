import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_feedback_banner.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/requests/controller/request_detail_controller.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/core/format/kh_formats.dart';

/// ADM-S09 · Request detail — full request oversight, matched vendors, offers, unmasked customer,
/// state timeline, connection status, internal notes, and administrative removal action.
class RequestDetailScreen extends ConsumerStatefulWidget {
  const RequestDetailScreen({
    super.key,
    required this.requestId,
  });

  final String requestId;

  @override
  ConsumerState<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  final _noteController = TextEditingController();
  bool _isSubmittingNote = false;
  String? _actionFeedback;
  bool _actionSuccess = true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final detailAsync = ref.watch(requestDetailControllerProvider(widget.requestId));

    return Material(
      color: kh.colors.backgroundSurface,
      child: detailAsync.when(
        loading: () => const Center(
          key: Key('request-detail-loading'),
          child: Padding(
            padding: EdgeInsets.all(48.0),
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
                kh,
                err.toString(),
                () => ref
                    .read(requestDetailControllerProvider(widget.requestId).notifier)
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
              _buildHeader(kh, detail),
              if (_actionFeedback != null) ...[
                SizedBox(height: kh.spacing.md),
                KhFeedbackBanner(
                  key: const Key('request-feedback-banner'),
                  message: _actionFeedback!,
                  isSuccess: _actionSuccess,
                  onDismiss: () => setState(() => _actionFeedback = null),
                ),
              ],
              if (detail.isRemoved) ...[
                SizedBox(height: kh.spacing.md),
                _buildRemovedNoticeBanner(kh, detail),
              ],
              if (detail.isAccepted && detail.connection != null) ...[
                SizedBox(height: kh.spacing.md),
                _buildConnectionBanner(kh, detail.connection!),
              ],
              SizedBox(height: kh.spacing.xl),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1080;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSpecificationsCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildMediaGalleryCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildOffersCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildTimelineCard(kh, detail),
                            ],
                          ),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildCustomerCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildMatchedVendorsCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildAdminActionsCard(context, kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildInternalNotesCard(kh, detail),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCustomerCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildSpecificationsCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildMediaGalleryCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildOffersCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildMatchedVendorsCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildTimelineCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildAdminActionsCard(context, kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildInternalNotesCard(kh, detail),
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
    final l10n = AppLocalizations.of(context);
    return TextButton.icon(
      key: const Key('request-detail-back-button'),
      onPressed: () => context.go('/requests'),
      icon: const Icon(Icons.arrow_back, size: 18.0),
      label: Text(l10n?.requestsDetailBack ?? 'Back to Requests'),
      style: TextButton.styleFrom(
        foregroundColor: kh.colors.goldPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: kh.spacing.sm,
          vertical: kh.spacing.xs,
        ),
      ),
    );
  }

  Widget _buildHeader(KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;
    final heading = detail.ornamentType != null && detail.ornamentType!.isNotEmpty
        ? '${detail.purityKarat != null ? "${detail.purityKarat} " : ""}${detail.ornamentType}'
        : '${detail.requestType.label} (${detail.direction.label})';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: kh.spacing.sm,
                      vertical: kh.spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: kh.colors.sapphire800,
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Text(
                      detail.reference ??
                          (l10n?.requestsDetailNoReference ?? 'NO REFERENCE'),
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.goldPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: kh.spacing.sm),
                  KhStatusChip(
                    label: detail.state.label,
                    tone: _stateTone(detail.state),
                  ),
                ],
              ),
              SizedBox(height: kh.spacing.xs),
              KhScreenHeader(
                eyebrow: l10n?.requestsDetailEyebrow ?? 'REQUEST OVERSIGHT',
                heading: heading,
                supportingText: detail.publishedAt != null
                    ? (l10n?.requestsDetailPublishedAt(
                            dateFormat.format(detail.publishedAt!)) ??
                        'Published ${dateFormat.format(detail.publishedAt!)} GST')
                    : (detail.createdAt != null
                        ? (l10n?.requestsDetailCreatedAt(
                                dateFormat.format(detail.createdAt!)) ??
                            'Created ${dateFormat.format(detail.createdAt!)} GST')
                        : ''),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemovedNoticeBanner(KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('request-removed-banner'),
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.error.withValues(alpha: 0.12),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gavel, color: kh.colors.error, size: 24.0),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.requestsDetailRemovedTitle ??
                      'REQUEST REMOVED BY PLATFORM MODERATION (FR-ADM-019)',
                  style: kh.typography.title.copyWith(
                    color: kh.colors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
                  l10n?.requestsDetailRemovedReason(
                        detail.removalReasonCode ??
                            l10n.requestsDetailRemovedReasonCodeDefault,
                        detail.removalReasonText ??
                            l10n.requestsDetailRemovedReasonTextDefault,
                      ) ??
                      'Reason: ${detail.removalReasonCode ?? "POLICY_VIOLATION"} · ${detail.removalReasonText ?? "Violates platform trading guidelines"}',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textPrimary,
                    fontSize: 12.0,
                  ),
                ),
                if (detail.removalPolicyClause != null &&
                    detail.removalPolicyClause!.isNotEmpty) ...[
                  SizedBox(height: kh.spacing.xxs),
                  Text(
                    l10n?.requestsDetailRemovedPolicyClause(
                            detail.removalPolicyClause!) ??
                        'Policy clause cited: ${detail.removalPolicyClause}',
                    style: kh.typography.caption.copyWith(
                      color: kh.colors.textMuted,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner(KhThemeExtension kh, RequestConnectionSummary connection) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;

    return Container(
      key: const Key('request-connection-banner'),
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.success.withValues(alpha: 0.12),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.handshake, color: kh.colors.success, size: 28.0),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n?.requestsDetailConnectionTitle ??
                          'ACTIVE CONNECTION ESTABLISHED',
                      style: kh.typography.title.copyWith(
                        color: kh.colors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(width: kh.spacing.sm),
                    KhStatusChip(
                      label: connection.state,
                      tone: KhStatusTone.success,
                      dense: true,
                    ),
                  ],
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
                  l10n?.requestsDetailConnectionParties(
                        connection.vendorName,
                        connection.customerName,
                      ) ??
                      'Accepted Vendor: ${connection.vendorName} · Customer: ${connection.customerName}',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                ),
                Text(
                  l10n?.requestsDetailConnectionMeta(
                        dateFormat.format(connection.connectedAt),
                        connection.channel ??
                            l10n.requestsDetailConnectionChannelDefault,
                      ) ??
                      'Connected at: ${dateFormat.format(connection.connectedAt)} GST · Channel: ${connection.channel ?? "WHATSAPP"}',
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textSecondary,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
          if (connection.whatsappUrl != null && connection.whatsappUrl!.isNotEmpty)
            OutlinedButton.icon(
              icon: const Icon(Icons.chat, size: 16.0),
              label: Text(l10n?.requestsDetailWhatsappChannel ?? 'WhatsApp Channel'),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsCard(KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = khNumberFormat;

    return Container(
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
              KhSectionLabel(l10n?.requestsDetailSpecsTitle ??
                  'Commercial Requirements & Specifications'),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: kh.colors.sapphire900,
                  borderRadius: kh.shapes.roundedSm,
                ),
                child: Text(
                  l10n?.requestsDetailSpecsReadOnly ??
                      'READ-ONLY FOR ADMIN (FR-ADM-018 AC3)',
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textMuted,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          _buildDetailRow(
              kh,
              l10n?.requestsDetailLabelReferenceCode ?? 'Reference Code',
              detail.reference ?? '—'),
          _buildDetailRow(
              kh,
              l10n?.requestsDetailLabelRequestType ?? 'Request Type',
              detail.requestType.label),
          _buildDetailRow(
              kh,
              l10n?.requestsDetailLabelMarketDirection ?? 'Market Direction',
              '${detail.direction.label} (${detail.direction.name.toUpperCase()})'),
          _buildDetailRow(kh,
              l10n?.requestsDetailLabelCategory ?? 'Category', detail.categoryName),
          _buildDetailRow(kh, l10n?.requestsDetailLabelRegion ?? 'Region',
              detail.regionName),
          if (detail.ornamentType != null && detail.ornamentType!.isNotEmpty)
            _buildDetailRow(
                kh,
                l10n?.requestsDetailLabelOrnamentType ?? 'Ornament Type',
                detail.ornamentType!),
          if (detail.purityKarat != null && detail.purityKarat!.isNotEmpty)
            _buildDetailRow(
                kh,
                l10n?.requestsDetailLabelPurityKarat ?? 'Purity / Karat',
                detail.purityKarat!),
          if (detail.weightGrams != null)
            _buildDetailRow(
              kh,
              l10n?.requestsDetailLabelWeight ?? 'Weight',
              detail.weightIsApproximate
                  ? (l10n?.requestsDetailWeightApproximate(
                          detail.weightGrams!.toStringAsFixed(2)) ??
                      '${detail.weightGrams!.toStringAsFixed(2)}g (Approximate)')
                  : (l10n?.requestsDetailWeightExact(
                          detail.weightGrams!.toStringAsFixed(2)) ??
                      '${detail.weightGrams!.toStringAsFixed(2)}g (Exact)'),
            ),
          if (detail.condition != null && detail.condition!.isNotEmpty)
            _buildDetailRow(kh,
                l10n?.requestsDetailLabelCondition ?? 'Condition', detail.condition!),
          if (detail.denominationGrams != null)
            _buildDetailRow(
                kh,
                l10n?.requestsDetailLabelDenomination ?? 'Denomination',
                '${detail.denominationGrams!.toStringAsFixed(2)}g'),
          if (detail.quantity != null)
            _buildDetailRow(
                kh,
                l10n?.requestsDetailLabelQuantity ?? 'Quantity',
                l10n?.requestsDetailQuantityUnits(detail.quantity!) ??
                    '${detail.quantity} units'),
          if (detail.mintOrRefiner != null && detail.mintOrRefiner!.isNotEmpty)
            _buildDetailRow(
                kh,
                l10n?.requestsDetailLabelMintRefiner ?? 'Mint / Refiner',
                detail.mintOrRefiner!),
          if (detail.indicativeValue != null)
            _buildDetailRow(
              kh,
              l10n?.requestsDetailLabelIndicativeValue ?? 'Indicative Value',
              'AED ${currencyFormat.format(detail.indicativeValue)}',
              highlightGold: true,
            ),
          if (detail.budgetMin != null || detail.budgetMax != null)
            _buildDetailRow(
              kh,
              l10n?.requestsDetailLabelCustomerBudget ?? 'Customer Budget',
              detail.budgetIsFlexible
                  ? (l10n?.requestsDetailBudgetValueFlexible(
                          currencyFormat.format(detail.budgetMin ?? 0),
                          currencyFormat.format(detail.budgetMax ?? 0)) ??
                      'AED ${currencyFormat.format(detail.budgetMin ?? 0)} – ${currencyFormat.format(detail.budgetMax ?? 0)} (Flexible)')
                  : (l10n?.requestsDetailBudgetValue(
                          currencyFormat.format(detail.budgetMin ?? 0),
                          currencyFormat.format(detail.budgetMax ?? 0)) ??
                      'AED ${currencyFormat.format(detail.budgetMin ?? 0)} – ${currencyFormat.format(detail.budgetMax ?? 0)}'),
            ),
          if (detail.notes != null && detail.notes!.isNotEmpty) ...[
            SizedBox(height: kh.spacing.sm),
            Text(
              l10n?.requestsDetailCustomerNotes ?? 'Customer Notes:',
              style: kh.typography.caption.copyWith(color: kh.colors.textMuted, fontSize: 11.0),
            ),
            SizedBox(height: kh.spacing.xxs),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(kh.spacing.sm),
              decoration: BoxDecoration(
                color: kh.colors.backgroundSurface,
                borderRadius: kh.shapes.roundedSm,
                border: Border.all(color: kh.colors.borderSubtle),
              ),
              child: Text(
                detail.notes!,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerCard(KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    final cust = detail.customer;
    final dateFormat = khDateFormat;

    return Container(
      key: const Key('request-customer-card'),
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
              KhSectionLabel(l10n?.requestsDetailCustomerProfileTitle ??
                  'Unmasked Customer Profile'),
              KhStatusChip(
                label: cust.accountState,
                tone: cust.accountState == 'ACTIVE'
                    ? KhStatusTone.success
                    : KhStatusTone.error,
                dense: true,
              ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 22.0,
                backgroundColor: kh.colors.goldPrimary.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: kh.colors.goldPrimary, size: 24.0),
              ),
              SizedBox(width: kh.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cust.fullName,
                      style: kh.typography.title.copyWith(
                        color: kh.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                      ),
                    ),
                    Text(
                      l10n?.requestsDetailCustomerId(cust.id) ??
                          'Customer ID: ${cust.id}',
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textMuted,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          _buildDetailRow(kh, l10n?.requestsDetailLabelMobilePhone ?? 'Mobile Phone',
              cust.mobileNumber ?? '—'),
          _buildDetailRow(kh, l10n?.requestsDetailLabelEmailAddress ?? 'Email Address',
              cust.email ?? '—'),
          if (cust.createdAt != null)
            _buildDetailRow(
                kh,
                l10n?.requestsDetailLabelMemberSince ?? 'Member Since',
                dateFormat.format(cust.createdAt!)),
        ],
      ),
    );
  }

  Widget _buildMediaGalleryCard(KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('request-media-gallery'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(
              l10n?.requestsDetailMediaTitle(detail.media.length) ??
                  'Uploaded Media (${detail.media.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.media.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoMedia ??
                    'No media uploaded for this request.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textMuted,
                  fontSize: 13.0,
                ),
              ),
            )
          else
            Wrap(
              spacing: kh.spacing.md,
              runSpacing: kh.spacing.md,
              children: [
                for (final item in detail.media)
                  Container(
                    width: 140.0,
                    padding: EdgeInsets.all(kh.spacing.xs),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundSurface,
                      borderRadius: kh.shapes.roundedMd,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: kh.colors.sapphire900,
                            borderRadius: kh.shapes.roundedSm,
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: kh.colors.goldPrimary,
                            size: 36.0,
                          ),
                        ),
                        SizedBox(height: kh.spacing.xxs),
                        Text(
                          item.fileName ??
                              (l10n?.requestsDetailImageNumber(
                                      item.displayOrder + 1) ??
                                  'Image #${item.displayOrder + 1}'),
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.sizeBytes != null)
                          Text(
                            '${(item.sizeBytes! / 1024).toStringAsFixed(0)} KB',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.textMuted,
                              fontSize: 10.0,
                            ),
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

  Widget _buildOffersCard(KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = khNumberFormat;
    final dateFormat = khDateTimeFormat;

    return Container(
      key: const Key('request-offers-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(
              l10n?.requestsDetailOffersTitle(detail.offers.length) ??
                  'Received Offers (${detail.offers.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.offers.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoOffers ?? 'No offers submitted yet.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textMuted,
                  fontSize: 13.0,
                ),
              ),
            )
          else
            KhDataTable(
              key: const Key('request-offers-table'),
              minWidth: 700.0,
              columns: [
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnVendor ?? 'Vendor', flex: 3),
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnPrice ?? 'Offered Price',
                    flex: 2),
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnStatus ?? 'Status', flex: 2),
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnSubmitted ?? 'Submitted',
                    flex: 2),
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnTurnaround ?? 'Turnaround',
                    flex: 2),
              ],
              rows: [
                for (final offer in detail.offers)
                  KhTableRow(
                    cells: [
                      Text(
                        offer.vendorName,
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.0,
                        ),
                      ),
                      Text(
                        'AED ${currencyFormat.format(offer.priceAED)}',
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.goldPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.0,
                        ),
                      ),
                      KhStatusChip(
                        label: offer.state.label,
                        tone: _offerStateTone(offer.state),
                        dense: true,
                      ),
                      Text(
                        dateFormat.format(offer.submittedAt),
                        style: kh.typography.caption.copyWith(
                          color: kh.colors.textSecondary,
                          fontSize: 11.0,
                        ),
                      ),
                      Text(
                        offer.estimatedDays != null
                            ? (l10n?.requestsDetailOfferDays(
                                    offer.estimatedDays!) ??
                                '${offer.estimatedDays} days')
                            : (offer.notes ?? '—'),
                        style: kh.typography.caption.copyWith(
                          color: kh.colors.textSecondary,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMatchedVendorsCard(KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;

    return Container(
      key: const Key('request-matched-vendors'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(
              l10n?.requestsDetailMatchedTitle(detail.matchedVendors.length) ??
                  'Matched Vendors (${detail.matchedVendors.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.matchedVendors.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoMatched ??
                    'No vendors matched to this request.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textMuted,
                  fontSize: 13.0,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.matchedVendors.length,
              separatorBuilder: (_, __) => Divider(
                color: kh.colors.borderSubtle,
                height: kh.spacing.md,
              ),
              itemBuilder: (context, index) {
                final mv = detail.matchedVendors[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mv.businessName,
                            style: kh.typography.bodySmall.copyWith(
                              color: kh.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.0,
                            ),
                          ),
                          if (mv.tradingName != null && mv.tradingName!.isNotEmpty)
                            Text(
                              mv.tradingName!,
                              style: kh.typography.caption.copyWith(
                                color: kh.colors.textMuted,
                                fontSize: 11.0,
                              ),
                            ),
                          Text(
                            l10n?.requestsDetailMatchedAt(
                                    dateFormat.format(mv.matchedAt)) ??
                                'Matched: ${dateFormat.format(mv.matchedAt)}',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.textSecondary,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (mv.rating != null)
                          Text(
                            '★ ${mv.rating!.toStringAsFixed(1)}',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.goldPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.0,
                            ),
                          ),
                        SizedBox(height: kh.spacing.xxs),
                        KhStatusChip(
                          label: mv.viewedAt != null
                              ? (l10n?.requestsDetailViewed ?? 'VIEWED')
                              : (l10n?.requestsDetailNotViewed ?? 'NOT VIEWED'),
                          tone: mv.viewedAt != null
                              ? KhStatusTone.success
                              : KhStatusTone.neutral,
                          dense: true,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;

    return Container(
      key: const Key('request-timeline'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(
              l10n?.requestsDetailTimelineTitle ?? 'State Transition History'),
          SizedBox(height: kh.spacing.md),
          if (detail.timeline.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoTransitions ?? 'No recorded transitions.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textMuted,
                  fontSize: 13.0,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.timeline.length,
              separatorBuilder: (_, __) => SizedBox(height: kh.spacing.sm),
              itemBuilder: (context, index) {
                final ev = detail.timeline[index];
                return Row(
                  children: [
                    KhStatusChip(
                      label: ev.state.label,
                      tone: _stateTone(ev.state),
                      dense: true,
                    ),
                    SizedBox(width: kh.spacing.md),
                    Text(
                      dateFormat.format(ev.timestamp),
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                    if (ev.actor != null) ...[
                      SizedBox(width: kh.spacing.sm),
                      Text(
                        l10n?.requestsDetailTimelineBy(ev.actor!) ??
                            'by ${ev.actor}',
                        style: kh.typography.caption.copyWith(
                          color: kh.colors.textMuted,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                    if (ev.notes != null) ...[
                      SizedBox(width: kh.spacing.sm),
                      Expanded(
                        child: Text(
                          '(${ev.notes})',
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.textSecondary,
                            fontStyle: FontStyle.italic,
                            fontSize: 11.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAdminActionsCard(BuildContext context, KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(
              l10n?.requestsDetailModerationTitle ?? 'Platform Moderation'),
          SizedBox(height: kh.spacing.md),
          Text(
            l10n?.requestsDetailModerationBody ??
                'Administrators can forcibly remove requests that violate platform trading policies (FR-ADM-019).',
            style: kh.typography.bodySmall.copyWith(
              color: kh.colors.textSecondary,
              fontSize: 12.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          if (detail.isRemoved)
            ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.block, size: 18.0),
              label: Text(
                  l10n?.requestsDetailAlreadyRemoved ?? 'Request Already Removed'),
            )
          else
            ElevatedButton.icon(
              key: const Key('remove-request-button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kh.colors.error,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.md,
                  vertical: kh.spacing.sm,
                ),
              ),
              icon: const Icon(Icons.delete_forever, size: 18.0),
              label: Text(l10n?.requestsDetailRemoveRequest ?? 'Remove Request'),
              onPressed: () => _showRemoveDialog(context, kh, detail),
            ),
        ],
      ),
    );
  }

  Widget _buildInternalNotesCard(KhThemeExtension kh, RequestDetail detail) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;

    return Container(
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(
              l10n?.requestsDetailNotesTitle(detail.internalNotes.length) ??
                  'Admin Internal Notes (${detail.internalNotes.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.internalNotes.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.internalNotes.length,
              separatorBuilder: (_, __) => Divider(
                color: kh.colors.borderSubtle,
                height: kh.spacing.md,
              ),
              itemBuilder: (context, index) {
                final note = detail.internalNotes[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          note.authorName,
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.goldPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.0,
                          ),
                        ),
                        Text(
                          dateFormat.format(note.createdAt),
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.textMuted,
                            fontSize: 10.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: kh.spacing.xxs),
                    Text(
                      note.text,
                      style: kh.typography.bodySmall.copyWith(
                        color: kh.colors.textPrimary,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                );
              },
            )
          else
            Padding(
              padding: EdgeInsets.only(bottom: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoNotes ?? 'No internal notes recorded.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textMuted,
                  fontSize: 12.0,
                ),
              ),
            ),
          SizedBox(height: kh.spacing.sm),
          TextField(
            key: const Key('add-note-field'),
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n?.requestsDetailAddNoteLabel ?? 'Add Internal Note',
              hintText: l10n?.requestsDetailAddNoteHint ??
                  'Record audit or compliance notes…',
              isDense: true,
            ),
          ),
          SizedBox(height: kh.spacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              key: const Key('submit-note-button'),
              onPressed: _isSubmittingNote ? null : () => _handleAddNote(kh),
              child: _isSubmittingNote
                  ? const SizedBox(
                      width: 14.0,
                      height: 14.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    )
                  : Text(l10n?.requestsDetailAddNote ?? 'Add Note'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddNote(KhThemeExtension kh) async {
    final l10n = AppLocalizations.of(context);
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmittingNote = true);
    try {
      await ref
          .read(requestDetailControllerProvider(widget.requestId).notifier)
          .addNote(text: text);
      _noteController.clear();
      setState(() {
        _actionSuccess = true;
        _actionFeedback =
            l10n?.requestsDetailNoteAdded ?? 'Note added successfully.';
      });
    } on Object catch (e) {
      setState(() {
        _actionSuccess = false;
        _actionFeedback =
            l10n?.requestsDetailNoteAddFailed(e.toString()) ??
                'Failed to add note: $e';
      });
    } finally {
      if (mounted) setState(() => _isSubmittingNote = false);
    }
  }

  Future<void> _showRemoveDialog(
    BuildContext context,
    KhThemeExtension kh,
    RequestDetail detail,
  ) async {
    final l10n = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    var selectedReasonCode = 'POLICY_VIOLATION';
    final policyClauseController = TextEditingController(text: 'Terms of Service §4.2');
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

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(requestDetailControllerProvider(widget.requestId).notifier)
            .removeRequest(
              reasonCode: selectedReasonCode,
              reasonText: reasonController.text.trim(),
              policyClause: policyClauseController.text.trim(),
            );
        setState(() {
          _actionSuccess = true;
          _actionFeedback = l10n?.requestsDetailRemoveSuccess ??
              'Request successfully removed.';
        });
      } on Object catch (e) {
        setState(() {
          _actionSuccess = false;
          _actionFeedback = l10n?.requestsDetailRemoveFailed(e.toString()) ??
              'Failed to remove request: $e';
        });
      }
    }
  }

  Widget _buildDetailRow(
    KhThemeExtension kh,
    String label,
    String value, {
    bool highlightGold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: kh.spacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.0,
            child: Text(
              label,
              style: kh.typography.caption.copyWith(
                color: kh.colors.textMuted,
                fontSize: 12.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: kh.typography.bodySmall.copyWith(
                color: highlightGold ? kh.colors.goldPrimary : kh.colors.textPrimary,
                fontWeight: highlightGold ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    KhThemeExtension kh,
    String message,
    VoidCallback onRetry,
  ) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.0, color: kh.colors.error),
            SizedBox(height: kh.spacing.md),
            Text(
              message,
              style: kh.typography.body.copyWith(
                color: kh.colors.error,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kh.spacing.md),
            OutlinedButton(
              key: const Key('request-detail-retry-button'),
              onPressed: onRetry,
              child: Text(l10n?.requestsDetailErrorRetry ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  KhStatusTone _stateTone(RequestState state) {
    switch (state) {
      case RequestState.draft:
        return KhStatusTone.neutral;
      case RequestState.published:
        return KhStatusTone.moderation;
      case RequestState.offersReceived:
        return KhStatusTone.pending;
      case RequestState.accepted:
        return KhStatusTone.success;
      case RequestState.closed:
      case RequestState.expired:
        return KhStatusTone.neutral;
      case RequestState.cancelled:
      case RequestState.removed:
        return KhStatusTone.error;
    }
  }

  KhStatusTone _offerStateTone(OfferState state) {
    switch (state) {
      case OfferState.accepted:
        return KhStatusTone.success;
      case OfferState.pending:
        return KhStatusTone.pending;
      case OfferState.rejected:
      case OfferState.expired:
      case OfferState.withdrawn:
      case OfferState.withdrawnBySystem:
        return KhStatusTone.error;
    }
  }
}
