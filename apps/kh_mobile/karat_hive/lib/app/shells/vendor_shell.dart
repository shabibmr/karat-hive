import 'package:flutter/material.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// ACTIVE Vendor marketplace shell. Thin CP1 chrome: Home only.
class VendorShell extends StatelessWidget {
  const VendorShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = KhStrings.of(context);
    return Scaffold(
      key: const Key('vendor-shell'),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: s.s('dashboard.title'),
          ),
        ],
        onDestinationSelected: (_) {},
      ),
    );
  }
}
