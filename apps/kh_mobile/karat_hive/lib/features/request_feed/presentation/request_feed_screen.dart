import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../controller/request_feed_controller.dart';
import 'request_filters_sheet.dart';

/// VEN-S06 — Available Requests Feed.
///
/// Infinite-scroll feed driven by [PagedListController] with pull-to-refresh,
/// filter bottom sheet, and masked customer summaries.
class RequestFeedScreen extends ConsumerStatefulWidget {
  const RequestFeedScreen({super.key});

  @override
  ConsumerState<RequestFeedScreen> createState() => _RequestFeedScreenState();
}

class _RequestFeedScreenState extends ConsumerState<RequestFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Pre-fetch next page when within 200px of bottom
    if (currentScroll >= (maxScroll - 200)) {
      ref.read(requestFeedControllerProvider).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(requestFeedControllerProvider);
    final filters = ref.watch(requestFiltersProvider);
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('request-feed-screen'),
      appBar: AppBar(
        title: Text(l10n?.availableRequestsTitle ?? 'Available Requests'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                key: const Key('filter-button'),
                icon: const Icon(Icons.filter_list),
                onPressed: () => RequestFiltersSheet.show(context),
              ),
              if (filters.hasActiveFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: tokens.gold,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${filters.activeFilterCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<PagedListState<VendorRequestItem>>(
        valueListenable: controller,
        builder: (context, state, _) {
          if (state.isInitialLoading) {
            return const Center(child: KhLoadingView());
          }

          if (state.isInitialError) {
            return Center(
              child: KhErrorView(
                message: l10n?.failedToLoadMatchingRequests ??
                    'Failed to load matching requests.',
                onRetry: controller.retry,
              ),
            );
          }

          if (state.isEmpty) {
            return KhRefresh(
              onRefresh: controller.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(tokens.space.lg),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  Icon(
                    Icons.search_off_outlined,
                    size: 64,
                    color: tokens.ink.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: tokens.space.md),
                  Text(
                    l10n?.noMatchingRequests ?? 'No Matching Requests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.space.sm),
                  Text(
                    filters.hasActiveFilters
                        ? (l10n?.emptyFeedResetFiltersHint ??
                            'Try resetting your active filters to see more requests.')
                        : (l10n?.emptyFeedBroadenHint ??
                            'Broaden your Categories and Regions, or check that you have an active Type Subscription for the request types you want to see.'),
                    style: TextStyle(
                      color: tokens.ink.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.space.md),
                  if (filters.hasActiveFilters)
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(requestFiltersProvider.notifier).reset();
                        },
                        child: Text(l10n?.resetFilters ?? 'Reset Filters'),
                      ),
                    )
                  else
                    Center(
                      child: OutlinedButton.icon(
                        key: const Key('empty-feed-subscriptions-cta'),
                        icon: const Icon(Icons.card_membership_outlined),
                        label: Text(l10n?.viewSubscriptions ?? 'View Subscriptions'),
                        // ACTIVE vendors edit Categories/Regions under
                        // AppGuards.vendorProfileCategories. Empty-feed CTA
                        // still points at subscriptions for entitlement gaps.
                        onPressed: () => context.push('/vendor/subscriptions'),
                      ),
                    ),
                ],
              ),
            );
          }

          return KhRefresh(
            onRefresh: controller.refresh,
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(tokens.space.md),
              itemCount: state.items.length + 1, // +1 for sentinel
              separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return KhEndSentinel(
                    hasMore: state.hasMore,
                    isLoading: state.isLoadingNextPage,
                    error: state.isNextPageError ? state.error : null,
                    onRetry: controller.retry,
                    endMessage: l10n?.allCaughtUp ?? 'You are all caught up',
                  );
                }

                final item = state.items[index];
                return VendorRequestCard(
                  key: ValueKey(item.id),
                  item: item,
                  onTap: () {
                    context.push('/vendor/requests/${item.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
