import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import 'active_shell_registry.dart';

/// Authenticated Customer marketplace shell (SH-SHELL-01/02/03).
///
/// Destinations:
/// Home / Dashboard (CUS-S02), My Requests (open list + History),
/// Connections (CUS-S16), Alerts (CUS-S19), Profile (CUS-S20).
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final strings = KhStrings.of(context);
    final selectedIndex = navigationShell.currentIndex.clamp(0, 4);

    // Read by AppBackButtonDispatcher to route hardware/gesture back presses
    // that have nothing left to pop: non-Home tab -> Home, Home -> confirm exit.
    ActiveShellRegistry.instance.current = ActiveShellInfo(
      isHome: selectedIndex == 0,
      goHome: () => navigationShell.goBranch(0),
    );

    return Scaffold(
      key: const Key('customer-shell'),
      body: navigationShell,
      bottomNavigationBar: KhBottomNav(
        destinations: [
          KhNavDestination(
            label: strings.s('shell.nav.home'),
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
          ),
          KhNavDestination(
            label: strings.s('shell.nav.requests'),
            icon: Icons.work_outline,
            selectedIcon: Icons.work,
          ),
          KhNavDestination(
            label: strings.s('shell.nav.connections'),
            icon: Icons.handshake_outlined,
            selectedIcon: Icons.handshake,
          ),
          KhNavDestination(
            label: strings.s('shell.nav.alerts'),
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
          ),
          KhNavDestination(
            label: strings.s('shell.nav.profile'),
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
          ),
        ],
        currentIndex: selectedIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
