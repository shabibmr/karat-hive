import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_formatters.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_row.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_domain/kh_domain.dart' show MaskedParty, RevealedParty;

/// Parent request reference card. Was `_ParentRequestCard`.
class OfferParentRequestCard extends StatelessWidget {
  const OfferParentRequestCard({super.key, required this.request});

  final OfferParentRequestSummary? request;

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
                l10n?.offersDetailParentRequestTitle ??
                    'Parent Request Reference',
                style: kh.typography.title.copyWith(
                  color: kh.colors.textPrimary,
                  fontSize: 16.0,
                ),
              ),
              if (request != null)
                ElevatedButton.icon(
                  key: const Key('parent-request-link'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    minimumSize: const Size(80.0, 32.0),
                  ),
                  onPressed: () => context.go('/requests/${request!.id}'),
                  icon: const Icon(Icons.open_in_new, size: 14.0),
                  label: Text(
                    l10n?.offersDetailOpenRequest ?? 'Open Request',
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          if (request == null)
            Text(
              l10n?.offersDetailNoParentRequest ?? 'No parent request linked.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textMuted,
                fontSize: 13.0,
              ),
            )
          else ...[
            OfferDetailRow(
              label: l10n?.offersDetailLabelRequestReference ??
                  'Request Reference',
              value: request!.reference ?? request!.id,
              isStrong: true,
            ),
            if (request!.requestType != null)
              OfferDetailRow(
                label: l10n?.offersDetailLabelRequestType ?? 'Request Type',
                value: request!.requestType!.displayName,
              ),
            if (request!.customer case final RevealedParty revealed)
              OfferDetailRow(
                label: l10n?.offersDetailLabelCustomerMobile ??
                    'Customer Name & Mobile',
                value: [
                  if (revealed.displayName.isNotEmpty) revealed.displayName,
                  if (revealed.mobile.e164.isNotEmpty) revealed.mobile.e164,
                ].join(' · '),
              )
            else if (request!.customer case final MaskedParty masked)
              OfferDetailRow(
                label: l10n?.offersDetailLabelCustomerMobile ?? 'Customer',
                value: masked.displayPseudonym,
              ),
            if (request!.categoryName != null)
              OfferDetailRow(
                label: l10n?.offersDetailLabelCategory ?? 'Category',
                value: request!.categoryName!,
              ),
            if (request!.regionName != null)
              OfferDetailRow(
                label: l10n?.offersDetailLabelRegion ?? 'Region',
                value: request!.regionName!,
              ),
            if (request!.indicativeValue != null)
              OfferDetailRow(
                label: l10n?.offersDetailLabelIndicativeBudget ??
                    'Indicative Budget',
                value: offerFormatPrice(request!.indicativeValue!),
              ),
            if (request!.notes != null && request!.notes!.isNotEmpty)
              OfferDetailRow(
                label: l10n?.offersDetailLabelRequestNotes ?? 'Request Notes',
                value: request!.notes!,
              ),
          ],
        ],
      ),
    );
  }
}
