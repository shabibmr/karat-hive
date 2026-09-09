import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/format/kh_formats.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_detail_row.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Commercial requirements & specifications card. Was `_buildSpecificationsCard`.
class RequestSpecificationsCard extends StatelessWidget {
  const RequestSpecificationsCard({super.key, required this.detail});

  final RequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final currencyFormat = khNumberFormat;

    return Container(
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              KhSectionLabel(l10n?.requestsDetailSpecsTitle ??
                  'Commercial Requirements & Specifications'),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: kh.colors.sapphire900,
                  borderRadius: kh.shapes.roundedSm,
                ),
                child: Text(
                  l10n?.requestsDetailSpecsReadOnly ??
                      'READ-ONLY FOR ADMIN (FR-ADM-018 AC3)',
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textMuted,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          RequestDetailRow(
              l10n?.requestsDetailLabelReferenceCode ?? 'Reference Code',
              detail.reference ?? '—'),
          RequestDetailRow(
              l10n?.requestsDetailLabelRequestType ?? 'Request Type',
              detail.requestType.label),
          RequestDetailRow(
              l10n?.requestsDetailLabelMarketDirection ?? 'Market Direction',
              '${detail.direction.label} (${detail.direction.name.toUpperCase()})'),
          RequestDetailRow(l10n?.requestsDetailLabelCategory ?? 'Category',
              detail.categoryName),
          RequestDetailRow(l10n?.requestsDetailLabelRegion ?? 'Region',
              detail.regionName),
          if (detail.ornamentType != null && detail.ornamentType!.isNotEmpty)
            RequestDetailRow(
                l10n?.requestsDetailLabelOrnamentType ?? 'Ornament Type',
                detail.ornamentType!),
          if (detail.purityKarat != null && detail.purityKarat!.isNotEmpty)
            RequestDetailRow(
                l10n?.requestsDetailLabelPurityKarat ?? 'Purity / Karat',
                detail.purityKarat!),
          if (detail.weightGrams != null)
            RequestDetailRow(
              l10n?.requestsDetailLabelWeight ?? 'Weight',
              detail.weightIsApproximate
                  ? (l10n?.requestsDetailWeightApproximate(
                          detail.weightGrams!.toStringAsFixed(2)) ??
                      '${detail.weightGrams!.toStringAsFixed(2)}g (Approximate)')
                  : (l10n?.requestsDetailWeightExact(
                          detail.weightGrams!.toStringAsFixed(2)) ??
                      '${detail.weightGrams!.toStringAsFixed(2)}g (Exact)'),
            ),
          if (detail.condition != null && detail.condition!.isNotEmpty)
            RequestDetailRow(
                l10n?.requestsDetailLabelCondition ?? 'Condition',
                detail.condition!),
          if (detail.denominationGrams != null)
            RequestDetailRow(
                l10n?.requestsDetailLabelDenomination ?? 'Denomination',
                '${detail.denominationGrams!.toStringAsFixed(2)}g'),
          if (detail.quantity != null)
            RequestDetailRow(
                l10n?.requestsDetailLabelQuantity ?? 'Quantity',
                l10n?.requestsDetailQuantityUnits(detail.quantity!) ??
                    '${detail.quantity} units'),
          if (detail.mintOrRefiner != null && detail.mintOrRefiner!.isNotEmpty)
            RequestDetailRow(
                l10n?.requestsDetailLabelMintRefiner ?? 'Mint / Refiner',
                detail.mintOrRefiner!),
          if (detail.indicativeValue != null)
            RequestDetailRow(
              l10n?.requestsDetailLabelIndicativeValue ?? 'Indicative Value',
              'AED ${currencyFormat.format(detail.indicativeValue)}',
              highlightGold: true,
            ),
          if (detail.budgetMin != null || detail.budgetMax != null)
            RequestDetailRow(
              l10n?.requestsDetailLabelCustomerBudget ?? 'Customer Budget',
              detail.budgetIsFlexible
                  ? (l10n?.requestsDetailBudgetValueFlexible(
                          currencyFormat.format(detail.budgetMin ?? 0),
                          currencyFormat.format(detail.budgetMax ?? 0)) ??
                      'AED ${currencyFormat.format(detail.budgetMin ?? 0)} – ${currencyFormat.format(detail.budgetMax ?? 0)} (Flexible)')
                  : (l10n?.requestsDetailBudgetValue(
                          currencyFormat.format(detail.budgetMin ?? 0),
                          currencyFormat.format(detail.budgetMax ?? 0)) ??
                      'AED ${currencyFormat.format(detail.budgetMin ?? 0)} – ${currencyFormat.format(detail.budgetMax ?? 0)}'),
            ),
          if (detail.notes != null && detail.notes!.isNotEmpty) ...[
            SizedBox(height: kh.spacing.sm),
            Text(
              l10n?.requestsDetailCustomerNotes ?? 'Customer Notes:',
              style: kh.typography.caption
                  .copyWith(color: kh.colors.textMuted, fontSize: 11.0),
            ),
            SizedBox(height: kh.spacing.xxs),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(kh.spacing.sm),
              decoration: BoxDecoration(
                color: kh.colors.backgroundSurface,
                borderRadius: kh.shapes.roundedSm,
                border: Border.all(color: kh.colors.borderSubtle),
              ),
              child: Text(
                detail.notes!,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
