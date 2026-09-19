import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';

class KhButton extends StatelessWidget {
  const KhButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.secondary = false,
    this.destructive = false,
    this.width = double.infinity,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool secondary;
  final bool destructive;
  final double? width;

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
    final button = secondary
        ? OutlinedButton(onPressed: onTap, child: child)
        : FilledButton(
            onPressed: onTap,
            style: destructive ? destructiveStyle : null,
            child: child,
          );
    if (width == null) return button;
    return SizedBox(
      width: width,
      child: button,
    );
  }
}
