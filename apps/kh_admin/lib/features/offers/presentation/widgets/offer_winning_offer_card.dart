import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_formatters.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// "Competing offer won this request" banner. Was `_WinningOfferCard`.
class OfferWinningOfferCard extends StatelessWidget {
  const OfferWinningOfferCard({super.key, required this.detail});

  final OfferDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final vendorPart = detail.winningVendorName != null
        ? (l10n?.offersDetailCompetingWonBy(detail.winningVendorName!) ??
            ' by ${detail.winningVendorName}')
        : '';
    final pricePart = detail.winningOfferPrice != null
        ? (l10n?.offersDetailCompetingWonFor(
                offerFormatPrice(detail.winningOfferPrice!)) ??
            ' for ${offerFormatPrice(detail.winningOfferPrice!)}')
        : '';

    return Container(
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.gold400.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(
          color: kh.colors.gold400.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(kh.spacing.sm),
            decoration: BoxDecoration(
              color: kh.colors.gold400.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: kh.colors.goldPrimary,
              size: 28.0,
            ),
          ),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.offersDetailCompetingWonTitle ??
                      'COMPETING OFFER WON THIS REQUEST',
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.goldPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 11.0,
                  ),
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
                  l10n?.offersDetailCompetingWonBody(
                        detail.winningOfferReference ??
                            detail.winningOfferId ??
                            '',
                        vendorPart,
                        pricePart,
                      ) ??
                      'Customer selected winning offer ${detail.winningOfferReference ?? detail.winningOfferId ?? ''}$vendorPart$pricePart.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textPrimary,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
          ),
          if (detail.winningOfferId != null &&
              detail.winningOfferId!.isNotEmpty) ...[
            SizedBox(width: kh.spacing.md),
            ElevatedButton(
              key: const Key('inspect-winning-offer-button'),
              onPressed: () => context.go('/offers/${detail.winningOfferId}'),
              child: Text(
                l10n?.offersDetailInspectWinning ?? 'Inspect Winning Offer',
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
