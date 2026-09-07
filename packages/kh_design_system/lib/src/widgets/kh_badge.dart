import 'package:flutter/material.dart';

import '../tokens.dart';

/// SH-FND-18 — unread / tab count badge.
class KhBadge extends StatelessWidget {
  const KhBadge({
    super.key,
    required this.count,
    this.child,
    this.showZero = false,
  });

  final int count;
  final Widget? child;
  final bool showZero;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final visible = count > 0 || showZero;
    final label = count > 99 ? '99+' : '$count';
    final badge = visible
        ? Semantics(
            label: label,
            child: Container(
              key: const Key('kh-badge'),
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: tokens.space.xs,
                vertical: tokens.space.xs / 2,
              ),
              decoration: BoxDecoration(
                color: tokens.danger,
                borderRadius: BorderRadius.circular(tokens.radius.lg),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: tokens.surface,
                    ),
              ),
            ),
          )
        : null;

    if (child == null) {
      return badge ?? const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        if (badge != null)
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: -tokens.space.xs,
            end: -tokens.space.xs,
            child: badge,
          ),
      ],
    );
  }
}
