import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Error view for the vendor detail screen. Was
/// `_VendorDetailScreenState._buildErrorView` (TR-S2-10).
class VendorDetailErrorView extends StatelessWidget {
  const VendorDetailErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Container(
      key: const Key('vendor-detail-error-view'),
      width: double.infinity,
      padding: EdgeInsets.all(kh.spacing.xl),
      decoration: BoxDecoration(
        color: kh.colors.error.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            'Unable to load vendor profile',
            style: kh.typography.title.copyWith(color: kh.colors.error),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
          ),
          SizedBox(height: kh.spacing.md),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
