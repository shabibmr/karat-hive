import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/theme/kh_theme.dart';
import '../../../core/design/widgets/kh_data_table.dart';
import '../../../core/design/widgets/kh_screen_header.dart';
import '../../../core/design/widgets/kh_section_label.dart';
import '../../../core/design/widgets/kh_status_chip.dart';
import '../controller/request_detail_controller.dart';
import '../model/request_detail.dart';
import '../model/request_enums.dart';

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
                _buildFeedbackBanner(kh),
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

  Widget _buildBackButton(BuildContext context, dynamic kh) {
    return TextButton.icon(
      key: const Key('request-detail-back-button'),
      onPressed: () => context.go('/requests'),
      icon: const Icon(Icons.arrow_back, size: 18.0),
      label: const Text('Back to Requests'),
      style: TextButton.styleFrom(
        foregroundColor: kh.colors.goldPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: kh.spacing.sm,
          vertical: kh.spacing.xs,
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic kh, RequestDetail detail) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
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
                      detail.reference ?? 'NO REFERENCE',
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
                eyebrow: 'REQUEST OVERSIGHT',
                heading: heading,
                supportingText: detail.publishedAt != null
                    ? 'Published ${dateFormat.format(detail.publishedAt!)} GST'
                    : (detail.createdAt != null
                        ? 'Created ${dateFormat.format(detail.createdAt!)} GST'
                        : ''),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackBanner(dynamic kh) {
    final isSuccess = _actionSuccess;
    final color = isSuccess ? kh.colors.success : kh.colors.error;

    return Container(
      key: const Key('request-feedback-banner'),
      padding: EdgeInsets.all(kh.spacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle : Icons.error, color: color, size: 20.0),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Text(
              _actionFeedback!,
              style: kh.typography.bodySmall.copyWith(color: color, fontSize: 13.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16.0),
            color: color,
            onPressed: () => setState(() => _actionFeedback = null),
          ),
        ],
      ),
    );
  }

  Widget _buildRemovedNoticeBanner(dynamic kh, RequestDetail detail) {
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
                  'REQUEST REMOVED BY PLATFORM MODERATION (FR-ADM-019)',
                  style: kh.typography.title.copyWith(
                    color: kh.colors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
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

  Widget _buildConnectionBanner(dynamic kh, RequestConnectionSummary connection) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

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
                  'Accepted Vendor: ${connection.vendorName} · Customer: ${connection.customerName}',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                ),
                Text(
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
              label: const Text('WhatsApp Channel'),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsCard(dynamic kh, RequestDetail detail) {
    final currencyFormat = NumberFormat('#,##0', 'en_US');

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
              const KhSectionLabel('Commercial Requirements & Specifications'),
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
          _buildDetailRow(kh, 'Reference Code', detail.reference ?? '—'),
          _buildDetailRow(kh, 'Request Type', detail.requestType.label),
          _buildDetailRow(kh, 'Market Direction', '${detail.direction.label} (${detail.direction.name.toUpperCase()})'),
          _buildDetailRow(kh, 'Category', detail.categoryName),
          _buildDetailRow(kh, 'Region', detail.regionName),
          if (detail.ornamentType != null && detail.ornamentType!.isNotEmpty)
            _buildDetailRow(kh, 'Ornament Type', detail.ornamentType!),
          if (detail.purityKarat != null && detail.purityKarat!.isNotEmpty)
            _buildDetailRow(kh, 'Purity / Karat', detail.purityKarat!),
          if (detail.weightGrams != null)
            _buildDetailRow(
              kh,
              'Weight',
              '${detail.weightGrams!.toStringAsFixed(2)}g ${detail.weightIsApproximate ? "(Approximate)" : "(Exact)"}',
            ),
          if (detail.condition != null && detail.condition!.isNotEmpty)
            _buildDetailRow(kh, 'Condition', detail.condition!),
          if (detail.denominationGrams != null)
            _buildDetailRow(kh, 'Denomination', '${detail.denominationGrams!.toStringAsFixed(2)}g'),
          if (detail.quantity != null)
            _buildDetailRow(kh, 'Quantity', '${detail.quantity} units'),
          if (detail.mintOrRefiner != null && detail.mintOrRefiner!.isNotEmpty)
            _buildDetailRow(kh, 'Mint / Refiner', detail.mintOrRefiner!),
          if (detail.indicativeValue != null)
            _buildDetailRow(
              kh,
              'Indicative Value',
              'AED ${currencyFormat.format(detail.indicativeValue)}',
              highlightGold: true,
            ),
          if (detail.budgetMin != null || detail.budgetMax != null)
            _buildDetailRow(
              kh,
              'Customer Budget',
              'AED ${currencyFormat.format(detail.budgetMin ?? 0)} – ${currencyFormat.format(detail.budgetMax ?? 0)} ${detail.budgetIsFlexible ? "(Flexible)" : ""}',
            ),
          if (detail.notes != null && detail.notes!.isNotEmpty) ...[
            SizedBox(height: kh.spacing.sm),
            Text(
              'Customer Notes:',
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

  Widget _buildCustomerCard(dynamic kh, RequestDetail detail) {
    final cust = detail.customer;
    final dateFormat = DateFormat('dd MMM yyyy');

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
              const KhSectionLabel('Unmasked Customer Profile'),
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
          _buildDetailRow(kh, 'Mobile Phone', cust.mobileNumber ?? '—'),
          _buildDetailRow(kh, 'Email Address', cust.email ?? '—'),
          if (cust.createdAt != null)
            _buildDetailRow(kh, 'Member Since', dateFormat.format(cust.createdAt!)),
        ],
      ),
    );
  }

  Widget _buildMediaGalleryCard(dynamic kh, RequestDetail detail) {
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
          KhSectionLabel('Uploaded Media (${detail.media.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.media.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
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
                          item.fileName ?? 'Image #${item.displayOrder + 1}',
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

  Widget _buildOffersCard(dynamic kh, RequestDetail detail) {
    final currencyFormat = NumberFormat('#,##0', 'en_US');
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

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
          KhSectionLabel('Received Offers (${detail.offers.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.offers.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                'No offers submitted yet.',
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
              columns: const [
                KhTableColumn('Vendor', flex: 3),
                KhTableColumn('Offered Price', flex: 2),
                KhTableColumn('Status', flex: 2),
                KhTableColumn('Submitted', flex: 2),
                KhTableColumn('Turnaround', flex: 2),
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
                            ? '${offer.estimatedDays} days'
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

  Widget _buildMatchedVendorsCard(dynamic kh, RequestDetail detail) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

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
          KhSectionLabel('Matched Vendors (${detail.matchedVendors.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.matchedVendors.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
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
                          label: mv.viewedAt != null ? 'VIEWED' : 'NOT VIEWED',
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

  Widget _buildTimelineCard(dynamic kh, RequestDetail detail) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

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
          const KhSectionLabel('State Transition History'),
          SizedBox(height: kh.spacing.md),
          if (detail.timeline.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                'No recorded transitions.',
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

  Widget _buildAdminActionsCard(BuildContext context, dynamic kh, RequestDetail detail) {
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
          const KhSectionLabel('Platform Moderation'),
          SizedBox(height: kh.spacing.md),
          Text(
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
              label: const Text('Request Already Removed'),
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
              label: const Text('Remove Request'),
              onPressed: () => _showRemoveDialog(context, kh, detail),
            ),
        ],
      ),
    );
  }

  Widget _buildInternalNotesCard(dynamic kh, RequestDetail detail) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

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
          KhSectionLabel('Admin Internal Notes (${detail.internalNotes.length})'),
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
                'No internal notes recorded.',
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
            decoration: const InputDecoration(
              labelText: 'Add Internal Note',
              hintText: 'Record audit or compliance notes…',
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
                  : const Text('Add Note'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddNote(dynamic kh) async {
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
        _actionFeedback = 'Note added successfully.';
      });
    } on Object catch (e) {
      setState(() {
        _actionSuccess = false;
        _actionFeedback = 'Failed to add note: $e';
      });
    } finally {
      if (mounted) setState(() => _isSubmittingNote = false);
    }
  }

  Future<void> _showRemoveDialog(
    BuildContext context,
    dynamic kh,
    RequestDetail detail,
  ) async {
    final formKey = GlobalKey<FormState>();
    var selectedReasonCode = 'POLICY_VIOLATION';
    final policyClauseController = TextEditingController(text: 'Terms of Service §4.2');
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Remove Request', style: kh.typography.title),
        content: SizedBox(
          width: 480.0,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
                  decoration: const InputDecoration(
                    labelText: 'Reason Code',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'POLICY_VIOLATION',
                      child: Text('Policy violation'),
                    ),
                    DropdownMenuItem(
                      value: 'PROHIBITED_ITEM',
                      child: Text('Prohibited item / Contraband'),
                    ),
                    DropdownMenuItem(
                      value: 'FRAUDULENT_LISTING',
                      child: Text('Fraudulent or misleading listing'),
                    ),
                    DropdownMenuItem(
                      value: 'CUSTOMER_REQUESTED',
                      child: Text('Customer requested cancellation'),
                    ),
                    DropdownMenuItem(
                      value: 'OTHER',
                      child: Text('Other administrative reason'),
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
                  decoration: const InputDecoration(
                    labelText: 'Policy Clause (cited to customer)',
                    hintText: 'e.g. Terms of Service §4.2',
                    isDense: true,
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                TextFormField(
                  key: const Key('remove-reason-text-field'),
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Justification & Notes',
                    hintText: 'State reason for audit log…',
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Detailed justification is required.' : null,
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
            child: const Text('Confirm Removal'),
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
          _actionFeedback = 'Request successfully removed.';
        });
      } on Object catch (e) {
        setState(() {
          _actionSuccess = false;
          _actionFeedback = 'Failed to remove request: $e';
        });
      }
    }
  }

  Widget _buildDetailRow(
    dynamic kh,
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
    dynamic kh,
    String message,
    VoidCallback onRetry,
  ) {
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
              child: const Text('Retry'),
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
