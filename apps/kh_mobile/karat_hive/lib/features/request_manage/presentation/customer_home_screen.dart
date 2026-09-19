import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../request_create/controller/request_create_controller.dart';
import '../../request_create/pending_publish_intent.dart';
import '../../request_create/routes.dart';
import '../controller/customer_home_controller.dart';
import 'customer_copy.dart';
import 'widgets/owner_request_card.dart';

/// CUS-S02 — Home / Customer Dashboard (Services + My Requests).
class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.offset >= _scroll.position.maxScrollExtent - 200) {
      ref.read(customerHomeControllerProvider).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(customerHomeControllerProvider);
    final tokens = context.tokens;
    final s = KhStrings.of(context);

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
        title: Text(s.s('cus.home.title')),
        actions: [
          TextButton(
            key: const Key('open-history'),
            onPressed: () => context.push('/customer/history'),
            child: Text(s.s('cus.home.history')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('quick-create'),
        onPressed: () => context.push(RequestCreatePaths.type),
        icon: const Icon(Icons.add),
        label: Text(s.s('cus.home.create')),
      ),
      body: ValueListenableBuilder<PagedListState<RequestForCustomer>>(
        valueListenable: controller,
        builder: (context, state, _) {
          if (state.isInitialLoading) {
            return const KhLoadingView();
          }
          if (state.isInitialError) {
            return KhErrorView(
              message: customerFailureMessage(
                state.error,
                s,
                'cus.home.error',
              ),
              onRetry: controller.retry,
              retryLabel: s.s('common.retry'),
            );
          }

          return KhPullToRefresh(
            onRefresh: controller.refresh,
            child: ListView(
              controller: _scroll,
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
                // Top section: 2x2 Request Types Grid
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

                // Section header: My Requests
                KhSectionHeader(
                  title: s.s('cus.home.title'),
                ),
                SizedBox(height: tokens.space.sm),

                if (state.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: tokens.space.xl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.diamond_outlined,
                            size: 40,
                            color: tokens.ink.withValues(alpha: 0.35),
                          ),
                          SizedBox(height: tokens.space.sm),
                          Text(
                            s.s('cus.home.empty'),
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: tokens.ink.withValues(alpha: 0.65),
                                    ),
                          ),
                          SizedBox(height: tokens.space.xs),
                          Text(
                            'Choose an option above to create your first request.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: tokens.ink.withValues(alpha: 0.45),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final req in state.items) ...[
                    OwnerRequestCard(
                      request: req,
                      onOpen: () =>
                          context.push('/customer/requests/${req.id}'),
                      onViewOffers: () =>
                          context.push('/customer/requests/${req.id}/offers'),
                    ),
                    SizedBox(height: tokens.space.sm),
                  ],
              ],
            ),
          );
        },
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
