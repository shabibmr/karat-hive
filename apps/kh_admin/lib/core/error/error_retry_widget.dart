import 'package:flutter/material.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// A friendly error recovery widget displayed when an unexpected error occurs.
///
/// Intended for use as a fallback screen or release-mode [ErrorWidget.builder].
class ErrorRetryWidget extends StatelessWidget {
  const ErrorRetryWidget({
    super.key,
    this.details,
    this.onRetry,
    this.message = 'An unexpected error occurred.',
  });

  /// The error details associated with this error, if available.
  final FlutterErrorDetails? details;

  /// Callback executed when the user presses the Retry button.
  final VoidCallback? onRetry;

  /// User-friendly message explaining that an error occurred.
  final String message;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Material(
      color: kh.colors.backgroundPrimary,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(kh.spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.0,
                color: kh.colors.error,
              ),
              SizedBox(height: kh.spacing.sm),
              Text(
                message,
                style: kh.typography.body.copyWith(
                  color: kh.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: kh.spacing.md),
              FilledButton.icon(
                icon: const Icon(Icons.refresh, size: 16.0),
                label: const Text('Retry'),
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
