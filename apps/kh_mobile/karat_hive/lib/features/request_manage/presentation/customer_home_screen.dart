import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../request_create/controller/request_create_controller.dart';
import '../../request_create/pending_publish_intent.dart';
import '../../request_create/routes.dart';
import '../controller/customer_home_controller.dart';

/// CUS-S02 — Customer Home / Dashboard (hero + services + activity summary).
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final s = KhStrings.of(context);
    final theme = Theme.of(context);
    final summary = ref.watch(customerHomeControllerProvider);

    final requestTypes = [
      _RequestTypeTileData(
        type: RequestType.findOrnament,
        title: s.s('guest.service.ornament'),
        subtitle: 'Bespoke & catalog',
        icon: Icons.diamond_outlined,
        key: const Key('customer-type-ornament'),
      ),
      _RequestTypeTileData(
        type: RequestType.sellOldGold,
        title: s.s('guest.service.sellGold'),
        subtitle: 'Instant jeweller bids',
        icon: Icons.balance_rounded,
        key: const Key('customer-type-sell-gold'),
      ),
      _RequestTypeTileData(
        type: RequestType.goldCoin,
        title: s.s('guest.service.coins'),
        subtitle: 'Standard weights',
        icon: Icons.monetization_on_outlined,
        key: const Key('customer-type-coins'),
      ),
      _RequestTypeTileData(
        type: RequestType.goldBullion,
        title: s.s('guest.service.bullion'),
        subtitle: '24K investment bars',
        icon: Icons.crop_landscape_rounded,
        key: const Key('customer-type-bullion'),
      ),
    ];

    return Scaffold(
      key: const Key('customer-home-screen'),
      appBar: AppBar(
        title: Text(s.s('shell.nav.home')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('quick-create'),
        onPressed: () => context.push(RequestCreatePaths.type),
        icon: const Icon(Icons.add),
        label: Text(s.s('cus.home.create')),
      ),
      body: KhPullToRefresh(
        onRefresh: () async {
          await ref.read(customerHomeControllerProvider.notifier).refresh();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            tokens.space.md,
            tokens.space.md,
            tokens.space.md,
            tokens.space.xl * 3,
          ),
          children: [
            if (ref.watch(pendingPublishIntentProvider)) ...[
              _RetryPublicationBanner(
                key: const Key('retry-publication-banner'),
                onRetry: () => ref
                    .read(requestCreateControllerProvider.notifier)
                    .reconcilePendingPublish(),
              ),
              SizedBox(height: tokens.space.lg),
            ],
            _HeroBanner(
              title: s.s('cus.home.heroTitle'),
              subtitle: s.s('cus.home.heroSub'),
              ctaLabel: s.s('cus.home.create'),
              onCreate: () => context.push(RequestCreatePaths.type),
            ),
            SizedBox(height: tokens.space.lg),
            _RequestTypesSection(
              title: s.s('guest.headline'),
              types: requestTypes,
              onSelect: (type) {
                ref
                    .read(requestCreateControllerProvider.notifier)
                    .selectType(type);
                context.push(RequestCreatePaths.composeFor(type));
              },
            ),
            SizedBox(height: tokens.space.lg),
            KhSectionHeader(title: s.s('cus.home.activity')),
            SizedBox(height: tokens.space.sm),
            summary.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => KhErrorView(
                message: s.s('cus.home.error'),
                onRetry: () =>
                    ref.read(customerHomeControllerProvider.notifier).refresh(),
                retryLabel: s.s('common.retry'),
              ),
              data: (data) => _ActivitySummaryRow(
                openLabel: s.s('cus.home.summaryOpen'),
                offersLabel: s.s('cus.home.summaryOffers'),
                connectionsLabel: s.s('cus.home.summaryConnections'),
                openCount: data.openRequests,
                offersCount: data.offersWaiting,
                connectionsCount: data.connections,
                onOpenTap: () => context.go(AppGuards.customerRequests),
                onOffersTap: () => context.go(AppGuards.customerRequests),
                onConnectionsTap: () =>
                    context.go(AppGuards.customerConnections),
              ),
            ),
            SizedBox(height: tokens.space.md),
            Text(
              s.s('cus.home.dashboardHint'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.ink.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onCreate,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Material(
      key: const Key('customer-home-hero'),
      color: tokens.gold.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(tokens.radius.md),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: tokens.space.xs),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.ink.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: tokens.space.md),
            KhButton(
              key: const Key('customer-home-hero-cta'),
              label: ctaLabel,
              width: null,
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySummaryRow extends StatelessWidget {
  const _ActivitySummaryRow({
    required this.openLabel,
    required this.offersLabel,
    required this.connectionsLabel,
    required this.openCount,
    required this.offersCount,
    required this.connectionsCount,
    required this.onOpenTap,
    required this.onOffersTap,
    required this.onConnectionsTap,
  });

  final String openLabel;
  final String offersLabel;
  final String connectionsLabel;
  final int openCount;
  final int offersCount;
  final int connectionsCount;
  final VoidCallback onOpenTap;
  final VoidCallback onOffersTap;
  final VoidCallback onConnectionsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            key: const Key('summary-open'),
            label: openLabel,
            value: '$openCount',
            onTap: onOpenTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            key: const Key('summary-offers'),
            label: offersLabel,
            value: '$offersCount',
            onTap: onOffersTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            key: const Key('summary-connections'),
            label: connectionsLabel,
            value: '$connectionsCount',
            onTap: onConnectionsTap,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Material(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.ink.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// GL-58: surfaced when a pending guest publish couldn't auto-complete
/// (e.g. offline at the time) so the user can retry it manually.
class _RetryPublicationBanner extends StatelessWidget {
  const _RetryPublicationBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Row(
          children: [
            Icon(Icons.cloud_upload_outlined, color: tokens.gold),
            SizedBox(width: tokens.space.sm),
            Expanded(
              child: Text(
                'Your request could not be published yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(width: tokens.space.sm),
            KhButton(
              label: 'Retry',
              width: null,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestTypeTileData {
  const _RequestTypeTileData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.key,
  });

  final RequestType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Key key;
}

class _RequestTypesSection extends StatelessWidget {
  const _RequestTypesSection({
    required this.title,
    required this.types,
    required this.onSelect,
  });

  final String title;
  final List<_RequestTypeTileData> types;
  final ValueChanged<RequestType> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KhSectionHeader(title: title),
        SizedBox(height: tokens.space.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: tokens.space.sm,
          mainAxisSpacing: tokens.space.sm,
          childAspectRatio: 1.45,
          children: [
            for (final item in types)
              _RequestTypeTile(
                data: item,
                onTap: () => onSelect(item.type),
              ),
          ],
        ),
      ],
    );
  }
}

class _RequestTypeTile extends StatelessWidget {
  const _RequestTypeTile({
    required this.data,
    required this.onTap,
  });

  final _RequestTypeTileData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Material(
      key: data.key,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(
          color: tokens.ink.withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: tokens.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(data.icon, color: tokens.gold, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.ink.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
