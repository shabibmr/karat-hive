import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// ACTIVE Vendor marketplace shell (SH-SHELL-01/02/03).
///
/// Houses the 5 bottom navigation destinations:
/// - Home (VEN-S05)
/// - Requests (VEN-S06)
/// - Offers (VEN-S11 / CP-3)
/// - Connections (VEN-S12 / CP-4)
/// - Profile (VEN-S15 hub; settings VEN-S18 nested; S16 re-home CP6-B01.3)
///
/// Notification centre (VEN-S17) is **not** a bottom-nav tab — entry is the
/// SH-SHELL-02 bell / push → `/vendor/notifications` on the Home branch
/// (distinct from Customer `/customer/alerts`).
///
/// Uses [StatefulNavigationShell] so each tab keeps an independent
/// navigation stack across tab switches.
class VendorShell extends StatelessWidget {
  const VendorShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
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
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: tokens.gold.withValues(alpha: 0.25),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer),
            label: 'Offers',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake),
            label: 'Connections',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
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
