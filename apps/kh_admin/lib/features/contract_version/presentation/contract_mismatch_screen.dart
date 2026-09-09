import 'package:flutter/material.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/platform/open_url.dart';

/// Screen displayed on HTTP 426 Upgrade Required / contract version mismatch (TR-S4-17 / E26).
class ContractMismatchScreen extends StatelessWidget {
  const ContractMismatchScreen({
    super.key,
    this.message,
    this.onReload,
  });

  final String? message;
  final VoidCallback? onReload;

  void _handleReload() {
    if (onReload != null) {
      onReload!();
      return;
    }
    // Default: reload browser tab
    openUrlInNewTab('.');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.backgroundElevated,
                borderRadius: shapes.roundedMd,
                border: Border.all(
                  color: colors.error.withValues(alpha: 0.6),
                  width: shapes.cardBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(spacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.error,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.system_update_alt_outlined,
                        size: 32,
                        color: colors.error,
                      ),
                    ),
                    SizedBox(height: spacing.md),
                    Text(
                      'Portal Upgrade Required',
                      style: typography.headline.copyWith(
                        color: colors.cream100,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      'HTTP 426 — Contract Version Mismatch',
                      style: typography.caption.copyWith(
                        color: colors.goldPrimary,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.lg),
                    Text(
                      message ??
                          'The Karat Hive Admin Portal client is running a version that is no longer compatible with the backend API contract. A client refresh or update is required to resume administrative operations.',
                      style: typography.body.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.xl),
                    ElevatedButton.icon(
                      key: const Key('contract-mismatch-reload-button'),
                      onPressed: _handleReload,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Reload Admin Portal'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, spacing.buttonHeight + 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
