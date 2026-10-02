import 'package:flutter/material.dart';
import 'package:kh_design_system/src/typography.dart';

import 'kh_badge.dart';
import 'package:kh_design_system/src/widgets/kh_home_style.dart';

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
    this.editorial = false,
  });

  final List<KhNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool editorial;

  @override
  Widget build(BuildContext context) {
    assert(
      destinations.length >= 2,
      'KhBottomNav requires at least 2 destinations (Material NavigationBar).',
    );
    final bar = NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final dest in destinations)
          NavigationDestination(
            icon: dest.badgeCount == null
                ? Icon(dest.icon)
                : KhBadge(count: dest.badgeCount!, child: Icon(dest.icon)),
            selectedIcon: Icon(dest.selectedIcon ?? dest.icon),
            label: dest.label,
          ),
      ],
    );
    if (!editorial) return bar;
    final fonts = KhFonts.forLocale(Localizations.maybeLocaleOf(context));
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 64,
        backgroundColor: KhHomeStyle.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => fonts
              .sansStyle(11, FontWeight.w500)
              .copyWith(
                color: states.contains(WidgetState.selected)
                    ? KhHomeStyle.gold
                    : KhHomeStyle.muted,
              ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? KhHomeStyle.gold
                : KhHomeStyle.muted,
          ),
        ),
      ),
      child: bar,
    );
  }
}
