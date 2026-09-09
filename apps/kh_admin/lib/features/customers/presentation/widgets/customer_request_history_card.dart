import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_detail_formatters.dart';

/// Customer request-history card. Was
/// `_CustomerDetailScreenState._buildRequestHistoryCard` (TR-S2-12).
class CustomerRequestHistoryCard extends StatelessWidget {
  const CustomerRequestHistoryCard({super.key, required this.detail});

  final CustomerDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Container(
      key: const Key('customer-request-history-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(
          color: kh.colors.borderSubtle,
          width: kh.shapes.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('ACTIVITY HISTORY'),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Customer Requests (${detail.requests.length})',
            style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
          ),
          SizedBox(height: kh.spacing.md),
          if (detail.requests.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Center(
                child: Text(
                  'No requests submitted by this customer yet.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
              ),
            )
          else
            KhDataTable(
              key: const Key('customer-requests-table'),
              minWidth: 640,
              columns: const [
                KhTableColumn('Reference / ID', flex: 2),
                KhTableColumn('Type', flex: 2),
                KhTableColumn('State', flex: 2),
                KhTableColumn('Offers', flex: 1),
                KhTableColumn('Created Date', flex: 2),
              ],
              rows: [
                for (final req in detail.requests)
                  KhTableRow(
                    cells: [
                      Text(
                        req.reference ??
                            (req.id.length > 8 ? req.id.substring(0, 8) : req.id),
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        req.requestType ?? '—',
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textSecondary,
                        ),
                      ),
                      KhStatusChip(
                        label: req.state ?? 'UNKNOWN',
                        dense: true,
                        tone: (req.state == 'ACCEPTED' || req.state == 'FULFILLED')
                            ? KhStatusTone.success
                            : (req.state == 'CANCELLED' || req.state == 'EXPIRED')
                                ? KhStatusTone.error
                                : KhStatusTone.neutral,
                      ),
                      Text(
                        '${req.offerCount}',
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textPrimary,
                        ),
                      ),
                      Text(
                        customerFormatDate(req.createdAt),
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
