import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// ACTIVE Vendor marketplace shell (SH-SHELL-01/02/03).
///
/// Houses the 5 bottom navigation destinations:
/// - Home (VEN-S05)
/// - Requests (VEN-S06)
/// - Offers (VEN-S11 / CP-3)
/// - Connections (VEN-S12, disabled until CP-4)
/// - Profile (VEN-S14, disabled until CP-6)
///
/// Uses [StatefulNavigationShell] so Home and Requests keep independent
/// navigation stacks across tab switches.
class VendorShell extends StatelessWidget {
  const VendorShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _enabledTabCount = 3;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index >= _enabledTabCount) {
      final message = switch (index) {
        3 => 'Customer connections open in Check-Point 4.',
        _ => 'Vendor profile & settings open in Check-Point 6.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final selectedIndex = navigationShell.currentIndex.clamp(0, 4);

    return Scaffold(
      key: const Key('vendor-shell'),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        key: const Key('vendor-bottom-nav'),
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onDestinationSelected(context, idx),
        indicatorColor: tokens.gold.withValues(alpha: 0.25),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Requests',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer),
            label: 'Offers',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: tokens.ink.withValues(alpha: 0.35),
            ),
            label: 'Connections',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: tokens.ink.withValues(alpha: 0.35),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Placeholder body for Vendor tabs that land in a later check-point.
class VendorComingSoonPage extends StatelessWidget {
  const VendorComingSoonPage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space.lg),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: tokens.ink.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}
