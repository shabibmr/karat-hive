import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Error view for the customer detail screen. Was
/// `_CustomerDetailScreenState._buildErrorView` (TR-S2-12).
class CustomerDetailErrorView extends StatelessWidget {
  const CustomerDetailErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Center(
      key: const Key('customer-detail-error'),
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: kh.colors.error),
            SizedBox(height: kh.spacing.md),
            Text(
              'Failed to load customer profile',
              style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
            ),
            SizedBox(height: kh.spacing.xs),
            Text(
              error,
              textAlign: TextAlign.center,
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textSecondary,
              ),
            ),
            SizedBox(height: kh.spacing.md),
            ElevatedButton.icon(
              key: const Key('customer-detail-retry-button'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
