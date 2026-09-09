import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/features/connections/model/connection_detail.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_detail_formatters.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_info_row.dart';

/// Accepted-offer-terms card. Was
/// `_ConnectionDetailScreenState._buildAcceptedOfferCard` (TR-S2-14).
class ConnectionAcceptedOfferCard extends StatelessWidget {
  const ConnectionAcceptedOfferCard({super.key, required this.detail});

  final ConnectionDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final offer = detail.offer;
    final vendor = detail.vendor;

    return Container(
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(
          color: kh.colors.borderSubtle,
          width: kh.shapes.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: kh.colors.goldPrimary, size: 20),
              SizedBox(width: kh.spacing.xs),
              Text('Accepted Offer Terms', style: kh.typography.title),
              if (offer?.reference != null) ...[
                const Spacer(),
                Text(
                  offer!.reference!,
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.goldPrimary),
                ),
              ],
            ],
          ),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.lg * 2),
          ConnectionInfoRow(label: 'Vendor Legal Name', value: vendor?.legalBusinessName ?? '—'),
          if (vendor?.tradingName != null && vendor!.tradingName!.isNotEmpty)
            ConnectionInfoRow(label: 'Trading Name', value: vendor.tradingName!),
          ConnectionInfoRow(label: 'Vendor Email', value: vendor?.email ?? '—'),
          ConnectionInfoRow(label: 'Vendor Mobile', value: vendor?.mobileNumber ?? '—'),
          if (vendor?.tradeLicenceNumber != null)
            ConnectionInfoRow(label: 'Trade Licence', value: vendor!.tradeLicenceNumber!),
          if (vendor?.rating != null)
            ConnectionInfoRow(
                label: 'Aggregate Rating',
                value: '★ ${vendor!.rating!.toStringAsFixed(1)}'),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.md * 2),
          ConnectionInfoRow(
            label: 'Agreed Price',
            value: offer != null ? connectionFormatPrice(offer.agreedPriceAed) : '—',
            isHighlighted: true,
          ),
          if (offer?.makingCharges != null)
            ConnectionInfoRow(
                label: 'Making Charges',
                value: connectionFormatPrice(offer!.makingCharges!)),
          if (offer?.ratePerGram != null)
            ConnectionInfoRow(
                label: 'Rate Per Gram',
                value: connectionFormatPrice(offer!.ratePerGram!)),
          if (offer?.validityHours != null)
            ConnectionInfoRow(
                label: 'Offer Validity', value: '${offer!.validityHours} hours'),
          if (offer?.deliveryTimeframe != null)
            ConnectionInfoRow(
                label: 'Delivery Timeframe', value: offer!.deliveryTimeframe!),
          if (offer?.warrantyTerms != null)
            ConnectionInfoRow(label: 'Warranty Terms', value: offer!.warrantyTerms!),
          if (offer?.vendorNote != null && offer!.vendorNote!.isNotEmpty) ...[
            SizedBox(height: kh.spacing.xs),
            const KhSectionLabel('VENDOR NOTE'),
            SizedBox(height: kh.spacing.xxs),
            Text(
              offer.vendorNote!,
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
