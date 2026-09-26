import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/src/expiry_countdown.dart';
import 'package:kh_ui_domain/src/money_display.dart';
import 'package:kh_ui_domain/src/relative_time_label.dart';
import 'package:kh_ui_domain/src/vendor_request_card.dart';

/// View mode for [RequestSummaryCard] per SH-REQ-01 / Architecture-Frontend §4.3.
enum RequestSummaryCardView {
  owner,
  vendor,
}

/// SH-REQ-01 — Request summary card (unified owner and vendor variants).
///
/// In owner view:
/// - Takes [RequestForCustomer] with zero vendor identity fields.
/// - Shows reference, state chip, direction, category/region, weight, budget,
///   offer count (with unread offer marker when present), and expiry countdown.
///
/// In vendor view:
/// - Delegates to / renders vendor presentation with customer identity masked via [MaskedPartyLabel].
class RequestSummaryCard extends StatelessWidget {
  const RequestSummaryCard.owner({
    super.key,
    required RequestForCustomer request,
    this.onTap,
  })  : view = RequestSummaryCardView.owner,
        ownerRequest = request,
        vendorRequest = null;

  const RequestSummaryCard.vendor({
    super.key,
    required VendorRequestItem request,
    this.onTap,
  })  : view = RequestSummaryCardView.vendor,
        ownerRequest = null,
        vendorRequest = request;

  const RequestSummaryCard({
    super.key,
    required this.view,
    this.ownerRequest,
    this.vendorRequest,
    this.onTap,
  }) : assert(
          (view == RequestSummaryCardView.owner && ownerRequest != null) ||
              (view == RequestSummaryCardView.vendor && vendorRequest != null),
          'ownerRequest must be provided for owner view; vendorRequest for vendor view',
        );

  final RequestSummaryCardView view;
  final RequestForCustomer? ownerRequest;
  final VendorRequestItem? vendorRequest;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (view == RequestSummaryCardView.vendor && vendorRequest != null) {
      return VendorRequestCard(item: vendorRequest!, onTap: onTap);
    }
    return OwnerRequestCard(request: ownerRequest!, onTap: onTap);
  }
}

/// Owner variant of SH-REQ-01 for Customer home / manage flows (CUS-S02, CUS-S10).
/// Strictly accepts [RequestForCustomer] — no vendor identity is exposed or parsed.
class OwnerRequestCard extends StatelessWidget {
  const OwnerRequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  final RequestForCustomer request;
  final VoidCallback? onTap;

  static KhStatusTone _stateTone(RequestState state) => switch (state) {
        RequestState.draft => KhStatusTone.neutral,
        RequestState.published => KhStatusTone.accent,
        RequestState.accepted => KhStatusTone.success,
        RequestState.closed => KhStatusTone.neutral,
        RequestState.expired => KhStatusTone.neutral,
        RequestState.cancelled => KhStatusTone.danger,
        RequestState.removed => KhStatusTone.danger,
        RequestState.unknown => KhStatusTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final catName = request.category.name(locale);
    final title = request.displayTitle(
      locale: locale,
      fallback: l10n?.requestFallback ?? 'Request',
    );

    final unreadOffers = request.unreadOfferCount ?? 0;
    final hasUnreadOffers = unreadOffers > 0;

    final firstMedia = request.media.isEmpty ? null : request.media.first;
    final imageUrl = firstMedia?.thumbnailUrl ?? firstMedia?.displayUrl;

    final budgetMinVal = double.tryParse(request.budgetMin ?? '');
    final budgetMaxVal = double.tryParse(request.budgetMax ?? '');

    return Card(
      key: const Key('owner-request-card'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(
          color: hasUnreadOffers
              ? tokens.gold
              : tokens.ink.withValues(alpha: 0.12),
          width: hasUnreadOffers ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(tokens.radius.md),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: KhNetworkImage(
                    url: imageUrl,
                    contentType: firstMedia!.contentType,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(tokens.space.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _Tag(
                                  text: request.direction == Direction.sell
                                      ? 'SELL'
                                      : 'BUY',
                                  color: request.direction == Direction.sell
                                      ? tokens.danger
                                      : tokens.gold,
                                ),
                                if (catName.isNotEmpty)
                                  _Tag(
                                    text: catName,
                                    color: tokens.ink,
                                  ),
                                if (request.region.name(locale).isNotEmpty)
                                  _Tag(
                                    text: request.region.name(locale),
                                    color: tokens.ink.withValues(alpha: 0.7),
                                  ),
                                if (request.purityKarat != null &&
                                    request.purityKarat != Karat.unknown)
                                  _Tag(
                                    text: request.purityKarat!.wire,
                                    color: tokens.gold,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      KhStatusChip(
                        label: request.state.wire,
                        tone: _stateTone(request.state),
                        compact: true,
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.space.sm),

                  Row(
                    children: [
                      if (request.weightGrams != null &&
                          request.weightGrams!.isNotEmpty) ...[
                        Icon(
                          Icons.scale_outlined,
                          size: 14,
                          color: tokens.ink.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${request.weightGrams}g${request.weightIsApproximate ? ' (~)' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: tokens.ink,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (budgetMinVal != null || budgetMaxVal != null) ...[
                        Icon(
                          Icons.payments_outlined,
                          size: 14,
                          color: tokens.ink.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        _OwnerBudgetLabel(
                          min: budgetMinVal,
                          max: budgetMaxVal,
                          flexible: request.budgetIsFlexible,
                        ),
                      ],
                      const Spacer(),
                      if (request.publishedAt != null)
                        RelativeTimeLabel(at: request.publishedAt!),
                    ],
                  ),
                  SizedBox(height: tokens.space.sm),

                  Row(
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 14,
                        color: tokens.ink.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${request.offerCount} ${request.offerCount == 1 ? 'Offer' : 'Offers'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tokens.ink,
                        ),
                      ),
                      if (hasUnreadOffers) ...[
                        const SizedBox(width: 6),
                        KhBadge(
                          key: const Key('unread-offers-badge'),
                          count: unreadOffers,
                        ),
                      ],
                      const Spacer(),
                      if (request.expiresAt != null)
                        ExpiryCountdown(expiresAt: request.expiresAt!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerBudgetLabel extends StatelessWidget {
  const _OwnerBudgetLabel({
    required this.min,
    required this.max,
    required this.flexible,
  });

  final double? min;
  final double? max;
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (min != null && max != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyDisplay(amount: min!),
          Text(l10n?.budgetRangeSeparator ?? ' - '),
          MoneyDisplay(amount: max!),
          if (flexible) const Text(' (flex)'),
        ],
      );
    }
    if (min != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n?.budgetFrom ?? 'From '),
          MoneyDisplay(amount: min!),
          if (flexible) const Text(' (flex)'),
        ],
      );
    }
    if (max != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n?.budgetUpTo ?? 'Up to '),
          MoneyDisplay(amount: max!),
          if (flexible) const Text(' (flex)'),
        ],
      );
    }
    return Text(l10n?.openBudget ?? 'Open Budget');
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
