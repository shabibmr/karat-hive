import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/format/kh_formats.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Matched vendors list card. Was `_buildMatchedVendorsCard`.
class RequestMatchedVendorsCard extends StatelessWidget {
  const RequestMatchedVendorsCard({super.key, required this.detail});

  final RequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;

    return Container(
      key: const Key('request-matched-vendors'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(
              l10n?.requestsDetailMatchedTitle(detail.matchedVendors.length) ??
                  'Matched Vendors (${detail.matchedVendors.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.matchedVendors.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoMatched ??
                    'No vendors matched to this request.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textMuted,
                  fontSize: 13.0,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.matchedVendors.length,
              separatorBuilder: (_, __) => Divider(
                color: kh.colors.borderSubtle,
                height: kh.spacing.md,
              ),
              itemBuilder: (context, index) {
                final mv = detail.matchedVendors[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mv.businessName,
                            style: kh.typography.bodySmall.copyWith(
                              color: kh.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.0,
                            ),
                          ),
                          if (mv.tradingName != null &&
                              mv.tradingName!.isNotEmpty)
                            Text(
                              mv.tradingName!,
                              style: kh.typography.caption.copyWith(
                                color: kh.colors.textMuted,
                                fontSize: 11.0,
                              ),
                            ),
                          Text(
                            l10n?.requestsDetailMatchedAt(
                                    dateFormat.format(mv.matchedAt)) ??
                                'Matched: ${dateFormat.format(mv.matchedAt)}',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.textSecondary,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (mv.rating != null)
                          Text(
                            '★ ${mv.rating!.toStringAsFixed(1)}',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.goldPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.0,
                            ),
                          ),
                        SizedBox(height: kh.spacing.xxs),
                        KhStatusChip(
                          label: mv.viewedAt != null
                              ? (l10n?.requestsDetailViewed ?? 'VIEWED')
                              : (l10n?.requestsDetailNotViewed ?? 'NOT VIEWED'),
                          tone: mv.viewedAt != null
                              ? KhStatusTone.success
                              : KhStatusTone.neutral,
                          dense: true,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
