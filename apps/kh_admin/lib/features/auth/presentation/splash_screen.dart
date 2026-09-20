import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Shown while [SessionController] resolves the session for the first time.
///
/// Its job is to occupy the route so no protected screen mounts — and fires
/// its admin API calls — against a session that is not yet known.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;

    return Scaffold(
      key: const Key('splash-screen'),
      backgroundColor: colors.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.backgroundSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.gold400.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.diamond_outlined,
                size: 32,
                color: colors.goldPrimary,
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              'KARAT HIVE',
              style: typography.headline.copyWith(
                color: colors.goldPrimary,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: spacing.lg),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.goldPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
