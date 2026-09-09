import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';

/// Taxonomy & coverage card. Was `_VendorDetailScreenState._buildTaxonomyCard`
/// (TR-S2-10).
class VendorTaxonomyCard extends StatelessWidget {
  const VendorTaxonomyCard({super.key, required this.detail});

  final VendorDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Container(
      key: const Key('vendor-taxonomy-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('Taxonomy & Coverage'),
          SizedBox(height: kh.spacing.md),
          Text(
            'Categories Served',
            style: kh.typography.caption.copyWith(
              color: kh.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: kh.spacing.xs),
          if (detail.categories.isEmpty)
            Text(
              'No categories declared.',
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
            )
          else
            Wrap(
              spacing: kh.spacing.xs,
              runSpacing: kh.spacing.xs,
              children: [
                for (final category in detail.categories)
                  Container(
                    key: Key('category-chip-$category'),
                    padding: EdgeInsets.symmetric(
                      horizontal: kh.spacing.sm,
                      vertical: kh.spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: kh.colors.goldPrimary.withValues(alpha: 0.1),
                      borderRadius: kh.shapes.pill,
                      border: Border.all(
                        color: kh.colors.goldPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      category,
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.goldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          SizedBox(height: kh.spacing.md),
          Text(
            'Regions Served',
            style: kh.typography.caption.copyWith(
              color: kh.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: kh.spacing.xs),
          if (detail.regions.isEmpty)
            Text(
              'No regions declared.',
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
            )
          else
            Wrap(
              spacing: kh.spacing.xs,
              runSpacing: kh.spacing.xs,
              children: [
                for (final region in detail.regions)
                  Container(
                    key: Key('region-chip-$region'),
                    padding: EdgeInsets.symmetric(
                      horizontal: kh.spacing.sm,
                      vertical: kh.spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: kh.colors.borderSubtle.withValues(alpha: 0.3),
                      borderRadius: kh.shapes.pill,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Text(
                      region,
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
