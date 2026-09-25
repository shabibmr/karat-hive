import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../controller/my_requests_controller.dart';
import 'customer_copy.dart';
import 'widgets/owner_request_card.dart';

/// My Requests tab — Open / Drafts segments; History → CUS-S17.
class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key, this.initialTab});

  /// Optional `OPEN` or `DRAFTS` from `?tab=` on entry.
  final String? initialTab;

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  final _scroll = ScrollController();
  var _appliedInitialTab = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedInitialTab) return;
    final tab = widget.initialTab;
    if (tab != 'OPEN' && tab != 'DRAFTS') {
      _appliedInitialTab = true;
      return;
    }
    _appliedInitialTab = true;
    final filters = ref.read(myRequestsFiltersProvider);
    if (filters.tab != tab) {
      // Apply before the first list fetch settles on the wrong tab.
      Future.microtask(() {
        if (!mounted) return;
        ref.read(myRequestsFiltersProvider.notifier).setTab(tab!);
      });
    }
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
      ref.read(myRequestsControllerProvider).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(myRequestsControllerProvider);
    final filters = ref.watch(myRequestsFiltersProvider);
    final tokens = context.tokens;
    final s = KhStrings.of(context);
    final isDrafts = filters.tab == 'DRAFTS';

    return Scaffold(
      key: const Key('my-requests-screen'),
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.space.sm),
            child: KhSegmentedTabs(
              key: const Key('my-requests-tabs'),
              selectedId: filters.tab,
              onSelected: (id) =>
                  ref.read(myRequestsFiltersProvider.notifier).setTab(id),
              tabs: [
                KhSegmentedTab(
                  id: 'OPEN',
                  label: s.s('cus.home.tabOpen'),
                ),
                KhSegmentedTab(
                  id: 'DRAFTS',
                  label: s.s('cus.home.tabDrafts'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<PagedListState<RequestForCustomer>>(
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
                      if (state.isEmpty)
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: tokens.space.xl),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  isDrafts
                                      ? Icons.drafts_outlined
                                      : Icons.diamond_outlined,
                                  size: 40,
                                  color: tokens.ink.withValues(alpha: 0.35),
                                ),
                                SizedBox(height: tokens.space.sm),
                                Text(
                                  s.s(
                                    isDrafts
                                        ? 'cus.home.emptyDrafts'
                                        : 'cus.home.empty',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            tokens.ink.withValues(alpha: 0.65),
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
                            onViewOffers: isDrafts
                                ? null
                                : () => context.push(
                                      '/customer/requests/${req.id}/offers',
                                    ),
                          ),
                          SizedBox(height: tokens.space.sm),
                        ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
