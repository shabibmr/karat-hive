import 'package:flutter/material.dart';

import 'kh_badge.dart';

class KhNavDestination {
  const KhNavDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final int? badgeCount;
}

/// SH-SHELL-03 — bottom navigation. Destinations are parameters; this widget
/// does not know Customer vs Vendor labels.
class KhBottomNav extends StatelessWidget {
  const KhBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final List<KhNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    assert(
      destinations.length >= 2,
      'KhBottomNav requires at least 2 destinations (Material NavigationBar).',
    );
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final dest in destinations)
          NavigationDestination(
            icon: dest.badgeCount == null
                ? Icon(dest.icon)
                : KhBadge(
                    count: dest.badgeCount!,
                    child: Icon(dest.icon),
                  ),
            selectedIcon: Icon(dest.selectedIcon ?? dest.icon),
            label: dest.label,
          ),
      ],
    );
  }
}
