import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';
import 'package:kh_admin/features/vendors/presentation/widgets/vendor_detail_formatters.dart';

/// KYC documents card. Was `_VendorDetailScreenState._buildKycDocumentsCard`
/// (TR-S2-10).
class VendorKycDocumentsCard extends StatelessWidget {
  const VendorKycDocumentsCard({super.key, required this.detail});

  final VendorDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Container(
      key: const Key('vendor-kyc-documents-card'),
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
              const KhSectionLabel('KYC Documents'),
              Text(
                '${detail.documents.length} Uploaded',
                style: kh.typography.caption.copyWith(
                  color: kh.colors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.md),
          if (detail.documents.isEmpty)
            Padding(
              padding: EdgeInsets.all(kh.spacing.md),
              child: Center(
                child: Text(
                  'No KYC documents uploaded for this vendor.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textMuted,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                for (final doc in detail.documents)
                  Container(
                    key: Key('vendor-doc-${doc.id}'),
                    margin: EdgeInsets.only(bottom: kh.spacing.sm),
                    padding: EdgeInsets.all(kh.spacing.md),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundSurface,
                      borderRadius: kh.shapes.roundedMd,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: kh.colors.goldPrimary,
                          size: 28,
                        ),
                        SizedBox(width: kh.spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.documentType.replaceAll('_', ' ').toUpperCase(),
                                style: kh.typography.caption.copyWith(
                                  color: kh.colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (doc.fileName != null)
                                Text(
                                  doc.fileName!,
                                  style: kh.typography.caption.copyWith(
                                    color: kh.colors.textSecondary,
                                  ),
                                ),
                              Text(
                                'Uploaded: ${vendorFormatDate(doc.uploadedAt)}${doc.expiryDate != null ? ' · Expires: ${vendorFormatDate(doc.expiryDate!)}' : ''}',
                                style: kh.typography.caption.copyWith(
                                  color: kh.colors.textMuted,
                                  fontSize: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        KhStatusChip(
                          label: doc.verified ? 'VERIFIED' : 'PENDING',
                          tone: doc.verified
                              ? KhStatusTone.success
                              : KhStatusTone.pending,
                          dense: true,
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
