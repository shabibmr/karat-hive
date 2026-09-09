import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/offers/controller/offer_detail_controller.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/model/offer_enums.dart';

/// ADM-S11 · Offer detail — Full offer terms, revisions, state history, and unmasked parties.
class OfferDetailScreen extends ConsumerStatefulWidget {
  const OfferDetailScreen({
    super.key,
    required this.offerId,
  });

  final String offerId;

  @override
  ConsumerState<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isPostingNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  static String _formatPrice(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return 'AED $whole.${parts[1]}';
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute GST';
  }

  Future<void> _handlePostNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPostingNote = true);
    try {
      await ref
          .read(offerDetailControllerProvider(widget.offerId).notifier)
          .addInternalNote(text);
      _noteController.clear();
    } finally {
      if (mounted) {
        setState(() => _isPostingNote = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final asyncDetail =
        ref.watch(offerDetailControllerProvider(widget.offerId));

    return Material(
      color: kh.colors.backgroundSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: asyncDetail.when(
          loading: () => const Center(
            key: Key('offer-detail-loading'),
            child: Padding(
              padding: EdgeInsets.all(64.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => _DetailErrorState(
            key: const Key('offer-detail-error'),
            message: err.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
            onRetry: () => ref
                .read(offerDetailControllerProvider(widget.offerId).notifier)
                .reload(),
          ),
          data: (detail) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Navigation Button
              Row(
                children: [
                  OutlinedButton.icon(
                    key: const Key('back-to-offers-button'),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/offers');
                      }
                    },
                    icon: const Icon(Icons.arrow_back, size: 16.0),
                    label: Text(
                      l10n?.offersDetailBack ?? 'Back to Offers',
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: kh.spacing.md),

              // Screen Header
              KhScreenHeader(
                eyebrow: detail.reference != null && detail.reference!.isNotEmpty
                    ? (l10n?.offersDetailEyebrow(detail.reference!) ??
                        'OFFER ${detail.reference}')
                    : (l10n?.offersDetailEyebrow(detail.id) ??
                        'OFFER ${detail.id}'),
                heading: _formatPrice(detail.offeredPrice),
                supportingText: detail.expiresAt != null
                    ? (l10n?.offersDetailHeaderMetaExpires(
                          _formatDate(detail.submittedAt),
                          detail.validityHours ?? 24,
                          _formatDate(detail.expiresAt),
                        ) ??
                        'Submitted on ${_formatDate(detail.submittedAt)} · Validity ${detail.validityHours ?? 24}h (Expires ${_formatDate(detail.expiresAt)})')
                    : (l10n?.offersDetailHeaderMeta(
                          _formatDate(detail.submittedAt),
                          detail.validityHours ?? 24,
                        ) ??
                        'Submitted on ${_formatDate(detail.submittedAt)} · Validity ${detail.validityHours ?? 24}h'),
                trailing: KhStatusChip(
                  label: detail.state.displayName.toUpperCase(),
                  tone: detail.state.statusTone,
                ),
              ),
              SizedBox(height: kh.spacing.lg),

              // Winning Offer Banner (if rejected because competitor won)
              if (detail.winningOfferId != null ||
                  (detail.state == OfferState.rejected &&
                      detail.winningOfferReference != null)) ...[
                _WinningOfferCard(
                  key: const Key('winning-offer-card'),
                  detail: detail,
                  formatPrice: _formatPrice,
                ),
                SizedBox(height: kh.spacing.lg),
              ],

              // Unmasked Vendor Card & Parent Request Card
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 960.0;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _VendorProfileCard(
                            vendor: detail.vendor,
                          ),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          child: _ParentRequestCard(
                            request: detail.parentRequest,
                            formatPrice: _formatPrice,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _VendorProfileCard(vendor: detail.vendor),
                      SizedBox(height: kh.spacing.lg),
                      _ParentRequestCard(
                        request: detail.parentRequest,
                        formatPrice: _formatPrice,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: kh.spacing.lg),

              // Pricing Breakdown Card
              _PricingBreakdownCard(
                key: const Key('pricing-breakdown-card'),
                detail: detail,
                formatPrice: _formatPrice,
              ),
              SizedBox(height: kh.spacing.lg),

              // Commercial Terms, Notes & Attachments
              _CommercialTermsCard(
                detail: detail,
                formatDate: _formatDate,
              ),
              SizedBox(height: kh.spacing.lg),

              // Revisions History Timeline (FR-VEN-014)
              _RevisionsTimelineCard(
                key: const Key('revisions-timeline-card'),
                revisions: detail.revisions,
                formatPrice: _formatPrice,
                formatDate: _formatDate,
              ),
              SizedBox(height: kh.spacing.lg),

              // State Transitions Timeline
              _StateTransitionsCard(
                key: const Key('state-transitions-card'),
                transitions: detail.stateTransitions,
                currentState: detail.state,
                formatDate: _formatDate,
              ),
              SizedBox(height: kh.spacing.lg),

              // Internal Notes Section
              _InternalNotesCard(
                notes: detail.internalNotes,
                controller: _noteController,
                isPosting: _isPostingNote,
                onPost: _handlePostNote,
                formatDate: _formatDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinningOfferCard extends StatelessWidget {
  const _WinningOfferCard({
    super.key,
    required this.detail,
    required this.formatPrice,
  });

  final OfferDetail detail;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final vendorPart = detail.winningVendorName != null
        ? (l10n?.offersDetailCompetingWonBy(detail.winningVendorName!) ??
            ' by ${detail.winningVendorName}')
        : '';
    final pricePart = detail.winningOfferPrice != null
        ? (l10n?.offersDetailCompetingWonFor(
                formatPrice(detail.winningOfferPrice!)) ??
            ' for ${formatPrice(detail.winningOfferPrice!)}')
        : '';

    return Container(
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.gold400.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(
          color: kh.colors.gold400.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(kh.spacing.sm),
            decoration: BoxDecoration(
              color: kh.colors.gold400.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: kh.colors.goldPrimary,
              size: 28.0,
            ),
          ),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.offersDetailCompetingWonTitle ??
                      'COMPETING OFFER WON THIS REQUEST',
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.goldPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 11.0,
                  ),
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
                  l10n?.offersDetailCompetingWonBody(
                        detail.winningOfferReference ??
                            detail.winningOfferId ??
                            '',
                        vendorPart,
                        pricePart,
                      ) ??
                      'Customer selected winning offer ${detail.winningOfferReference ?? detail.winningOfferId ?? ''}$vendorPart$pricePart.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textPrimary,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
          ),
          if (detail.winningOfferId != null && detail.winningOfferId!.isNotEmpty) ...[
            SizedBox(width: kh.spacing.md),
            ElevatedButton(
              key: const Key('inspect-winning-offer-button'),
              onPressed: () => context.go('/offers/${detail.winningOfferId}'),
              child: Text(
                l10n?.offersDetailInspectWinning ?? 'Inspect Winning Offer',
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VendorProfileCard extends StatelessWidget {
  const _VendorProfileCard({
    required this.vendor,
  });

  final OfferVendorSummary? vendor;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.offersDetailVendorProfileTitle ??
                    'Unmasked Vendor Profile',
                style: kh.typography.title.copyWith(
                  color: kh.colors.textPrimary,
                  fontSize: 16.0,
                ),
              ),
              if (vendor != null)
                OutlinedButton(
                  key: Key('view-vendor-${vendor!.id}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    minimumSize: const Size(60.0, 30.0),
                  ),
                  onPressed: () => context.go('/vendors/${vendor!.id}'),
                  child: Text(
                    l10n?.offersDetailViewVendor ?? 'View Vendor',
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          if (vendor == null)
            Text(
              l10n?.offersDetailNoVendor ?? 'No vendor details provided.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textMuted,
                fontSize: 13.0,
              ),
            )
          else ...[
            _DetailRow(
              label: l10n?.offersDetailLabelLegalName ?? 'Legal Business Name',
              value: vendor!.legalBusinessName,
              isStrong: true,
            ),
            if (vendor!.tradingName != null &&
                vendor!.tradingName!.isNotEmpty &&
                vendor!.tradingName != vendor!.legalBusinessName)
              _DetailRow(
                label: l10n?.offersDetailLabelTradingName ?? 'Trading Name',
                value: vendor!.tradingName!,
              ),
            if (vendor!.tradeLicenceNumber != null)
              _DetailRow(
                label: l10n?.offersDetailLabelTradeLicence ?? 'Trade Licence',
                value: vendor!.tradeLicenceNumber!,
              ),
            if (vendor!.contactPersonName != null || vendor!.mobileNumber != null)
              _DetailRow(
                label: l10n?.offersDetailLabelContactMobile ??
                    'Contact Person & Mobile',
                value: [
                  if (vendor!.contactPersonName != null)
                    vendor!.contactPersonName!,
                  if (vendor!.mobileNumber != null) vendor!.mobileNumber!,
                ].join(' · '),
              ),
            if (vendor!.email != null)
              _DetailRow(
                label: l10n?.offersDetailLabelBusinessEmail ?? 'Business Email',
                value: vendor!.email!,
              ),
            if (vendor!.rating != null)
              _DetailRow(
                label: l10n?.offersDetailLabelVendorRating ?? 'Vendor Rating',
                value:
                    '★ ${vendor!.rating!.toStringAsFixed(1)}${vendor!.completedDeals != null ? (l10n?.offersDetailDealsSuffix(vendor!.completedDeals!) ?? ' (${vendor!.completedDeals} deals completed)') : ''}',
              ),
          ],
        ],
      ),
    );
  }
}

class _ParentRequestCard extends StatelessWidget {
  const _ParentRequestCard({
    required this.request,
    required this.formatPrice,
  });

  final OfferParentRequestSummary? request;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.offersDetailParentRequestTitle ??
                    'Parent Request Reference',
                style: kh.typography.title.copyWith(
                  color: kh.colors.textPrimary,
                  fontSize: 16.0,
                ),
              ),
              if (request != null)
                ElevatedButton.icon(
                  key: const Key('parent-request-link'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    minimumSize: const Size(80.0, 32.0),
                  ),
                  onPressed: () => context.go('/requests/${request!.id}'),
                  icon: const Icon(Icons.open_in_new, size: 14.0),
                  label: Text(
                    l10n?.offersDetailOpenRequest ?? 'Open Request',
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          if (request == null)
            Text(
              l10n?.offersDetailNoParentRequest ?? 'No parent request linked.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textMuted,
                fontSize: 13.0,
              ),
            )
          else ...[
            _DetailRow(
              label: l10n?.offersDetailLabelRequestReference ??
                  'Request Reference',
              value: request!.reference ?? request!.id,
              isStrong: true,
            ),
            if (request!.requestType != null)
              _DetailRow(
                label: l10n?.offersDetailLabelRequestType ?? 'Request Type',
                value: request!.requestType!.displayName,
              ),
            if (request!.customerName != null || request!.customerMobile != null)
              _DetailRow(
                label: l10n?.offersDetailLabelCustomerMobile ??
                    'Customer Name & Mobile',
                value: [
                  if (request!.customerName != null) request!.customerName!,
                  if (request!.customerMobile != null) request!.customerMobile!,
                ].join(' · '),
              ),
            if (request!.categoryName != null)
              _DetailRow(
                label: l10n?.offersDetailLabelCategory ?? 'Category',
                value: request!.categoryName!,
              ),
            if (request!.regionName != null)
              _DetailRow(
                label: l10n?.offersDetailLabelRegion ?? 'Region',
                value: request!.regionName!,
              ),
            if (request!.indicativeValue != null)
              _DetailRow(
                label: l10n?.offersDetailLabelIndicativeBudget ??
                    'Indicative Budget',
                value: formatPrice(request!.indicativeValue!),
              ),
            if (request!.notes != null && request!.notes!.isNotEmpty)
              _DetailRow(
                label: l10n?.offersDetailLabelRequestNotes ?? 'Request Notes',
                value: request!.notes!,
              ),
          ],
        ],
      ),
    );
  }
}

class _PricingBreakdownCard extends StatelessWidget {
  const _PricingBreakdownCard({
    super.key,
    required this.detail,
    required this.formatPrice,
  });

  final OfferDetail detail;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    final goldPrice = detail.calculatedGoldPrice;
    final makingCharge = detail.makingCharges;
    final ratePerGram = detail.ratePerGram;
    final vat = detail.calculatedVat;
    final total = detail.calculatedTotal;

    return Container(
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.offersDetailPricingTitle ?? 'Pricing Breakdown',
            style: kh.typography.title.copyWith(
              color: kh.colors.textPrimary,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          Container(
            padding: EdgeInsets.all(kh.spacing.md),
            decoration: BoxDecoration(
              color: kh.colors.backgroundSurface,
              borderRadius: kh.shapes.roundedMd,
              border: Border.all(color: kh.colors.borderSubtle),
            ),
            child: Column(
              children: [
                _PricingRow(
                  label:
                      l10n?.offersDetailPricingGoldValue ?? 'Gold Metal Value',
                  value: formatPrice(goldPrice),
                  hint: ratePerGram != null
                      ? (l10n?.offersDetailPricingGoldHintRate(
                              formatPrice(ratePerGram)) ??
                          'Base gold price (${formatPrice(ratePerGram)}/g)')
                      : (l10n?.offersDetailPricingGoldHint ??
                          'Base gold price component'),
                ),
                const Divider(),
                _PricingRow(
                  label: l10n?.offersDetailPricingMaking ??
                      'Making / Crafting Charges',
                  value: makingCharge != null ? formatPrice(makingCharge) : '—',
                  hint: l10n?.offersDetailPricingMakingHint ??
                      'Labour and artistry charges',
                ),
                const Divider(),
                _PricingRow(
                  label: l10n?.offersDetailPricingVat ??
                      'Value Added Tax (VAT 5%)',
                  value: formatPrice(vat),
                  hint: l10n?.offersDetailPricingVatHint ?? 'UAE statutory tax',
                ),
                const Divider(thickness: 1.5),
                SizedBox(height: kh.spacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.offersDetailPricingTotal ?? 'Total Offered Price',
                      style: kh.typography.title.copyWith(
                        color: kh.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      formatPrice(total),
                      style: kh.typography.title.copyWith(
                        color: kh.colors.goldPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  const _PricingRow({
    required this.label,
    required this.value,
    this.hint,
  });

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: kh.spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
              if (hint != null)
                Text(
                  hint!,
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textMuted,
                    fontSize: 11.0,
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: kh.typography.bodySmall.copyWith(
              color: kh.colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommercialTermsCard extends StatelessWidget {
  const _CommercialTermsCard({
    required this.detail,
    required this.formatDate,
  });

  final OfferDetail detail;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.offersDetailTermsTitle ??
                'Commercial Terms, Notes & Attachments',
            style: kh.typography.title.copyWith(
              color: kh.colors.textPrimary,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          _DetailRow(
            label: l10n?.offersDetailLabelDelivery ??
                'Delivery / Readiness Timeframe',
            value: detail.deliveryTimeframe ??
                (l10n?.offersDetailDeliveryDefault ??
                    'Immediate dispatch / collection'),
          ),
          _DetailRow(
            label:
                l10n?.offersDetailLabelWarranty ?? 'Warranty / Buy-Back Terms',
            value: detail.warrantyTerms ??
                (l10n?.offersDetailWarrantyDefault ??
                    'Standard UAE jeweller guarantee'),
          ),
          _DetailRow(
            label: l10n?.offersDetailLabelVendorNote ?? 'Vendor Note',
            value: detail.vendorNote ??
                (l10n?.offersDetailVendorNoteDefault ??
                    'No free-text note provided by vendor.'),
          ),
          _DetailRow(
            label: l10n?.offersDetailLabelValidityExpiry ??
                'Offer Validity & Expiry',
            value: l10n?.offersDetailValidityExpiryValue(
                  detail.validityHours ?? 24,
                  formatDate(detail.expiresAt),
                ) ??
                '${detail.validityHours ?? 24} hours · Expiry: ${formatDate(detail.expiresAt)}',
          ),
          if (detail.declineReason != null && detail.declineReason!.isNotEmpty)
            _DetailRow(
              label: l10n?.offersDetailLabelDeclineReason ?? 'Decline Reason',
              value: detail.declineReason!,
              valueColor: kh.colors.error,
            ),
          SizedBox(height: kh.spacing.sm),
          Text(
            l10n?.offersDetailAttachmentsCount(detail.attachments.length) ??
                'Attachments & Certificates (${detail.attachments.length})',
            style: kh.typography.caption.copyWith(
              color: kh.colors.goldPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              fontSize: 11.0,
            ),
          ),
          SizedBox(height: kh.spacing.xs),
          if (detail.attachments.isEmpty)
            Text(
              l10n?.offersDetailNoAttachments ??
                  'No media files or certificates attached by vendor.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textMuted,
                fontSize: 13.0,
              ),
            )
          else
            Wrap(
              spacing: kh.spacing.md,
              runSpacing: kh.spacing.md,
              children: [
                for (final attachment in detail.attachments)
                  Container(
                    width: 220.0,
                    padding: EdgeInsets.all(kh.spacing.sm),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundSurface,
                      borderRadius: kh.shapes.roundedMd,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 28.0,
                          color: kh.colors.goldPrimary,
                        ),
                        SizedBox(width: kh.spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attachment.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: kh.typography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.0,
                                ),
                              ),
                              if (attachment.sizeBytes != null)
                                Text(
                                  '${(attachment.sizeBytes! / 1024).toStringAsFixed(1)} KB',
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
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RevisionsTimelineCard extends StatelessWidget {
  const _RevisionsTimelineCard({
    super.key,
    required this.revisions,
    required this.formatPrice,
    required this.formatDate,
  });

  final List<OfferRevisionItem> revisions;
  final String Function(double) formatPrice;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.offersDetailRevisionsTitle ??
                    'Revisions History (FR-VEN-014)',
                style: kh.typography.title.copyWith(
                  color: kh.colors.textPrimary,
                  fontSize: 16.0,
                ),
              ),
              Text(
                l10n?.offersDetailRevisionCount(revisions.length) ??
                    '${revisions.length} revision${revisions.length == 1 ? '' : 's'}',
                style: kh.typography.caption.copyWith(
                  color: kh.colors.goldPrimary,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.sm),
          if (revisions.isEmpty)
            Text(
              l10n?.offersDetailNoRevisions ??
                  'Initial offer terms. No modifications were made pre-acceptance.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textMuted,
                fontSize: 13.0,
              ),
            )
          else
            Column(
              children: [
                for (final rev in revisions)
                  Container(
                    margin: EdgeInsets.only(bottom: kh.spacing.sm),
                    padding: EdgeInsets.all(kh.spacing.md),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundSurface,
                      borderRadius: kh.shapes.roundedMd,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: kh.colors.gold400.withValues(alpha: 0.15),
                            borderRadius: kh.shapes.roundedSm,
                          ),
                          child: Text(
                            l10n?.offersDetailRevisionNumber(
                                    rev.revisionNumber) ??
                                'Rev #${rev.revisionNumber}',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.goldPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.0,
                            ),
                          ),
                        ),
                        SizedBox(width: kh.spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n?.offersDetailRevisionOffered(formatPrice(rev.offeredPrice)) ?? 'Offered: ${formatPrice(rev.offeredPrice)}'}${rev.makingCharges != null ? (l10n?.offersDetailRevisionMakingSuffix(formatPrice(rev.makingCharges!)) ?? ' (Making: ${formatPrice(rev.makingCharges!)})') : ''}',
                                style: kh.typography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.0,
                                ),
                              ),
                              if (rev.changeSummary != null)
                                Text(
                                  rev.changeSummary!,
                                  style: kh.typography.caption.copyWith(
                                    color: kh.colors.textSecondary,
                                    fontSize: 11.0,
                                  ),
                                ),
                              if (rev.vendorNote != null && rev.vendorNote!.isNotEmpty)
                                Text(
                                  l10n?.offersDetailRevisionNote(
                                          rev.vendorNote!) ??
                                      'Note: ${rev.vendorNote}',
                                  style: kh.typography.caption.copyWith(
                                    color: kh.colors.textMuted,
                                    fontSize: 11.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          formatDate(rev.revisedAt),
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.textMuted,
                            fontSize: 11.0,
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
}

class _StateTransitionsCard extends StatelessWidget {
  const _StateTransitionsCard({
    super.key,
    required this.transitions,
    required this.currentState,
    required this.formatDate,
  });

  final List<OfferStateTransitionItem> transitions;
  final OfferState currentState;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.offersDetailTransitionsTitle ?? 'State Transitions Timeline',
            style: kh.typography.title.copyWith(
              color: kh.colors.textPrimary,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          if (transitions.isEmpty)
            Text(
              l10n?.offersDetailNoTransitions(
                      currentState.displayName.toUpperCase()) ??
                  'Offer is in ${currentState.displayName.toUpperCase()} state. No state transition audit recorded.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textMuted,
                fontSize: 13.0,
              ),
            )
          else
            Column(
              children: [
                for (final item in transitions)
                  Padding(
                    padding: EdgeInsets.only(bottom: kh.spacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          size: 18.0,
                          color: kh.colors.goldPrimary,
                        ),
                        SizedBox(width: kh.spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.fromState != null ? '${item.fromState} → ' : ''}${item.toState}',
                                style: kh.typography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.0,
                                ),
                              ),
                              if (item.actor != null || item.reason != null)
                                Text(
                                  [
                                    if (item.actor != null)
                                      l10n?.offersDetailTransitionActor(
                                              item.actor!) ??
                                          'By: ${item.actor}',
                                    if (item.reason != null)
                                      l10n?.offersDetailTransitionReason(
                                              item.reason!) ??
                                          'Reason: ${item.reason}',
                                  ].join(' · '),
                                  style: kh.typography.caption.copyWith(
                                    color: kh.colors.textMuted,
                                    fontSize: 11.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          formatDate(item.transitionedAt),
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.textMuted,
                            fontSize: 11.0,
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
}

class _InternalNotesCard extends StatelessWidget {
  const _InternalNotesCard({
    required this.notes,
    required this.controller,
    required this.isPosting,
    required this.onPost,
    required this.formatDate,
  });

  final List<OfferInternalNoteItem> notes;
  final TextEditingController controller;
  final bool isPosting;
  final VoidCallback onPost;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.offersDetailNotesTitle ?? 'Internal Administrative Notes',
            style: kh.typography.title.copyWith(
              color: kh.colors.textPrimary,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.xxs),
          Text(
            l10n?.offersDetailNotesSubtitle ??
                'Admin inspection notes are internal to Karat Hive. Commercial terms are read-only.',
            style: kh.typography.caption.copyWith(
              color: kh.colors.textMuted,
              fontSize: 11.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('offer-internal-note-input'),
                  controller: controller,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: l10n?.offersDetailNotesHint ??
                        'Add an internal note about this offer…',
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: kh.spacing.md),
              ElevatedButton.icon(
                key: const Key('offer-add-note-button'),
                onPressed: isPosting ? null : onPost,
                icon: isPosting
                    ? const SizedBox(
                        width: 14.0,
                        height: 14.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : const Icon(Icons.add_comment_outlined, size: 16.0),
                label: Text(
                  l10n?.offersDetailAddNote ?? 'Add Note',
                  style: const TextStyle(fontSize: 12.0),
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.lg),
          if (notes.isEmpty)
            Text(
              l10n?.offersDetailNoNotes ?? 'No internal notes added yet.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textMuted,
                fontSize: 13.0,
              ),
            )
          else
            Column(
              children: [
                for (final note in notes)
                  Container(
                    margin: EdgeInsets.only(bottom: kh.spacing.xs),
                    padding: EdgeInsets.all(kh.spacing.sm),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundSurface,
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 16.0,
                          color: kh.colors.goldPrimary,
                        ),
                        SizedBox(width: kh.spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    note.author,
                                    style: kh.typography.caption.copyWith(
                                      color: kh.colors.goldPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.0,
                                    ),
                                  ),
                                  Text(
                                    formatDate(note.createdAt),
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
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isStrong = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isStrong;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: kh.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180.0,
            child: Text(
              label,
              style: kh.typography.caption.copyWith(
                color: kh.colors.textMuted,
                fontSize: 11.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: kh.typography.bodySmall.copyWith(
                color: valueColor ?? kh.colors.textPrimary,
                fontWeight: isStrong ? FontWeight.w700 : FontWeight.normal,
                fontSize: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kh.spacing.xxl),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.0, color: kh.colors.error),
          SizedBox(height: kh.spacing.md),
          Text(
            l10n?.offersDetailErrorTitle ?? 'Failed to load offer details',
            style: kh.typography.title.copyWith(
              color: kh.colors.error,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: kh.typography.bodySmall.copyWith(
              color: kh.colors.textSecondary,
              fontSize: 13.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          ElevatedButton.icon(
            key: const Key('offer-detail-retry-button'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18.0),
            label: Text(
              l10n?.offersRetry ?? 'Retry',
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
        ],
      ),
    );
  }
}
