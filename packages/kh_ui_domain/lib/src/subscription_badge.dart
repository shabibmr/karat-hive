import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// Subscription entitlement status badge (ACTIVE / GRACE / EXPIRED / NONE).
///
/// Note: SH-DOM-08 is [RelativeTimeLabel]; this badge is subscription-specific.
class SubscriptionBadge extends StatelessWidget {
  const SubscriptionBadge({
    super.key,
    required this.state,
    this.compact = false,
  });

  final String state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final upper = state.toUpperCase();

    final (Color fg, Color bg, IconData icon) = switch (upper) {
      'ACTIVE' => (
          const Color(0xFF1B5E20),
          const Color(0xFFE8F5E9),
          Icons.check_circle_outline,
        ),
      'GRACE' => (
          const Color(0xFFE65100),
          const Color(0xFFFFF3E0),
          Icons.warning_amber_rounded,
        ),
      'EXPIRED' || 'LAPSED' => (
          tokens.danger,
          tokens.danger.withValues(alpha: 0.12),
          Icons.cancel_outlined,
        ),
      _ => (
          tokens.ink.withValues(alpha: 0.7),
          tokens.ink.withValues(alpha: 0.08),
          Icons.help_outline,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            upper,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
