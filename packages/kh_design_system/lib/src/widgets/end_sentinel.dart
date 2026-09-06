import 'package:flutter/material.dart';
import '../tokens.dart';

/// SH-FND-25 — Pagination / infinite scroll sentinel widget.
///
/// Renders at the tail of a paginated scrollable list to handle:
/// - Loading indicator when next page is actively fetching (`isLoading == true`).
/// - Inline error view with retry button if next page fetch fails (`error != null`).
/// - Automatic `onVisible` trigger when scrolled to the tail with more items (`hasMore == true`).
/// - End message when all items have loaded (`hasMore == false`).
/// - Gracefully handles empty pages (`itemCount == 0`) and duplicate page terminations.
class KhEndSentinel extends StatefulWidget {
  const KhEndSentinel({
    super.key,
    required this.hasMore,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.onVisible,
    this.itemCount,
    this.endMessage = "You've reached the end",
    this.retryLabel = 'Try again',
    this.showDivider = true,
  });

  /// Whether there are more items to fetch.
  final bool hasMore;

  /// Whether a subsequent page is actively being fetched.
  final bool isLoading;

  /// Error from a failed next page request, if any.
  final Object? error;

  /// Callback when user taps retry on a next page failure.
  final VoidCallback? onRetry;

  /// Callback triggered when the sentinel becomes visible to load the next page.
  final VoidCallback? onVisible;

  /// Total number of loaded items in the list.
  ///
  /// If provided and equal to 0, the sentinel renders as empty ([SizedBox.shrink])
  /// to avoid displaying an end message when an empty state view is already showing.
  final int? itemCount;

  /// Message displayed when all items have been loaded (`hasMore == false`).
  final String endMessage;

  /// Label for the retry button on next page failure.
  final String retryLabel;

  /// Whether to show a subtle decorative divider line around the end message.
  final bool showDivider;

  @override
  State<KhEndSentinel> createState() => _KhEndSentinelState();
}

typedef EndSentinel = KhEndSentinel;

class _KhEndSentinelState extends State<KhEndSentinel> {
  @override
  void initState() {
    super.initState();
    _checkTrigger();
  }

  @override
  void didUpdateWidget(KhEndSentinel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasMore && !widget.isLoading && widget.error == null) {
      _checkTrigger();
    }
  }

  void _checkTrigger() {
    if (widget.hasMore &&
        !widget.isLoading &&
        widget.error == null &&
        widget.onVisible != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            widget.hasMore &&
            !widget.isLoading &&
            widget.error == null) {
          widget.onVisible?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    // 1. Error state on next page request
    if (widget.error != null) {
      final scheme = theme.colorScheme;
      return Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Center(
          key: const Key('end-sentinel-error'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.error.toString(),
                style: TextStyle(color: scheme.error),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.space.sm),
              OutlinedButton(
                onPressed: widget.onRetry,
                child: Text(widget.retryLabel),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Next page loading
    if (widget.isLoading) {
      return Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: const Center(
          key: Key('end-sentinel-loading'),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    // 3. Graceful handling of empty page (0 items loaded)
    if (!widget.hasMore && widget.itemCount != null && widget.itemCount == 0) {
      return const SizedBox.shrink(key: Key('end-sentinel-empty'));
    }

    // 4. End of list: all items loaded
    if (!widget.hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: tokens.space.lg,
          horizontal: tokens.space.md,
        ),
        child: Center(
          key: const Key('end-sentinel-end'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showDivider) ...[
                const Expanded(child: Divider()),
                SizedBox(width: tokens.space.md),
              ],
              Text(
                widget.endMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              if (widget.showDivider) ...[
                SizedBox(width: tokens.space.md),
                const Expanded(child: Divider()),
              ],
            ],
          ),
        ),
      );
    }

    // 5. Waiting to trigger next page load
    return const SizedBox(
      key: Key('end-sentinel-trigger'),
      height: 1,
    );
  }
}
