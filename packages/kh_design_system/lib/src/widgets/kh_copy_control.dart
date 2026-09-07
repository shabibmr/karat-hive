import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kh_design_system/src/tokens.dart';

/// SH-FND-22 — copy a value to the clipboard with a success toast.
class KhCopyControl extends StatelessWidget {
  const KhCopyControl({
    super.key,
    required this.value,
    this.tooltip = 'Copy',
    this.copiedMessage = 'Copied',
    this.icon = Icons.copy_outlined,
    this.compact = false,
  });

  final String value;
  final String tooltip;
  final String copiedMessage;
  final IconData icon;
  final bool compact;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(copiedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      button: true,
      label: tooltip,
      child: IconButton(
        key: const Key('kh-copy-control'),
        tooltip: tooltip,
        visualDensity:
            compact ? VisualDensity.compact : VisualDensity.standard,
        icon: Icon(icon, size: compact ? 18 : 22, color: tokens.ink),
        onPressed: value.trim().isEmpty ? null : () => _copy(context),
      ),
    );
  }
}
