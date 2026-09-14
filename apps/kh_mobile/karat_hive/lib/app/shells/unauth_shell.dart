import 'package:flutter/material.dart';

/// Unauthenticated / guest shell (`adr/0011`).
///
/// Hosts Guest Landing, login/register, and the create-compose wizard
/// (reachable without a token until Publish). No Customer marketplace tabs.
class UnauthShell extends StatelessWidget {
  const UnauthShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: const Key('unauth-shell'),
        child: child,
      );
}
