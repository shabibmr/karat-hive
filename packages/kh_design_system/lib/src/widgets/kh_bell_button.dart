import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';

/// Header bell with an unread indicator (Home-1).
///
/// 48 px hit target, bell 26. When [showDot] is true or [unreadCount] > 0, an
/// 8 px red dot sits at the top-end — no numeral, matching Home-1. The count
/// stays in [semanticLabel] only.
class KhBellButton extends StatelessWidget {
  const KhBellButton({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    this.unreadCount,
    this.showDot = false,
    this.iconColor,
  });

  final VoidCallback onPressed;

  /// e.g. "Alerts" or "Alerts, 3 new" — the caller localises the count.
  final String semanticLabel;
  final int? unreadCount;

  /// Draws the plain red unread dot even when [unreadCount] is null/0.
  final bool showDot;

  /// Defaults to [KhTokens.gold] (Home-1).
  final Color? iconColor;

  /// Home-1 badge red (`#D92B24`).
  static const Color _dotRed = Color(0xFFD92B24);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final count = unreadCount ?? 0;
    final dotted = showDot || count > 0;

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
              Icon(
                Icons.notifications_outlined,
                size: 26,
                color: iconColor ?? t.gold,
              ),
              if (dotted)
                PositionedDirectional(
                  top: 10,
                  end: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _dotRed,
                      shape: BoxShape.circle,
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
