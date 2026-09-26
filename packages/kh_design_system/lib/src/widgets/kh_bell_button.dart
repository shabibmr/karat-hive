import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';

/// Header bell with an unread badge (`UI-Design-Context.md` §6.14).
///
/// 44 px box, bell 26; the `danger` badge sits 6/6 in from the top-end and is
/// omitted when [unreadCount] is null or 0. The count is part of
/// [semanticLabel], not a separate node (§11).
class KhBellButton extends StatelessWidget {
  const KhBellButton({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    this.unreadCount,
  });

  final VoidCallback onPressed;

  /// e.g. "Alerts" or "Alerts, 3 new" — the caller localises the count.
  final String semanticLabel;
  final int? unreadCount;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final count = unreadCount ?? 0;

    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications_outlined, size: 26, color: t.ink),
              if (count > 0)
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    padding: EdgeInsets.symmetric(horizontal: t.space.xs),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.danger,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: context.typography.badge.copyWith(height: 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
