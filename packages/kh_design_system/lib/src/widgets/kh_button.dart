import 'package:flutter/material.dart';

class KhButton extends StatelessWidget {
  const KhButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.secondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);
    final onTap = busy ? null : onPressed;
    return SizedBox(
      width: double.infinity,
      child: secondary
          ? OutlinedButton(onPressed: onTap, child: child)
          : FilledButton(onPressed: onTap, child: child),
    );
  }
}
