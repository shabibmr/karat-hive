import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

/// Request specification grid for jewelry request details.
/// Displays key parameters cleanly without clutter.
///
/// Note: SH-DOM-03 is [MoneyDisplay]; this grid is a request-detail layout.
class SpecificationGrid extends StatelessWidget {
  const SpecificationGrid({
    super.key,
    required this.item,
  });

  final VendorRequestItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    final entries = <MapEntry<String, String>>[
      MapEntry('Category', item.categoryName ?? item.categoryId),
      MapEntry('Region', item.regionName ?? item.regionId),
      if (item.purityKarat != null)
        MapEntry('Purity', '${item.purityKarat}K Gold'),
      if (item.weightGrams != null)
        MapEntry(
          'Weight',
          '${item.weightGrams} g${item.weightIsApproximate ? ' (approx)' : ''}',
        ),
      if (item.budgetMin != null || item.budgetMax != null)
        MapEntry('Budget', _formatBudget(item)),
      MapEntry('Type', item.requestType.replaceAll('_', ' ')),
      MapEntry('Direction', item.direction),
    ];

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specifications',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: tokens.space.sm),
            const Divider(height: 1),
            SizedBox(height: tokens.space.sm),
            Wrap(
              spacing: tokens.space.md,
              runSpacing: tokens.space.sm,
              children: entries.map((entry) {
                return SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.ink.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tokens.ink,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(growable: false),
            ),
            if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
              SizedBox(height: tokens.space.md),
              const Divider(height: 1),
              SizedBox(height: tokens.space.sm),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 12,
                  color: tokens.ink.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.notes!,
                style: TextStyle(
                  fontSize: 13,
                  color: tokens.ink,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatBudget(VendorRequestItem item) {
    if (item.budgetMin != null && item.budgetMax != null) {
      return 'AED ${item.budgetMin!.toInt()} - ${item.budgetMax!.toInt()}${item.budgetIsFlexible ? ' (flex)' : ''}';
    } else if (item.budgetMin != null) {
      return 'From AED ${item.budgetMin!.toInt()}';
    } else if (item.budgetMax != null) {
      return 'Up to AED ${item.budgetMax!.toInt()}';
    }
    return 'Open';
  }
}
