import 'package:flutter/material.dart';

/// SH-FND-12 — empty state.
class KhEmptyView extends StatelessWidget {
  const KhEmptyView({super.key, required this.message, this.icon = Icons.inbox_outlined});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
        key: const Key('empty-view'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      );
}

/// SH-FND-13 — full-screen error with retry.
class KhErrorView extends StatelessWidget {
  const KhErrorView({super.key, required this.message, required this.onRetry, this.retryLabel = 'Try again'});
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) => Center(
        key: const Key('error-view'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      );
}

class KhLoadingView extends StatelessWidget {
  const KhLoadingView({
    super.key,
    this.showLogo = true,
    this.logoWidth = 140,
    this.indicatorSize = 28,
  });

  final bool showLogo;
  final double logoWidth;
  final double indicatorSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('loading-view'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Image.asset(
              'assets/karat-hive-logo.png',
              package: 'kh_design_system',
              width: logoWidth,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/karat-hive-logo.png',
                width: logoWidth,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF8A6A1F),
            ),
          ),
        ],
      ),
    );
  }
}

/// SH-FND-13 inline — a form/banner error.
class KhInlineError extends StatelessWidget {
  const KhInlineError({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('inline-error'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
    );
  }
}
