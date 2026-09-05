import 'package:flutter/material.dart';

/// SH-SHELL-05 — separate from the Vendor shell so marketplace routes are not
/// mounted for a non-ACTIVE Vendor (Architecture-Frontend §7.2, C-04).
class AwaitingApprovalShell extends StatelessWidget {
  const AwaitingApprovalShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: const Key('awaiting-approval-shell'),
        child: child,
      );
}
