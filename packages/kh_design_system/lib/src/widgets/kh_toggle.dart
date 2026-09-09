import 'package:flutter/material.dart';

import '../tokens.dart';

/// SH-FND-06 — toggle / switch (settings, flexible budget, away mode).
class KhToggle extends StatelessWidget {
  const KhToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final canInteract = enabled && onChanged != null;
    final switchWidget = Switch(
      key: const Key('kh-toggle'),
      value: value,
      onChanged: canInteract ? onChanged : null,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return tokens.surface;
        return tokens.ink.withValues(alpha: 0.55);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return tokens.gold;
        return tokens.ink.withValues(alpha: 0.18);
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.transparent;
        return tokens.ink.withValues(alpha: 0.28);
      }),
    );

    if (label == null) {
      return Semantics(
        toggled: value,
        enabled: canInteract,
        child: switchWidget,
      );
    }

    return Semantics(
      toggled: value,
      enabled: canInteract,
      label: label,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: tokens.ink.withValues(
                      alpha: canInteract ? 1 : 0.45,
                    ),
                  ),
            ),
          ),
          SizedBox(width: tokens.space.sm),
          switchWidget,
        ],
      ),
    );
  }
}
