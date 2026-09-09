import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_formatters.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Pricing breakdown card. Was `_PricingBreakdownCard`.
class OfferPricingBreakdownCard extends StatelessWidget {
  const OfferPricingBreakdownCard({super.key, required this.detail});

  final OfferDetail detail;

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
                  value: offerFormatPrice(goldPrice),
                  hint: ratePerGram != null
                      ? (l10n?.offersDetailPricingGoldHintRate(
                              offerFormatPrice(ratePerGram)) ??
                          'Base gold price (${offerFormatPrice(ratePerGram)}/g)')
                      : (l10n?.offersDetailPricingGoldHint ??
                          'Base gold price component'),
                ),
                const Divider(),
                _PricingRow(
                  label: l10n?.offersDetailPricingMaking ??
                      'Making / Crafting Charges',
                  value: makingCharge != null
                      ? offerFormatPrice(makingCharge)
                      : '—',
                  hint: l10n?.offersDetailPricingMakingHint ??
                      'Labour and artistry charges',
                ),
                const Divider(),
                _PricingRow(
                  label: l10n?.offersDetailPricingVat ??
                      'Value Added Tax (VAT 5%)',
                  value: offerFormatPrice(vat),
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
                      offerFormatPrice(total),
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

/// One line of the pricing breakdown. Was `_PricingRow`.
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
