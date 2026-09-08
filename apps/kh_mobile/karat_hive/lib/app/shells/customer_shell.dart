import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../guards.dart';

/// Customer application shell — app shell + app bar + bottom nav
/// (`SH-SHELL-01/02/03`, Architecture-Frontend §7.2).
///
/// Bottom-nav destinations are the Customer screen set: Home/Requests
/// (`CUS-S02`), Notifications (`CUS-S19`), Profile (`CUS-S20`). Bodies are
/// placeholders — the real screens are built on top of this foundation.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <({String path, IconData icon, IconData active})>[
    (
      path: AppGuards.customerHome,
      icon: Icons.home_outlined,
      active: Icons.home,
    ),
    (
      path: AppGuards.customerNotifications,
      icon: Icons.notifications_outlined,
      active: Icons.notifications,
    ),
    (
      path: AppGuards.customerProfile,
      icon: Icons.person_outline,
      active: Icons.person,
    ),
  ];

  int _indexFor(String location) {
    final i = _tabs.indexWhere((t) => location == t.path);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KhL10n.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexFor(location);
    final labels = <String>[
      l10n.navHome,
      l10n.navNotifications,
      l10n.navProfile,
    ];

    return Scaffold(
      key: const Key('customer-shell'),
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i != index) context.go(_tabs[i].path);
        },
        destinations: [
          for (var i = 0; i < _tabs.length; i++)
            NavigationDestination(
              icon: Icon(_tabs[i].icon),
              selectedIcon: Icon(_tabs[i].active),
              label: labels[i],
            ),
        ],
      ),
    );
  }
}

/// Placeholder body for a Customer tab. Replaced by the real screen later.
class CustomerScreenPlaceholder extends StatelessWidget {
  const CustomerScreenPlaceholder(this.screenId, {super.key});

  final String screenId;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          screenId,
          key: Key('placeholder-$screenId'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
}
