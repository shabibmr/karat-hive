import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

import 'expiry_countdown.dart';
import 'masked_party_label.dart';

/// SH-REQ-01 — Request summary card (Vendor variant).
///
/// Customer identity is strictly masked via [MaskedPartyLabel].
/// Competitor prices are never displayed per BR-008.
class VendorRequestCard extends StatelessWidget {
  const VendorRequestCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final VendorRequestItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    final title = item.reference ?? item.categoryName ?? 'Request';
    final isUnread = !item.isViewed;

    return Card(
      elevation: 0,
      color: tokens.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(
          color: isUnread ? tokens.gold : tokens.border,
          width: isUnread ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header: Title + Category/Region tags + Unread dot ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (item.categoryName != null)
                              _Tag(text: item.categoryName!, color: tokens.ink),
                            if (item.regionName != null)
                              _Tag(text: item.regionName!, color: tokens.ink.withValues(alpha: 0.7)),
                            if (item.purityKarat != null)
                              _Tag(text: '${item.purityKarat}K', color: tokens.gold),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isUnread) ...[
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 4, left: 4),
                      decoration: BoxDecoration(
                        color: tokens.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: tokens.space.sm),

              // --- Spec summary: Weight + Budget ---
              Row(
                children: [
                  if (item.weightGrams != null) ...[
                    Icon(Icons.scale_outlined, size: 14, color: tokens.ink.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      '${item.weightGrams}g',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: tokens.ink,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (item.budgetMin != null || item.budgetMax != null) ...[
                    Icon(Icons.payments_outlined, size: 14, color: tokens.ink.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      _formatBudget(item),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tokens.ink,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: tokens.space.sm),

              // --- Customer Masked Summary (BR-006) ---
              MaskedPartyLabel(party: item.customer, compact: true),
              SizedBox(height: tokens.space.sm),

              const Divider(height: 1),
              SizedBox(height: tokens.space.xs),

              // --- Footer: Offer count + ExpiryCountdown ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 14,
                        color: tokens.ink.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.offerCount} ${item.offerCount == 1 ? 'offer' : 'offers'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.ink.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  if (item.expiresAt != null)
                    ExpiryCountdown(
                      expiresAt: item.expiresAt!,
                      compact: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBudget(VendorRequestItem item) {
    if (item.budgetMin != null && item.budgetMax != null) {
      return 'AED ${item.budgetMin!.toInt()} - ${item.budgetMax!.toInt()}';
    } else if (item.budgetMin != null) {
      return 'From AED ${item.budgetMin!.toInt()}';
    } else if (item.budgetMax != null) {
      return 'Up to AED ${item.budgetMax!.toInt()}';
    }
    return 'Open Budget';
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radius.xs),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
