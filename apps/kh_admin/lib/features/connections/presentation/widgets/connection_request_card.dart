import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/features/connections/model/connection_detail.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_detail_formatters.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_info_row.dart';

/// Originating-request card. Was
/// `_ConnectionDetailScreenState._buildRequestCard` (TR-S2-14).
class ConnectionRequestCard extends StatelessWidget {
  const ConnectionRequestCard({super.key, required this.detail});

  final ConnectionDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final request = detail.request;
    final customer = detail.customer;

    return Container(
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
              Icon(Icons.shopping_bag_outlined, color: kh.colors.goldPrimary, size: 20),
              SizedBox(width: kh.spacing.xs),
              Text('Originating Request', style: kh.typography.title),
              if (request?.reference != null) ...[
                const Spacer(),
                Text(
                  request!.reference!,
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.goldPrimary),
                ),
              ],
            ],
          ),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.lg * 2),
          ConnectionInfoRow(label: 'Customer Name', value: customer?.displayName ?? '—'),
          ConnectionInfoRow(label: 'Customer Email', value: customer?.email ?? '—'),
          ConnectionInfoRow(label: 'Customer Mobile', value: customer?.mobileNumber ?? '—'),
          ConnectionInfoRow(label: 'Request Type', value: request?.requestType ?? '—'),
          ConnectionInfoRow(
              label: 'Indicative Budget',
              value: request?.indicativeValue != null
                  ? connectionFormatPrice(request!.indicativeValue!)
                  : '—'),
          if (request?.purityKarat != null)
            ConnectionInfoRow(label: 'Purity / Karat', value: request!.purityKarat!),
          if (request?.weightGrams != null)
            ConnectionInfoRow(label: 'Weight', value: '${request!.weightGrams} grams'),
          if (request?.ornamentType != null)
            ConnectionInfoRow(label: 'Ornament Type', value: request!.ornamentType!),
          if (request?.description != null && request!.description!.isNotEmpty) ...[
            SizedBox(height: kh.spacing.xs),
            const KhSectionLabel('DESCRIPTION / NOTES'),
            SizedBox(height: kh.spacing.xxs),
            Text(
              request.description!,
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
