import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/session/session_controller.dart';
import '../repository/request_feed_repository.dart';

final vendorDashboardProvider =
    FutureProvider.autoDispose<VendorDashboard>((ref) async {
  final repo = ref.watch(requestFeedRepositoryProvider);
  final r = await repo.getDashboard();
  return r.when(ok: (v) => v, err: (f) => throw f);
});

/// VEN-S05 — Upgraded Vendor Dashboard.
///
/// Surfaces real counts from GET /v1/me/dashboard (CP2-A13 / CP2-B06) with deep links
/// to available requests and subscriptions.
class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = KhStrings.of(context);
    final dash = ref.watch(vendorDashboardProvider);
    final session = ref.watch(sessionProvider);
    final vendor = session is SignedIn ? session.user.vendor : null;
    final tokens = context.tokens;

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
          padding: EdgeInsets.all(tokens.space.md),
          children: [
            if (vendor != null) ...[
              VendorStatusCard(
                lifecycle: vendor.lifecycle,
                tradingName: vendor.tradingName,
                lifecycleLabel: s.s('lifecycle.${vendor.lifecycle.name}'),
              ),
              SizedBox(height: tokens.space.md),
            ],

            // Panel 1: New Requests (Deep-link to VEN-S06 feed)
            _ActionStatCard(
              key: const Key('dashboard-new-requests'),
              label: s.s('dashboard.newRequests'),
              value: d.newRequests,
              icon: Icons.notifications_active_outlined,
              badgeColor: tokens.gold,
              subtitle: d.newRequests > 0
                  ? '${d.newRequests} matching request(s) waiting'
                  : 'No new requests right now',
              onTap: () => context.push('/vendor/requests'),
            ),
            if (d.newRequestPreview.isNotEmpty) ...[
              SizedBox(height: tokens.space.sm),
              KhSectionHeader(
                title: 'Latest matches',
                actionLabel: 'See all',
                onAction: () => context.push('/vendor/requests'),
              ),
              SizedBox(height: tokens.space.xs),
              ...d.newRequestPreview.take(3).map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: tokens.space.sm),
                      child: VendorRequestCard(
                        key: Key('dashboard-preview-${item.id}'),
                        item: item,
                        onTap: () =>
                            context.push('/vendor/requests/${item.id}'),
                      ),
                    ),
                  ),
            ],
            SizedBox(height: tokens.space.sm),

            // Panel 2: Pending Offers (CP-3)
            _ActionStatCard(
              label: s.s('dashboard.pendingOffers'),
              value: d.pendingOffers,
              icon: Icons.local_offer_outlined,
              subtitle: d.pendingOffersExpiringWithin24h > 0
                  ? '${d.pendingOffersExpiringWithin24h} expiring within 24h'
                  : 'Active bids awaiting customer response',
              disabled: true,
              disabledMessage: 'Offer management opens in Check-Point 3',
            ),
            SizedBox(height: tokens.space.sm),

            // Panel 3: Active Connections (CP-4)
            _ActionStatCard(
              label: s.s('dashboard.activeConnections'),
              value: d.activeConnections,
              icon: Icons.chat_bubble_outline,
              subtitle: d.activeConnectionsNoTalkCount > 0
                  ? '${d.activeConnectionsNoTalkCount} with no talk yet'
                  : 'Won deals & direct customer chats',
              disabled: true,
              disabledMessage: 'Connections open in Check-Point 4',
            ),
            SizedBox(height: tokens.space.md),

            // Panel 4: Subscriptions summary (Links to VEN-S22)
            Card(
              elevation: 0,
              color: tokens.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radius.md),
                side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
              ),
              child: ListTile(
                leading: Icon(Icons.card_membership_outlined, color: tokens.gold),
                title: Text(s.s('dashboard.subscriptions')),
                subtitle: Text(
                  d.subscriptions.isEmpty
                      ? s.s('dashboard.noSubscriptions')
                      : '${d.subscriptions.where((sub) => sub.state == 'ACTIVE' || sub.state == 'GRACE').length} active entitlement(s)',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/vendor/subscriptions'),
              ),
            ),
            SizedBox(height: tokens.space.sm),

            // Rating & Reviews tile
            Card(
              elevation: 0,
              color: tokens.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radius.md),
                side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
              ),
              child: ListTile(
                leading: Icon(Icons.star_outline, color: tokens.gold),
                title: Text(s.s('dashboard.rating')),
                subtitle: Text(
                  d.reviewCount == 0
                      ? s.s('dashboard.noReviews')
                      : '${d.ratingAverage ?? '—'} (${d.reviewCount})',
                ),
              ),
            ),

            // Gold rates panel (hidden while flag is off per AD-API-09)
            if (d.goldRates != null) ...[
              SizedBox(height: tokens.space.sm),
              Card(
                elevation: 0,
                color: tokens.surface,
                child: ListTile(
                  title: Text(s.s('dashboard.goldRates')),
                  subtitle: Text(d.goldRates.toString()),
                ),
              ),
            ],

            SizedBox(height: tokens.space.md),
            if (d.newRequests + d.pendingOffers + d.activeConnections == 0)
              KhEmptyView(message: s.s('common.empty')),
          ],
        ),
      ),
    );
  }
}

class _ActionStatCard extends StatelessWidget {
  const _ActionStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.badgeColor,
    this.disabled = false,
    this.disabledMessage,
    this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final String? subtitle;
  final Color? badgeColor;
  final bool disabled;
  final String? disabledMessage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(
          color: (value > 0 && badgeColor != null)
              ? badgeColor!
              : tokens.ink.withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        onTap: disabled
            ? () {
                if (disabledMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(disabledMessage!)),
                  );
                }
              }
            : onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (disabled ? tokens.ink : (badgeColor ?? tokens.gold))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(
                  icon,
                  color: disabled
                      ? tokens.ink.withValues(alpha: 0.4)
                      : (badgeColor ?? tokens.gold),
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: disabled ? tokens.ink.withValues(alpha: 0.5) : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.ink.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '$value',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: disabled ? tokens.ink.withValues(alpha: 0.4) : null,
                ),
              ),
              if (!disabled) ...[
                SizedBox(width: tokens.space.xs),
                Icon(
                  Icons.chevron_right,
                  color: tokens.ink.withValues(alpha: 0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
