import 'package:flutter/material.dart';

import 'active_shell_registry.dart';

/// Unauthenticated / guest shell (`adr/0011`).
///
/// Hosts Guest Landing, login/register, and the create-compose wizard
/// (reachable without a token until Publish). No Customer marketplace tabs.
class UnauthShell extends StatelessWidget {
  const UnauthShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // No bottom-nav tabs here — clear any stale entry from a prior
    // Customer/Vendor shell so AppBackButtonDispatcher falls back to
    // the router's own handling (e.g. the wizard's `type` route onExit).
    ActiveShellRegistry.instance.current = null;
    return KeyedSubtree(
      key: const Key('unauth-shell'),
      child: child,
    );
  }
}
