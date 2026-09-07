import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

/// CU-11 / SH-OFF-01 — Offer row with masked Vendor only.
class CustomerOfferRow extends StatelessWidget {
  const CustomerOfferRow({
    super.key,
    required this.offer,
    required this.onOpen,
    this.selected = false,
    this.onToggleSelect,
  });

  final OfferForCustomer offer;
  final VoidCallback onOpen;
  final bool selected;
  final VoidCallback? onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final unread = offer.viewedByCustomerAt == null &&
        offer.state == OfferState.pending;
    final price = num.tryParse(offer.terms.offeredPrice) ?? 0;

    return Card(
      key: Key('offer-row-${offer.id}'),
      margin: EdgeInsets.only(bottom: tokens.space.md),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (onToggleSelect != null)
                    Checkbox(
                      key: Key('compare-check-${offer.id}'),
                      value: selected,
                      onChanged: (_) => onToggleSelect!(),
                    ),
                  Expanded(
                    child: MaskedPartyLabel(party: offer.vendor),
                  ),
                  if (unread)
                    KhBadge(
                      count: 1,
                      child: const SizedBox(width: 8, height: 8),
                    ),
                ],
              ),
              SizedBox(height: tokens.space.sm),
              MoneyDisplay(
                amount: price,
                highlight: true,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: tokens.space.xs),
              Row(
                children: [
                  Expanded(
                    child: RelativeTimeLabel(at: offer.submittedAt),
                  ),
                  ExpiryCountdown(expiresAt: offer.expiresAt),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
