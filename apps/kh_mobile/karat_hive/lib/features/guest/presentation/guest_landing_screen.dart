import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../request_create/controller/request_create_controller.dart';
import '../../request_create/routes.dart';

/// CUS-S23 Guest Landing (`adr/0011`).
///
/// Cold-start surface with no live session. Not the signed-in Dashboard.
class GuestLandingScreen extends ConsumerWidget {
  const GuestLandingScreen({super.key});

  void _openService(BuildContext context, WidgetRef ref, RequestType type) {
    ref.read(requestCreateControllerProvider.notifier).selectType(type);
    context.go(RequestCreatePaths.composeFor(type));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = KhStrings.of(context);
    final theme = Theme.of(context);

    return KhScaffold(
      title: strings.s('guest.title'),
      actions: [
        TextButton(
          key: const Key('guest-log-in'),
          onPressed: () => context.go(AppGuards.customerOnboarding),
          child: Text(strings.s('guest.logIn')),
        ),
      ],
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
        children: [
          Text(
            strings.s('guest.headline'),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            strings.s('guest.subhead'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _ServiceCard(
            key: const Key('guest-service-ornament'),
            label: strings.s('guest.service.ornament'),
            icon: Icons.diamond_outlined,
            onTap: () => _openService(context, ref, RequestType.findOrnament),
          ),
          _ServiceCard(
            key: const Key('guest-service-sell-gold'),
            label: strings.s('guest.service.sellGold'),
            icon: Icons.sell_outlined,
            onTap: () => _openService(context, ref, RequestType.sellOldGold),
          ),
          _ServiceCard(
            key: const Key('guest-service-coins'),
            label: strings.s('guest.service.coins'),
            icon: Icons.monetization_on_outlined,
            onTap: () => _openService(context, ref, RequestType.goldCoin),
          ),
          _ServiceCard(
            key: const Key('guest-service-bullion'),
            label: strings.s('guest.service.bullion'),
            icon: Icons.inventory_2_outlined,
            onTap: () => _openService(context, ref, RequestType.goldBullion),
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            key: const Key('guest-how-it-works'),
            title: Text(strings.s('guest.howItWorks')),
            childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  strings.s('guest.howItWorksBody'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              key: const Key('guest-jeweller-register'),
              onPressed: () => context.go(AppGuards.register),
              child: Text(strings.s('guest.jewellerFooter')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
            child: Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
