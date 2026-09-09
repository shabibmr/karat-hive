import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_detail_formatters.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_detail_header.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_detail_row.dart';

/// Customer summary card. Was
/// `_CustomerDetailScreenState._buildSummaryCard` (TR-S2-12).
class CustomerSummaryCard extends StatelessWidget {
  const CustomerSummaryCard({super.key, required this.detail});

  final CustomerDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Container(
      key: const Key('customer-summary-card'),
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
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: kh.colors.goldPrimary.withValues(alpha: 0.18),
                child: Text(
                  detail.displayName.isNotEmpty
                      ? detail.displayName[0].toUpperCase()
                      : 'C',
                  style: kh.typography.headline.copyWith(
                    color: kh.colors.goldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: kh.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.displayName.isNotEmpty
                          ? detail.displayName
                          : 'Unnamed Customer',
                      style: kh.typography.title.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kh.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: kh.spacing.xxs),
                    KhStatusChip(
                      label: detail.accountState.displayName,
                      tone: customerStatusTone(detail.accountState),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.lg),
          Divider(color: kh.colors.borderSubtle, height: 1),
          SizedBox(height: kh.spacing.md),
          CustomerDetailRow(label: 'Email Address', value: detail.email ?? '—'),
          CustomerDetailRow(
              label: 'Mobile Number', value: detail.mobileNumber ?? '—'),
          CustomerDetailRow(
              label: 'Default Region',
              value: detail.defaultRegion ?? 'UAE (Default)'),
          CustomerDetailRow(
              label: 'Joined Date',
              value: customerFormatDate(detail.createdAt)),
          CustomerDetailRow(label: 'User ID', value: detail.userId),
          CustomerDetailRow(label: 'Customer Profile ID', value: detail.id),
        ],
      ),
    );
  }
}
