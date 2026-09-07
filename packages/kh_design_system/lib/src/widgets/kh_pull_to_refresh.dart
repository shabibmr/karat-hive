import 'package:flutter/material.dart';

import '../tokens.dart';

/// SH-SHELL-06 — pull-to-refresh. [lastUpdated] is already-formatted copy.
class KhPullToRefresh extends StatelessWidget {
  const KhPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.lastUpdated,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final String? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final indicator = RefreshIndicator(onRefresh: onRefresh, child: child);
    if (lastUpdated == null) return indicator;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            tokens.space.md,
            tokens.space.sm,
            tokens.space.md,
            tokens.space.xs,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              lastUpdated!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(child: indicator),
      ],
    );
  }
}
