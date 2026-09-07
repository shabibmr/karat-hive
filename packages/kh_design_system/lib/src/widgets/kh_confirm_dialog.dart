import 'package:flutter/material.dart';

import '../tokens.dart';
import 'kh_button.dart';

/// SH-FND-15 — confirm dialog with optional destructive confirm.
class KhConfirmDialog extends StatelessWidget {
  const KhConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    this.destructive = false,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(body),
          SizedBox(height: tokens.space.md),
          KhButton(
            label: confirmLabel,
            destructive: destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          SizedBox(height: tokens.space.sm),
          KhButton(
            label: cancelLabel,
            secondary: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showKhConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => KhConfirmDialog(
      title: title,
      body: body,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
}
