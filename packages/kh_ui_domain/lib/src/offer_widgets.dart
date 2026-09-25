import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import 'package:kh_ui_domain/src/expiry_countdown.dart';
import 'package:kh_ui_domain/src/masked_party_label.dart';
import 'package:kh_ui_domain/src/money_display.dart';
import 'package:kh_ui_domain/src/purity_picker.dart';

KhStatusTone offerStateTone(OfferState state) => switch (state) {
      OfferState.pending => KhStatusTone.accent,
      OfferState.accepted => KhStatusTone.success,
      OfferState.rejected ||
      OfferState.expired ||
      OfferState.withdrawn ||
      OfferState.withdrawnBySystem =>
        KhStatusTone.danger,
      OfferState.unknown => KhStatusTone.neutral,
    };

String offerStateLabel(OfferState state, AppLocalizations? l10n) =>
    switch (state) {
      OfferState.pending => l10n?.offerStatePending ?? 'Pending',
      OfferState.accepted => l10n?.offerStateAccepted ?? 'Accepted',
      OfferState.rejected => l10n?.offerStateRejected ?? 'Rejected',
      OfferState.expired => l10n?.offerStateExpired ?? 'Expired',
      OfferState.withdrawn || OfferState.withdrawnBySystem =>
        l10n?.offerStateWithdrawn ?? 'Withdrawn',
      OfferState.unknown => l10n?.offerStateUnknown ?? 'Unknown',
    };

/// View mode for [OfferSummaryCard] (SH-OFF-01).
enum OfferSummaryCardView {
  /// Customer Offers list (CUS-S11) — counterparty is [MaskedParty] Vendor.
  customer,

  /// Vendor My Offers (VEN-S11) — counterparty is masked Customer label.
  vendor,
}

/// SH-OFF-01 — Offer summary row (Customer and Vendor variants).
///
/// Customer variant takes [OfferForCustomer] only — Vendor identity fields are
/// unreachable ([MaskedParty] via [MaskedPartyLabel]).
class OfferSummaryCard extends StatelessWidget {
  /// Vendor My-Offers row (backward-compatible positional API).
  const OfferSummaryCard({
    super.key,
    required OfferForVendor offer,
    this.onTap,
    this.connectionComingSoonLabel,
    this.selected = false,
  })  : view = OfferSummaryCardView.vendor,
        vendorOffer = offer,
        customerOffer = null;

  const OfferSummaryCard.vendor({
    super.key,
    required OfferForVendor offer,
    this.onTap,
    this.connectionComingSoonLabel,
    this.selected = false,
  })  : view = OfferSummaryCardView.vendor,
        vendorOffer = offer,
        customerOffer = null;

  /// Customer Offers-on-Request row (CUS-S11).
  const OfferSummaryCard.customer({
    super.key,
    required OfferForCustomer offer,
    this.onTap,
    this.selected = false,
  })  : view = OfferSummaryCardView.customer,
        customerOffer = offer,
        vendorOffer = null,
        connectionComingSoonLabel = null;

  final OfferSummaryCardView view;
  final OfferForCustomer? customerOffer;
  final OfferForVendor? vendorOffer;
  final VoidCallback? onTap;
  final String? connectionComingSoonLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (view == OfferSummaryCardView.customer) {
      return _CustomerOfferSummaryCard(
        offer: customerOffer!,
        onTap: onTap,
        selected: selected,
      );
    }
    return _VendorOfferSummaryCard(
      offer: vendorOffer!,
      onTap: onTap,
      connectionComingSoonLabel: connectionComingSoonLabel,
    );
  }
}

class _CustomerOfferSummaryCard extends StatelessWidget {
  const _CustomerOfferSummaryCard({
    required this.offer,
    this.onTap,
    this.selected = false,
  });

  final OfferForCustomer offer;
  final VoidCallback? onTap;
  final bool selected;

