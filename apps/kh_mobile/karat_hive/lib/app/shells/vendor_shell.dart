import 'package:flutter/material.dart';

/// ACTIVE Vendor marketplace shell (SH-SHELL-01).
///
/// CP1 mounts only Home (VEN-S05). Material [NavigationBar] asserts
/// `destinations.length >= 2`, so SH-SHELL-03 bottom nav is omitted until the
/// remaining vendor destinations (Requests / Offers / Connect / More) land.
class VendorShell extends StatelessWidget {
  const VendorShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('vendor-shell'),
      body: child,
    );
  }
}
