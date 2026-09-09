import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Error state for the connection detail screen. Was the private
/// `_DetailErrorState` in `connection_detail_screen.dart` (TR-S2-14).
class ConnectionDetailErrorState extends StatelessWidget {
  const ConnectionDetailErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: kh.colors.error),
            SizedBox(height: kh.spacing.sm),
            Text(
              message,
              style: kh.typography.body.copyWith(color: kh.colors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kh.spacing.md),
            FilledButton.icon(
              key: const Key('connection-detail-error-retry'),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
