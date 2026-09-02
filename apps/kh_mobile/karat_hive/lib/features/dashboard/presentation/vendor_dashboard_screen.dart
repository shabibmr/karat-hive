import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/session/session_controller.dart';
import '../repository/dashboard_repository.dart';

/// VEN-S05 — the ACTIVE landing shell. Counts are zeroed until the marketplace
/// modules land.
class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = KhStrings.of(context);
    final dash = ref.watch(vendorDashboardProvider);

    return KhScaffold(
      title: s.s('dashboard.title'),
      onRefresh: () async => ref.invalidate(vendorDashboardProvider),
      actions: [
        IconButton(
          onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: dash.when(
        loading: () => const KhLoadingView(),
        error: (_, __) => KhErrorView(
          message: 'Could not load your dashboard.',
          onRetry: () => ref.invalidate(vendorDashboardProvider),
        ),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatCard(label: s.s('dashboard.newRequests'), value: d.newRequests),
            _StatCard(label: s.s('dashboard.pendingOffers'), value: d.pendingOffers),
            _StatCard(
              label: s.s('dashboard.activeConnections'),
              value: d.activeConnections,
            ),
            const SizedBox(height: 16),
            if (d.newRequests + d.pendingOffers + d.activeConnections == 0)
              KhEmptyView(message: s.s('common.empty')),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(label),
          trailing: Text('$value', style: Theme.of(context).textTheme.headlineSmall),
        ),
      );
}
