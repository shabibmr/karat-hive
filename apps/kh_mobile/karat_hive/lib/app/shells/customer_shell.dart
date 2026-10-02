import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import 'active_shell_registry.dart';

/// Authenticated Customer marketplace shell (SH-SHELL-01/02/03).
///
/// Destinations:
/// Home / Dashboard (CUS-S02), My Requests (open list + History),
/// Connections (CUS-S16), Profile (CUS-S20). Alerts remain accessible by bell.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final strings = KhStrings.of(context);
    // Keep all five route branches so existing alert deep links remain valid.
    // Only four branches have a visible tab; Profile is route branch 4.
    const tabBranches = [0, 1, 2, 4];
    final tabIndex = tabBranches.indexOf(navigationShell.currentIndex);
    final selectedIndex = tabIndex < 0 ? 0 : tabIndex;

    // Read by AppBackButtonDispatcher to route hardware/gesture back presses
    // that have nothing left to pop: non-Home tab -> Home, Home -> confirm exit.
    ActiveShellRegistry.instance.current = ActiveShellInfo(
      isHome: navigationShell.currentIndex == 0,
      goHome: () => navigationShell.goBranch(0),
    );

    return Scaffold(
      backgroundColor: KhHomeStyle.background,
      key: const Key('customer-shell'),
      body: navigationShell,
      bottomNavigationBar: KhBottomNav(
        editorial: true,
        destinations: [
          KhNavDestination(
            label: strings.s('shell.nav.home'),
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
          ),
          KhNavDestination(
            label: strings.s('cus.home.nav.requests'),
            icon: Icons.description_outlined,
            selectedIcon: Icons.description,
          ),
          KhNavDestination(
            label: strings.s('shell.nav.connections'),
            icon: Icons.groups_outlined,
            selectedIcon: Icons.groups,
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
            tabBranches[index],
            initialLocation: tabBranches[index] == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
