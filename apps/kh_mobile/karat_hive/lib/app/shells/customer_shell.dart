import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import 'active_shell_registry.dart';

/// Authenticated Customer marketplace shell (SH-SHELL-01/02/03).
///
/// Destinations match Home-1: Home · Requests · Connections · Profile.
/// Alerts stay on the header bell (`/customer/alerts` on the Home branch).
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Home-1 selected antique gold / idle grey.
  static const _selected = Color(0xFF82521C);
  static const _idle = Color(0xFF888682);
  static const _barFill = Color(0xFFFEFBF6);

  @override
  Widget build(BuildContext context) {
    final strings = KhStrings.of(context);
    final selectedIndex = navigationShell.currentIndex.clamp(0, 3);
    final textTheme = Theme.of(context).textTheme;

    // Read by AppBackButtonDispatcher to route hardware/gesture back presses
    // that have nothing left to pop: non-Home tab -> Home, Home -> confirm exit.
    ActiveShellRegistry.instance.current = ActiveShellInfo(
      isHome: selectedIndex == 0,
      goHome: () => navigationShell.goBranch(0),
    );

    return Scaffold(
      key: const Key('customer-shell'),
      body: navigationShell,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            height: 80,
            backgroundColor: _barFill,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            indicatorColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? textTheme.labelMedium!.copyWith(
                      color: _selected,
                      fontWeight: FontWeight.w700,
                    )
                  : textTheme.labelMedium!.copyWith(color: _idle),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (s) => IconThemeData(
                size: 24,
                color: s.contains(WidgetState.selected) ? _selected : _idle,
              ),
            ),
          ),
        ),
        child: KhBottomNav(
          destinations: [
            KhNavDestination(
              label: strings.s('shell.nav.home'),
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
            ),
            KhNavDestination(
              label: strings.s('shell.nav.requestsTab'),
              icon: Icons.description_outlined,
              selectedIcon: Icons.description,
            ),
            KhNavDestination(
              label: strings.s('shell.nav.connections'),
              icon: Icons.people_outline,
              selectedIcon: Icons.people,
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
      ),
    );
  }
}
