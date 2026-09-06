import 'package:flutter/material.dart';
import '../tokens.dart';

/// SH-SHELL-06 — Pull-to-refresh container.
///
/// Wraps any scrollable child to provide platform-adaptive pull-to-refresh
/// semantics (Cupertino on iOS/macOS, Material on Android).
///
/// Under Frontend Architecture §9.5, this is the primary user-driven
/// cache invalidation trigger across the app's list and dashboard surfaces.
class KhRefresh extends StatelessWidget {
  const KhRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.lastUpdated,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.notificationPredicate,
  });

  /// Async callback invoked when the user pulls to refresh.
  ///
  /// Signals the underlying controller/provider to invalidate caches and
  /// refetch fresh data.
  final RefreshCallback onRefresh;

  /// The scrollable child to be wrapped (ListView, CustomScrollView, etc.).
  final Widget child;

  /// Optional timestamp of when the content was last fetched/updated (SH-SHELL-06).
  final DateTime? lastUpdated;

  /// The color of the refresh indicator. Defaults to brand gold ([KhTokens.gold]).
  final Color? color;

  /// The background color of the refresh indicator circle. Defaults to [KhTokens.surface].
  final Color? backgroundColor;

  /// The distance from the child's top edge where the indicator settles.
  final double displacement;

  /// The offset where the refresh indicator begins appearing.
  final double edgeOffset;

  /// Check that determines whether the scroll notification should trigger refresh.
  final ScrollNotificationPredicate? notificationPredicate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return RefreshIndicator.adaptive(
      key: const Key('kh-refresh-indicator'),
      onRefresh: onRefresh,
      color: color ?? tokens.gold,
      backgroundColor: backgroundColor ?? tokens.surface,
      displacement: displacement,
      edgeOffset: edgeOffset,
      notificationPredicate:
          notificationPredicate ?? defaultScrollNotificationPredicate,
      child: child,
    );
  }
}

/// Alias for [KhRefresh] matching component catalogue naming.
typedef KhPullToRefresh = KhRefresh;
