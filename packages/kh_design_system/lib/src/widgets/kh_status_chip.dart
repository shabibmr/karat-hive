import 'package:flutter/material.dart';

import '../tokens.dart';

/// SH-FND-19 — Status chip with a colour map for domain entity states.
class KhStatusChip extends StatelessWidget {
  const KhStatusChip({
    super.key,
    required this.label,
    this.tone = KhStatusTone.neutral,
    this.compact = false,
  });

  final String label;
  final KhStatusTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (Color fg, Color bg) = switch (tone) {
      KhStatusTone.success => (
          const Color(0xFF1B5E20),
          const Color(0xFFE8F5E9),
        ),
      KhStatusTone.warning => (
          const Color(0xFFE65100),
          const Color(0xFFFFF3E0),
        ),
      KhStatusTone.danger => (
          tokens.danger,
          tokens.danger.withValues(alpha: 0.12),
        ),
      KhStatusTone.accent => (
          tokens.ink,
          tokens.gold.withValues(alpha: 0.28),
        ),
      KhStatusTone.neutral => (
          tokens.ink.withValues(alpha: 0.75),
          tokens.ink.withValues(alpha: 0.08),
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
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

enum KhStatusTone {
  neutral,
  accent,
  success,
  warning,
  danger,
}
