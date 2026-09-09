import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Error state for the platform-settings list. Was
/// `_PlatformSettingsScreenState._buildErrorState` (TR-S2-11).
class PlatformSettingsErrorState extends StatelessWidget {
  const PlatformSettingsErrorState({
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
      key: const Key('settings-list-error'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.error.withValues(alpha: 0.1),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: kh.colors.error),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Text(
              message,
              style: kh.typography.body.copyWith(color: kh.colors.error),
            ),
          ),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: kh.colors.error,
              foregroundColor: kh.colors.cream100,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Empty state for the platform-settings list. Was
/// `_PlatformSettingsScreenState._buildEmptyState` (TR-S2-11).
class PlatformSettingsEmptyState extends StatelessWidget {
  const PlatformSettingsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Container(
      key: const Key('settings-list-empty'),
      padding: EdgeInsets.all(kh.spacing.xl),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(Icons.tune_outlined, size: 40, color: kh.colors.mutedGold),
          SizedBox(height: kh.spacing.sm),
          Text(
            'No matching platform settings found',
            style: kh.typography.headline.copyWith(color: kh.colors.cream100),
          ),
          SizedBox(height: kh.spacing.xxs),
          Text(
            'Try adjusting your filter category or search keywords.',
            style:
                kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
          ),
        ],
      ),
    );
  }
}
