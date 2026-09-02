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
  const KhLoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(key: Key('loading-view'), child: CircularProgressIndicator());
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
