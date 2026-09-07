import 'package:flutter/material.dart';

import 'kh_app_bar.dart';
import 'kh_bottom_nav.dart';
import 'kh_pull_to_refresh.dart';

/// SH-SHELL-01 — authenticated app chrome. Destinations are injected so this
/// package stays free of role-specific labels and l10n.
class KhAppShell extends StatelessWidget {
  const KhAppShell({
    super.key,
    required this.title,
    required this.body,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.actions,
    this.onBack,
    this.onRefresh,
    this.lastUpdated,
  });

  final String title;
  final Widget body;
  final List<KhNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final Future<void> Function()? onRefresh;
  final String? lastUpdated;

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (onRefresh != null) {
      content = KhPullToRefresh(
        onRefresh: onRefresh!,
        lastUpdated: lastUpdated,
        child: content,
      );
    }
    return Scaffold(
      appBar: KhAppBar(
        title: title,
        onBack: onBack,
        actions: actions,
      ),
      body: content,
      bottomNavigationBar: destinations.length < 2
          ? null
          : KhBottomNav(
              destinations: destinations,
              currentIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
            ),
    );
  }
}
