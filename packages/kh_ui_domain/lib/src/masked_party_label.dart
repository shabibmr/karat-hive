import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

/// SH-ID-07 — Trust signal badge / row.
/// Displays rating score, count, and completed deal count.
class TrustSignalBadge extends StatelessWidget {
  const TrustSignalBadge({
    super.key,
    this.rating,
    this.dealCount,
  });

  final RatingSummary? rating;
  final int? dealCount;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasRating = rating != null && rating!.hasScore;
    final hasDeals = dealCount != null && dealCount! > 0;

    if (!hasRating && !hasDeals) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasRating) ...[
          Icon(Icons.star_rounded, size: 16, color: tokens.gold),
          const SizedBox(width: 2),
          Text(
            rating!.scoreString,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tokens.ink,
            ),
          ),
          if (rating!.count != null && rating!.count! > 0) ...[
            const SizedBox(width: 2),
            Text(
              '(${rating!.count})',
              style: TextStyle(
                fontSize: 11,
                color: tokens.ink.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
        if (hasRating && hasDeals) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '•',
              style: TextStyle(color: tokens.ink.withValues(alpha: 0.4)),
            ),
          ),
        ],
        if (hasDeals) ...[
          Icon(Icons.handshake_outlined, size: 14, color: tokens.ink.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            '$dealCount deals',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: tokens.ink.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}

/// SH-ID-01 — Masked Party Label (Visual expression of BR-006 / AD-FE-07).
///
/// Accepts strictly [MaskedParty]. Contains no name, mobile, or address fields.
/// Mistakes of leaking customer identity are unrepresentable by type design.
class MaskedPartyLabel extends StatelessWidget {
  const MaskedPartyLabel({
    super.key,
    required this.party,
    this.compact = false,
  });

  final MaskedParty party;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final pseudonym = party.displayPseudonym;
    final region = party.regionName;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: compact ? 12 : 16,
          backgroundColor: tokens.gold.withValues(alpha: 0.2),
          child: Icon(
            Icons.person_outline,
            size: compact ? 14 : 18,
            color: tokens.ink,
          ),
        ),
        SizedBox(width: tokens.space.xs),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pseudonym,
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: tokens.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (region != null && region.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      '($region)',
                      style: TextStyle(
                        fontSize: compact ? 11 : 12,
                        color: tokens.ink.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
              if (!compact && (party.rating != null || party.dealCount > 0)) ...[
                const SizedBox(height: 2),
                TrustSignalBadge(
                  rating: party.rating,
                  dealCount: party.dealCount,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
