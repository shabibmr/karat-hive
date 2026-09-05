import 'package:flutter/material.dart';

/// Unauthenticated shell: login / register only. No marketplace routes.
class UnauthShell extends StatelessWidget {
  const UnauthShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: const Key('unauth-shell'),
        child: child,
      );
}
