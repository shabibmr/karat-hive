import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// SH-DOM-09 — copyable entity reference chip (`KH-RQ-…`).
class EntityReferenceChip extends StatelessWidget {
  const EntityReferenceChip({
    super.key,
    required this.reference,
    this.onCopied,
    this.copiedMessage = 'Copied',
  });

  final String reference;
  final VoidCallback? onCopied;
  final String copiedMessage;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: reference));
    onCopied?.call();
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(content: Text(copiedMessage), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ActionChip(
      key: const Key('entity-reference-chip'),
      avatar: Icon(Icons.copy, size: 16, color: tokens.ink),
      label: Text(
        reference,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: tokens.ink,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      onPressed: () => _copy(context),
      backgroundColor: tokens.gold.withValues(alpha: 0.16),
      side: BorderSide.none,
    );
  }
}
