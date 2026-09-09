import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Label/value row for the offer detail cards. Was `_DetailRow`.
class OfferDetailRow extends StatelessWidget {
  const OfferDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isStrong = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isStrong;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: kh.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180.0,
            child: Text(
              label,
              style: kh.typography.caption.copyWith(
                color: kh.colors.textMuted,
                fontSize: 11.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: kh.typography.bodySmall.copyWith(
                color: valueColor ?? kh.colors.textPrimary,
                fontWeight: isStrong ? FontWeight.w700 : FontWeight.normal,
                fontSize: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
