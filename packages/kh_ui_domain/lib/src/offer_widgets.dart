import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import 'expiry_countdown.dart';
import 'money_display.dart';

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

/// SH-OFF-01 — Offer summary row for My Offers lists.
class OfferSummaryCard extends StatelessWidget {
  const OfferSummaryCard({
    super.key,
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
    final title = summary?.reference ??
        summary?.categoryName ??
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
                ExpiryCountdown(expiresAt: offer.expiresAt),
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
    this.validityHours = 24,
    this.makingCharges = '',
    this.ratePerGram = '',
    this.deliveryTimeframe = '',
    this.warrantyTerms = '',
    this.vendorNote = '',
    List<String>? mediaKeys,
  }) : mediaKeys = List<String>.from(mediaKeys ?? const []);

  String offeredPrice;
  int validityHours;
  String makingCharges;
  String ratePerGram;
  String deliveryTimeframe;
  String warrantyTerms;
  String vendorNote;
  final List<String> mediaKeys;

  OfferTermsInput toInput() => OfferTermsInput(
        offeredPrice: offeredPrice.trim(),
        validityHours: validityHours,
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
        validityHours: terms.validityHours == 0 ? 24 : terms.validityHours,
        makingCharges: terms.makingCharges ?? '',
        ratePerGram: terms.ratePerGram ?? '',
        deliveryTimeframe: terms.deliveryTimeframe ?? '',
        warrantyTerms: terms.warrantyTerms ?? '',
        vendorNote: terms.vendorNote ?? '',
        mediaKeys: terms.media.map((m) => m.key).toList(growable: false),
      );
}

/// SH-OFF-03 — validity picker from platform-config (never hard-coded).
class OfferValidityPicker extends StatelessWidget {
  const OfferValidityPicker({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.requestExpiresAt,
    this.now,
    this.label,
  });

  final List<int> options;
  final int value;
  final ValueChanged<int> onChanged;
  final DateTime? requestExpiresAt;
  final DateTime? now;
  final String? label;

  List<int> get _allowed {
    final clock = now ?? DateTime.now().toUtc();
    if (requestExpiresAt == null) return options;
    final remainingHours =
        requestExpiresAt!.toUtc().difference(clock).inMinutes / 60.0;
    final filtered = options.where((h) => h <= remainingHours + 0.01).toList();
    return filtered.isEmpty ? options : filtered;
  }

  DateTime? absoluteExpiryFor(int hours) {
    final clock = now ?? DateTime.now().toUtc();
    final nominal = clock.add(Duration(hours: hours));
    final req = requestExpiresAt?.toUtc();
    if (req == null) return nominal;
    return nominal.isAfter(req) ? req : nominal;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    final allowed = _allowed;
    final selected = allowed.contains(value) ? value : allowed.first;
    final absolute = absoluteExpiryFor(selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KhSelectField<int>(
          label: label ?? l10n?.offerValidityLabel ?? 'Validity',
          value: selected,
          options: [
            for (final h in allowed)
              KhSelectOption(
                value: h,
                label: l10n?.offerValidityHours(h) ?? '$h hours',
              ),
          ],
          onChanged: onChanged,
        ),
        if (absolute != null) ...[
          SizedBox(height: tokens.space.xs),
          Text(
            l10n?.offerAbsoluteExpiry(absolute.toLocal().toString()) ??
                'Expires at ${absolute.toLocal()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.ink.withValues(alpha: 0.7),
                ),
          ),
        ],
      ],
    );
  }
}

/// SH-OFF-02 — Offer terms form fields.
class OfferTermsForm extends StatelessWidget {
  const OfferTermsForm({
    super.key,
    required this.draft,
    required this.validityOptions,
    required this.onChanged,
    this.requestExpiresAt,
    this.now,
    this.showMediaHint = true,
    this.mediaSlot,
  });

  final OfferTermsDraft draft;
  final List<int> validityOptions;
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
        OfferValidityPicker(
          options: validityOptions,
          value: draft.validityHours,
          requestExpiresAt: requestExpiresAt,
          now: now,
          onChanged: (h) {
            draft.validityHours = h;
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

/// SH-OFF-04 — read-only terms snapshot.
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
            row(
              l10n?.offerValidityLabel ?? 'Validity',
              l10n?.offerValidityHours(terms.validityHours) ??
                  '${terms.validityHours} hours',
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
