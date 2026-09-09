import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Label/value row used across the vendor profile card. Was
/// `_VendorDetailScreenState._buildFieldRow` (TR-S2-10).
class VendorDetailRow extends StatelessWidget {
  const VendorDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.badge,
  });

  final String label;
  final String value;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Padding(
      padding: EdgeInsets.only(bottom: kh.spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(
              label,
              style: kh.typography.caption.copyWith(
                color: kh.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: kh.typography.bodySmall.copyWith(
                      color: kh.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  SizedBox(width: kh.spacing.xs),
                  badge!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
