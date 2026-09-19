import 'package:flutter/foundation.dart';

/// Tracks which bottom-nav branch is currently visible in the authenticated
/// Customer/Vendor shell, so [AppBackButtonDispatcher] can special-case
/// "non-Home tab, nothing to pop -> jump to Home" and "Home tab, nothing to
/// pop -> confirm exit" without relying on `GoRoute.onExit` (which also
/// fires on ordinary `goBranch` tab switches and session redirects, not
/// just a genuine dead-end back-press).
class ActiveShellInfo {
  const ActiveShellInfo({required this.isHome, required this.goHome});

  final bool isHome;
  final VoidCallback goHome;
}

class ActiveShellRegistry {
  ActiveShellRegistry._();
  static final instance = ActiveShellRegistry._();

  ActiveShellInfo? current;
}
