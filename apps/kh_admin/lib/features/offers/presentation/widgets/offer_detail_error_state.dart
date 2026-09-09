import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Error state card for the offer detail screen. Was `_DetailErrorState`.
class OfferDetailErrorState extends StatelessWidget {
  const OfferDetailErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kh.spacing.xxl),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.0, color: kh.colors.error),
          SizedBox(height: kh.spacing.md),
          Text(
            l10n?.offersDetailErrorTitle ?? 'Failed to load offer details',
            style: kh.typography.title.copyWith(
              color: kh.colors.error,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: kh.typography.bodySmall.copyWith(
              color: kh.colors.textSecondary,
              fontSize: 13.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          ElevatedButton.icon(
            key: const Key('offer-detail-retry-button'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18.0),
            label: Text(
              l10n?.offersRetry ?? 'Retry',
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
        ],
      ),
    );
  }
}
