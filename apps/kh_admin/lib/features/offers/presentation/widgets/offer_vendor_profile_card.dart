import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_row.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Unmasked vendor profile card. Was `_VendorProfileCard`.
class OfferVendorProfileCard extends StatelessWidget {
  const OfferVendorProfileCard({super.key, required this.vendor});

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
            OfferDetailRow(
              label: l10n?.offersDetailLabelLegalName ?? 'Legal Business Name',
              value: vendor!.legalBusinessName,
              isStrong: true,
            ),
            if (vendor!.tradingName != null &&
                vendor!.tradingName!.isNotEmpty &&
                vendor!.tradingName != vendor!.legalBusinessName)
              OfferDetailRow(
                label: l10n?.offersDetailLabelTradingName ?? 'Trading Name',
                value: vendor!.tradingName!,
              ),
            if (vendor!.tradeLicenceNumber != null)
              OfferDetailRow(
                label: l10n?.offersDetailLabelTradeLicence ?? 'Trade Licence',
                value: vendor!.tradeLicenceNumber!,
              ),
            if (vendor!.contactPersonName != null ||
                vendor!.mobileNumber != null)
              OfferDetailRow(
                label: l10n?.offersDetailLabelContactMobile ??
                    'Contact Person & Mobile',
                value: [
                  if (vendor!.contactPersonName != null)
                    vendor!.contactPersonName!,
                  if (vendor!.mobileNumber != null) vendor!.mobileNumber!,
                ].join(' · '),
              ),
            if (vendor!.email != null)
              OfferDetailRow(
                label: l10n?.offersDetailLabelBusinessEmail ?? 'Business Email',
                value: vendor!.email!,
              ),
            if (vendor!.rating != null)
              OfferDetailRow(
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
