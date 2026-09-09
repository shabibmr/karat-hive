import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Label/value row on the customer summary card. Was
/// `_CustomerDetailScreenState._buildInfoRow` (TR-S2-12).
class CustomerDetailRow extends StatelessWidget {
  const CustomerDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: kh.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: kh.typography.caption.copyWith(
                color: kh.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
