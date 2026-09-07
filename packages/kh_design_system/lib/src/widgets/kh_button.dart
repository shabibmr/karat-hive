import 'package:flutter/material.dart';

import '../tokens.dart';

class KhButton extends StatelessWidget {
  const KhButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.secondary = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool secondary;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spinnerSize = tokens.space.md + tokens.space.xs;
    final child = busy
        ? SizedBox(
            height: spinnerSize,
            width: spinnerSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);
    final onTap = busy ? null : onPressed;
    final destructiveStyle = FilledButton.styleFrom(
      backgroundColor: tokens.danger,
      foregroundColor: tokens.surface,
    );
    return SizedBox(
      width: double.infinity,
      child: secondary
          ? OutlinedButton(onPressed: onTap, child: child)
          : FilledButton(
              onPressed: onTap,
              style: destructive ? destructiveStyle : null,
              child: child,
            ),
    );
  }
}
