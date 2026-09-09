import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/format/kh_formats.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_detail_row.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Received offers table card. Was `_buildOffersCard`.
class RequestOffersCard extends StatelessWidget {
  const RequestOffersCard({super.key, required this.detail});

  final RequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final currencyFormat = khNumberFormat;
    final dateFormat = khDateTimeFormat;

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
          KhSectionLabel(
              l10n?.requestsDetailOffersTitle(detail.offers.length) ??
                  'Received Offers (${detail.offers.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.offers.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoOffers ?? 'No offers submitted yet.',
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
              columns: [
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnVendor ?? 'Vendor', flex: 3),
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnPrice ?? 'Offered Price',
                    flex: 2),
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnStatus ?? 'Status', flex: 2),
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnSubmitted ?? 'Submitted',
                    flex: 2),
                KhTableColumn(
                    l10n?.requestsDetailOffersColumnTurnaround ?? 'Turnaround',
                    flex: 2),
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
                        tone: offerStateTone(offer.state),
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
                            ? (l10n?.requestsDetailOfferDays(
                                    offer.estimatedDays!) ??
                                '${offer.estimatedDays} days')
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
}