  /// Unread only when the wire key is present and the timestamp is null (SAM-GAP-1).
  bool get _unread =>
      offer.viewedByCustomerAtPresent && offer.viewedByCustomerAt == null;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    final price = double.tryParse(offer.terms.offeredPrice) ?? 0;
    final borderColor = selected
        ? tokens.gold
        : tokens.ink.withValues(alpha: 0.12);

    return Card(
      key: Key('offer-summary-${offer.id}'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: borderColor, width: selected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: MaskedPartyLabel(party: offer.vendor),
                  ),
                  if (_unread) ...[
                    const KhBadge(count: 1),
                    SizedBox(width: tokens.space.xs),
                  ],
                  KhStatusChip(
                    label: offerStateLabel(offer.state, l10n),
                    tone: offerStateTone(offer.state),
                    compact: true,
                  ),
                ],
              ),
              SizedBox(height: tokens.space.sm),
              MoneyDisplay(amount: price, highlight: true),
              if (offer.state == OfferState.pending) ...[
                SizedBox(height: tokens.space.sm),
                ExpiryCountdown(expiresAt: offer.expiresAt),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorOfferSummaryCard extends StatelessWidget {
  const _VendorOfferSummaryCard({
    required this.offer,
    this.onTap,
    this.connectionComingSoonLabel,
  });

  final OfferForVendor offer;
  final VoidCallback? onTap;
  final String? connectionComingSoonLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final summary = offer.requestSummary;
    final title = summary?.displayTitle(
          fallback: l10n?.offerFallbackTitle ?? 'Offer',
        ) ??
        (l10n?.offerFallbackTitle ?? 'Offer');
    final price = double.tryParse(offer.terms.offeredPrice) ?? 0;

    return Card(
      key: Key('offer-summary-${offer.id}'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (offer.terms.media.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      offer.terms.media.first.key,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                SizedBox(height: tokens.space.sm),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  KhStatusChip(
                    label: offerStateLabel(offer.state, l10n),
                    tone: offerStateTone(offer.state),
                    compact: true,
                  ),
                ],
              ),
              SizedBox(height: tokens.space.sm),
              MoneyDisplay(amount: price, highlight: true),
              if (summary?.customerLabel != null) ...[
                SizedBox(height: tokens.space.xs),
                Text(
                  summary!.customerLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.7),
                  ),
                ),
              ],
              if (offer.state == OfferState.pending) ...[
                SizedBox(height: tokens.space.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ExpiryCountdown(expiresAt: offer.expiresAt),
                    KhStatusChip(
                      label: offer.isSeenByCustomer
                          ? 'Seen by Customer'
                          : 'Not Seen Yet',
                      tone: offer.isSeenByCustomer
                          ? KhStatusTone.accent
                          : KhStatusTone.neutral,
                      compact: true,
                    ),
                  ],
                ),
              ],
              if (offer.awardedElsewhere) ...[
                SizedBox(height: tokens.space.sm),
                Text(
                  l10n?.offerAwardedElsewhere ??
                      'This Request was awarded elsewhere.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.75),
                  ),
                ),
              ],
              if (offer.state == OfferState.accepted &&
                  connectionComingSoonLabel != null) ...[
                SizedBox(height: tokens.space.sm),
                Text(
                  connectionComingSoonLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Mutable draft for SH-OFF-02 / SH-OFF-03.
class OfferTermsDraft {
  OfferTermsDraft({
    this.offeredPrice = '',
    this.weightGrams = '',
    this.purityKarat = Karat.k22,
    this.makingCharges = '',
    this.ratePerGram = '',
    this.deliveryTimeframe = '',
    this.warrantyTerms = '',
    this.vendorNote = '',
    List<String>? mediaKeys,
  }) : mediaKeys = List<String>.from(mediaKeys ?? const []);

  String offeredPrice;
  String weightGrams;
  Karat purityKarat;
  String makingCharges;
  String ratePerGram;
  String deliveryTimeframe;
  String warrantyTerms;
  String vendorNote;
  final List<String> mediaKeys;

  OfferTermsInput toInput() => OfferTermsInput(
        offeredPrice: offeredPrice.trim(),
        weightGrams: weightGrams.trim(),
        purityKarat: purityKarat == Karat.unknown ? '22K' : purityKarat.wire,
        makingCharges: makingCharges.trim().isEmpty ? null : makingCharges.trim(),
        ratePerGram: ratePerGram.trim().isEmpty ? null : ratePerGram.trim(),
        deliveryTimeframe:
            deliveryTimeframe.trim().isEmpty ? null : deliveryTimeframe.trim(),
        warrantyTerms:
            warrantyTerms.trim().isEmpty ? null : warrantyTerms.trim(),
        vendorNote: vendorNote.trim().isEmpty ? null : vendorNote.trim(),
        mediaKeys: List<String>.from(mediaKeys),
      );

  factory OfferTermsDraft.fromTerms(OfferTerms terms) => OfferTermsDraft(
        offeredPrice: terms.offeredPrice,
        weightGrams: terms.weightGrams,
        purityKarat: Karat.parse(terms.purityKarat),
        makingCharges: terms.makingCharges ?? '',
        ratePerGram: terms.ratePerGram ?? '',
        deliveryTimeframe: terms.deliveryTimeframe ?? '',
        warrantyTerms: terms.warrantyTerms ?? '',
        vendorNote: terms.vendorNote ?? '',
        mediaKeys: terms.media.map((m) => m.key).toList(growable: false),
      );
}

/// SH-OFF-02 — Offer terms form fields.
class OfferTermsForm extends StatelessWidget {
  const OfferTermsForm({
    super.key,
    required this.draft,
    required this.onChanged,
    this.requestExpiresAt,
    this.now,
    this.showMediaHint = true,
    this.mediaSlot,
  });

  final OfferTermsDraft draft;
  final VoidCallback onChanged;
  final DateTime? requestExpiresAt;
  final DateTime? now;
  final bool showMediaHint;
  final Widget? mediaSlot;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KhNumericField(
          key: const Key('offer-price-field'),
          label: l10n?.offerPriceLabel ?? 'Offered price',
          unit: 'AED',
          initialValue: draft.offeredPrice,
          min: 0.01,
          onChanged: (v) {
            draft.offeredPrice = v?.toStringAsFixed(2) ?? '';
            onChanged();
          },
        ),
        SizedBox(height: tokens.space.md),
        KhNumericField(
          key: const Key('offer-weight-field'),
          label: 'Gold weight (grams)',
          unit: 'g',
          initialValue: draft.weightGrams,
          min: 0.01,
          onChanged: (v) {
            draft.weightGrams = v?.toStringAsFixed(2) ?? '';
            onChanged();
          },
        ),
        SizedBox(height: tokens.space.md),
        PurityPicker(
          label: l10n?.purity ?? 'Purity',
          value: draft.purityKarat == Karat.unknown ? Karat.k22 : draft.purityKarat,
          onChanged: (k) {
            draft.purityKarat = k;
            onChanged();
          },
        ),
        SizedBox(height: tokens.space.md),
        KhNumericField(
          label: l10n?.offerMakingChargesLabel ?? 'Making charges (optional)',
          unit: 'AED',
          initialValue: draft.makingCharges,
          min: 0,
          onChanged: (v) {
            draft.makingCharges = v?.toStringAsFixed(2) ?? '';
            onChanged();
          },
        ),
        SizedBox(height: tokens.space.md),
        KhNumericField(
          label: l10n?.offerRatePerGramLabel ?? 'Rate per gram (optional)',
          unit: 'AED/g',
          initialValue: draft.ratePerGram,
          min: 0.01,
          onChanged: (v) {
            draft.ratePerGram = v?.toStringAsFixed(2) ?? '';
            onChanged();
          },
        ),
        SizedBox(height: tokens.space.md),
        KhTextField(
          label: l10n?.offerDeliveryLabel ?? 'Delivery / readiness',
          initialValue: draft.deliveryTimeframe,
          onChanged: (v) {
            draft.deliveryTimeframe = v;
            onChanged();
          },
        ),
        SizedBox(height: tokens.space.md),
        KhTextField(
          label: l10n?.offerWarrantyLabel ?? 'Warranty / buy-back terms',
          initialValue: draft.warrantyTerms,
          maxLines: 3,
          onChanged: (v) {
            draft.warrantyTerms = v;
            onChanged();
          },
        ),
        SizedBox(height: tokens.space.md),
        KhTextField(
          label: l10n?.offerNoteLabel ?? 'Note (no contact details)',
          initialValue: draft.vendorNote,
          maxLines: 4,
          onChanged: (v) {
            draft.vendorNote = v;
            onChanged();
          },
        ),
        if (mediaSlot != null) ...[
          SizedBox(height: tokens.space.md),
          mediaSlot!,
        ] else if (showMediaHint) ...[
          SizedBox(height: tokens.space.md),
          Text(
            l10n?.offerImagesHint ?? 'Up to 3 supporting images (optional).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// SH-OFF-04 — read-only terms snapshot (full attributes + images).
class OfferTermsReadOnly extends StatelessWidget {
  const OfferTermsReadOnly({
    super.key,
    required this.terms,
    this.expiresAt,
  });

  final OfferTerms terms;
  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final price = double.tryParse(terms.offeredPrice) ?? 0;

    Widget row(String label, String value) => Padding(
          padding: EdgeInsets.only(bottom: tokens.space.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.65),
                  ),
                ),
              ),
              Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
            ],
          ),
        );

    return Card(
      key: const Key('offer-terms-readonly'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoneyDisplay(amount: price, highlight: true),
            SizedBox(height: tokens.space.sm),
            if (terms.purityKarat.isNotEmpty)
              row(
                l10n?.purity ?? 'Purity',
                terms.purityKarat,
              ),
            if (terms.weightGrams.isNotEmpty)
              row(
                'Gold weight',
                '${terms.weightGrams}g',
              ),
            if (terms.makingCharges != null && terms.makingCharges!.isNotEmpty)
              row(
                l10n?.offerMakingChargesLabel ?? 'Making charges',
                '${terms.makingCharges} AED',
              ),
            if (terms.ratePerGram != null && terms.ratePerGram!.isNotEmpty)
              row(
                l10n?.offerRatePerGramLabel ?? 'Rate / g',
                '${terms.ratePerGram} AED/g',
              ),
            if (terms.deliveryTimeframe != null &&
                terms.deliveryTimeframe!.isNotEmpty)
              row(
                l10n?.offerDeliveryLabel ?? 'Delivery',
                terms.deliveryTimeframe!,
              ),
            if (terms.warrantyTerms != null && terms.warrantyTerms!.isNotEmpty)
              row(
                l10n?.offerWarrantyLabel ?? 'Warranty',
                terms.warrantyTerms!,
              ),
            if (terms.vendorNote != null && terms.vendorNote!.isNotEmpty)
              row(l10n?.offerNoteLabel ?? 'Note', terms.vendorNote!),
            if (terms.media.isNotEmpty) ...[
              SizedBox(height: tokens.space.sm),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  key: const Key('offer-terms-media'),
                  scrollDirection: Axis.horizontal,
                  itemCount: terms.media.length,
                  separatorBuilder: (_, __) => SizedBox(width: tokens.space.xs),
                  itemBuilder: (context, i) {
                    final ref = terms.media[i];
                    final url = ref.displayUrl ?? ref.thumbnailUrl ?? ref.key;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: tokens.ink.withValues(alpha: 0.06),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: tokens.ink.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (expiresAt != null) ...[
              SizedBox(height: tokens.space.sm),
              ExpiryCountdown(expiresAt: expiresAt!),
            ],
          ],
        ),
      ),
    );
  }
}
