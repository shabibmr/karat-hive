import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/model/offer_enums.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_formatters.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// State transitions timeline card. Was `_StateTransitionsCard`.
class OfferStateTransitionsCard extends StatelessWidget {
  const OfferStateTransitionsCard({
    super.key,
    required this.transitions,
    required this.currentState,
  });

  final List<OfferStateTransitionItem> transitions;
  final OfferState currentState;

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
            l10n?.offersDetailTransitionsTitle ?? 'State Transitions Timeline',
            style: kh.typography.title.copyWith(
              color: kh.colors.textPrimary,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          if (transitions.isEmpty)
            Text(
              l10n?.offersDetailNoTransitions(
                      currentState.displayName.toUpperCase()) ??
                  'Offer is in ${currentState.displayName.toUpperCase()} state. No state transition audit recorded.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textMuted,
                fontSize: 13.0,
              ),
            )
          else
            Column(
              children: [
                for (final item in transitions)
                  Padding(
                    padding: EdgeInsets.only(bottom: kh.spacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          size: 18.0,
                          color: kh.colors.goldPrimary,
                        ),
                        SizedBox(width: kh.spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.fromState != null ? '${item.fromState} → ' : ''}${item.toState}',
                                style: kh.typography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.0,
                                ),
                              ),
                              if (item.actor != null || item.reason != null)
                                Text(
                                  [
                                    if (item.actor != null)
                                      l10n?.offersDetailTransitionActor(
                                              item.actor!) ??
                                          'By: ${item.actor}',
                                    if (item.reason != null)
                                      l10n?.offersDetailTransitionReason(
                                              item.reason!) ??
                                          'Reason: ${item.reason}',
                                  ].join(' · '),
                                  style: kh.typography.caption.copyWith(
                                    color: kh.colors.textMuted,
                                    fontSize: 11.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          offerFormatDate(item.transitionedAt),
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
