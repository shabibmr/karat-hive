import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Label/value row used across the connection detail cards. Was
/// `_ConnectionDetailScreenState._infoRow` (TR-S2-14).
class ConnectionInfoRow extends StatelessWidget {
  const ConnectionInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: kh.spacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: kh.typography.bodySmall.copyWith(
                color: isHighlighted ? kh.colors.goldPrimary : kh.colors.textPrimary,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
