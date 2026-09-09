import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';

/// Pending offer-validity architecture-decision banner. Was
/// `_PlatformSettingsScreenState._buildOfferValidityNoticeBanner` (TR-S2-11).
class OfferValidityNoticeBanner extends StatelessWidget {
  const OfferValidityNoticeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Container(
      key: const Key('offer-validity-decision-banner'),
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.warning.withValues(alpha: 0.12),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(
          color: kh.colors.warning.withValues(alpha: 0.6),
          width: kh.shapes.cardBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: kh.colors.warning, size: 24),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ARCHITECTURE DECISION PENDING: OFFER VALIDITY MODEL',
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.warning,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: kh.spacing.xs),
                    const KhStatusChip(
                      label: 'PENDING DECISION',
                      tone: KhStatusTone.pending,
                      dense: true,
                    ),
                  ],
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
                  'Offer validity option-set is flagged pending the live product decision. '
                  'This portal follows FR-VEN-013 / AD-API-07 (12 / 24 / 48 hours) and will not invent 72h or 168h options from the stale entity dictionary. '
                  'Per BR-020, configuration modifications apply only to entities created after the change and do not retroactively rewrite live Requests or Offers.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
