import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_formatters.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_row.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Commercial terms, notes & attachments card. Was `_CommercialTermsCard`.
class OfferCommercialTermsCard extends StatelessWidget {
  const OfferCommercialTermsCard({super.key, required this.detail});

  final OfferDetail detail;

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
          OfferDetailRow(
            label: l10n?.offersDetailLabelDelivery ??
                'Delivery / Readiness Timeframe',
            value: detail.deliveryTimeframe ??
                (l10n?.offersDetailDeliveryDefault ??
                    'Immediate dispatch / collection'),
          ),
          OfferDetailRow(
            label:
                l10n?.offersDetailLabelWarranty ?? 'Warranty / Buy-Back Terms',
            value: detail.warrantyTerms ??
                (l10n?.offersDetailWarrantyDefault ??
                    'Standard UAE jeweller guarantee'),
          ),
          OfferDetailRow(
            label: l10n?.offersDetailLabelVendorNote ?? 'Vendor Note',
            value: detail.vendorNote ??
                (l10n?.offersDetailVendorNoteDefault ??
                    'No free-text note provided by vendor.'),
          ),
          OfferDetailRow(
            label: l10n?.offersDetailLabelValidityExpiry ??
                'Offer Validity & Expiry',
            value: l10n?.offersDetailValidityExpiryValue(
                  detail.validityHours ?? 24,
                  offerFormatDate(detail.expiresAt),
                ) ??
                '${detail.validityHours ?? 24} hours · Expiry: ${offerFormatDate(detail.expiresAt)}',
          ),
          if (detail.declineReason != null && detail.declineReason!.isNotEmpty)
            OfferDetailRow(
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
