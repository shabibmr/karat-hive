import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/format/kh_formats.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_detail_row.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Unmasked customer profile card. Was `_buildCustomerCard`.
class RequestCustomerCard extends StatelessWidget {
  const RequestCustomerCard({super.key, required this.detail});

  final RequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final cust = detail.customer;
    final dateFormat = khDateFormat;

    return Container(
      key: const Key('request-customer-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              KhSectionLabel(l10n?.requestsDetailCustomerProfileTitle ??
                  'Unmasked Customer Profile'),
              KhStatusChip(
                label: cust.accountState,
                tone: cust.accountState == 'ACTIVE'
                    ? KhStatusTone.success
                    : KhStatusTone.error,
                dense: true,
              ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 22.0,
                backgroundColor: kh.colors.goldPrimary.withValues(alpha: 0.2),
                child:
                    Icon(Icons.person, color: kh.colors.goldPrimary, size: 24.0),
              ),
              SizedBox(width: kh.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cust.fullName,
                      style: kh.typography.title.copyWith(
                        color: kh.colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                      ),
                    ),
                    Text(
                      l10n?.requestsDetailCustomerId(cust.id) ??
                          'Customer ID: ${cust.id}',
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textMuted,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          RequestDetailRow(
              l10n?.requestsDetailLabelMobilePhone ?? 'Mobile Phone',
              cust.mobileNumber ?? '—'),
          RequestDetailRow(
              l10n?.requestsDetailLabelEmailAddress ?? 'Email Address',
              cust.email ?? '—'),
          if (cust.createdAt != null)
            RequestDetailRow(
                l10n?.requestsDetailLabelMemberSince ?? 'Member Since',
                dateFormat.format(cust.createdAt!)),
        ],
      ),
    );
  }
}
