import 'package:flutter/material.dart';

import '../tokens.dart';

/// Domain-free tone for SH-FND-19. Feature code maps Request/Offer/Connection
/// states onto these values — this package must not import kh_domain.
enum KhStatusTone { neutral, success, warning, danger, info }

/// SH-FND-19 — status chip with a token colour map.
class KhStatusChip extends StatelessWidget {
  const KhStatusChip({
    super.key,
    required this.label,
    required this.tone,
  });

  final String label;
  final KhStatusTone tone;

  Color _toneColor(KhTokens tokens) {
    return switch (tone) {
      KhStatusTone.neutral => tokens.ink,
      KhStatusTone.success => tokens.success,
      KhStatusTone.warning => tokens.warning,
      KhStatusTone.danger => tokens.danger,
      KhStatusTone.info => tokens.info,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = _toneColor(tokens);
    return Semantics(
      key: const Key('kh-status-chip'),
      label: label,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: tokens.space.sm,
            vertical: tokens.space.xs,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: tokens.surface,
                ),
          ),
        ),
      ),
    );
  }
}
