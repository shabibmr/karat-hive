import 'package:flutter/material.dart';

import 'kh_confirm_dialog.dart';

/// Wraps a form screen so back navigation (AppBar back, hardware/gesture
/// back) is intercepted while [isDirty] is true, prompting the user to
/// confirm discarding unsaved changes before the screen actually pops.
class KhDiscardGuard extends StatelessWidget {
  const KhDiscardGuard({
    super.key,
    required this.isDirty,
    required this.child,
    this.title = 'Discard changes?',
    this.body = 'You have unsaved changes. Discard them?',
    this.confirmLabel = 'Discard',
    this.cancelLabel = 'Keep editing',
  });

  final bool isDirty;
  final Widget child;
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await showKhConfirmDialog(
          context,
          title: title,
          body: body,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          destructive: true,
        );
        if (confirmed == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
