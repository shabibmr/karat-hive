import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_detail_formatters.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_detail_row.dart';

/// Business profile card. Was `_VendorDetailScreenState._buildProfileCard`
/// (TR-S2-10).
class VendorProfileCard extends StatelessWidget {
  const VendorProfileCard({super.key, required this.detail});

  final VendorDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final isExpired = detail.isLicenceExpired;
    final expiryFormatted = vendorFormatDate(detail.licenceExpiryDate);

    return Container(
      key: const Key('vendor-profile-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('Business Profile'),
          SizedBox(height: kh.spacing.md),
          VendorDetailRow(
              label: 'Legal Business Name', value: detail.legalBusinessName),
          VendorDetailRow(
              label: 'Trading Name', value: detail.tradingName ?? '—'),
          VendorDetailRow(
            label: 'Trade Licence Number',
            value: detail.tradeLicenceNumber,
            badge: isExpired
                ? KhStatusChip(label: 'EXPIRED', tone: KhStatusTone.error, dense: true)
                : KhStatusChip(label: 'VALID', tone: KhStatusTone.success, dense: true),
          ),
          VendorDetailRow(
              label: 'Licence Expiry Date', value: expiryFormatted),
          VendorDetailRow(
              label: 'Primary Address', value: detail.businessAddress),
          VendorDetailRow(
              label: 'Authorised Contact Person',
              value: detail.contactPersonName),
          VendorDetailRow(
              label: 'Business Email', value: detail.businessEmail),
          VendorDetailRow(
              label: 'Mobile Number', value: detail.mobileNumber ?? '—'),
          if (detail.submittedAt != null)
            VendorDetailRow(
                label: 'Registration Date',
                value: vendorFormatDate(detail.submittedAt!)),
        ],
      ),
    );
  }
}
