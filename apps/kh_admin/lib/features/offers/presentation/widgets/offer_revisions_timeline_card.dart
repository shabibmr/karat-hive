import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_formatters.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Revisions history timeline card (FR-VEN-014). Was `_RevisionsTimelineCard`.
class OfferRevisionsTimelineCard extends StatelessWidget {
  const OfferRevisionsTimelineCard({super.key, required this.revisions});

  final List<OfferRevisionItem> revisions;

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
                                '${l10n?.offersDetailRevisionOffered(offerFormatPrice(rev.offeredPrice)) ?? 'Offered: ${offerFormatPrice(rev.offeredPrice)}'}${rev.makingCharges != null ? (l10n?.offersDetailRevisionMakingSuffix(offerFormatPrice(rev.makingCharges!)) ?? ' (Making: ${offerFormatPrice(rev.makingCharges!)})') : ''}',
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
                              if (rev.vendorNote != null &&
                                  rev.vendorNote!.isNotEmpty)
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
                          offerFormatDate(rev.revisedAt),
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
