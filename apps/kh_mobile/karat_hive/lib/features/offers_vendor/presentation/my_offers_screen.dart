import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../controller/my_offers_controller.dart';

/// VEN-S11 — My Offers (Pending / Accepted / Closed).
class MyOffersScreen extends ConsumerStatefulWidget {
  const MyOffersScreen({super.key});

  @override
  ConsumerState<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends ConsumerState<MyOffersScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myOffersControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(myOffersControllerProvider);
    final filters = ref.watch(myOffersFiltersProvider);
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;

    return Scaffold(
      key: const Key('my-offers-screen'),
      appBar: AppBar(
        title: Text(l10n?.myOffersTitle ?? 'My Offers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.space.sm),
            child: KhSegmentedTabs(
              selectedId: filters.tab,
              onSelected: (id) =>
                  ref.read(myOffersFiltersProvider.notifier).setTab(id),
              tabs: [
                KhSegmentedTab(
                  id: 'PENDING',
                  label: l10n?.offerTabPending ?? 'Pending',
                ),
                KhSegmentedTab(
                  id: 'ACCEPTED',
                  label: l10n?.offerTabAccepted ?? 'Accepted',
                ),
                KhSegmentedTab(
                  id: 'CLOSED',
                  label: l10n?.offerTabClosed ?? 'Closed',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space.md),
            child: KhTextField(
              label: l10n?.offerSearchByReference ?? 'Search by reference',
              controller: _searchController,
              onChanged: (v) =>
                  ref.read(myOffersFiltersProvider.notifier).setQuery(v),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<PagedListState<OfferForVendor>>(
              valueListenable: controller,
              builder: (context, listState, _) {
                if (listState.status == PagedListStatus.loadingFirstPage) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (listState.status == PagedListStatus.error &&
                    listState.items.isEmpty) {
                  return KhErrorView(
                    message: switch (listState.error) {
                      final Failure f => f.message ??
                          (l10n?.couldNotLoadOffers ?? 'Could not load offers.'),
                      _ => l10n?.couldNotLoadOffers ?? 'Could not load offers.',
                    },
                    onRetry: () =>
                        ref.read(myOffersControllerProvider.notifier).retry(),
                  );
                }
                if (listState.items.isEmpty) {
                  return KhEmptyView(
                    message: l10n?.offersEmptyBody ??
                        'No offers yet. Submit an Offer from a matched Request.',
                  );
                }

                return KhPullToRefresh(
                  onRefresh: () =>
                      ref.read(myOffersControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.all(tokens.space.md),
                    itemCount:
                        listState.items.length + (listState.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        SizedBox(height: tokens.space.sm),
                    itemBuilder: (context, index) {
                      if (index >= listState.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final offer = listState.items[index];
                      final connectionId = offer.connectionId;
                      final accepted = offer.state == OfferState.accepted;
                      return OfferSummaryCard(
                        offer: offer,
                        connectionComingSoonLabel: accepted &&
                                (connectionId == null || connectionId.isEmpty)
                            ? (l10n?.offerConnectionCp4 ??
                                'Connection opens in Check-Point 4.')
                            : null,
                        onTap: offer.state == OfferState.pending
                            ? () => context.push('/vendor/offers/${offer.id}')
                            : accepted &&
                                    connectionId != null &&
                                    connectionId.isNotEmpty
                                ? () => context.push(
                                      '/vendor/connections/$connectionId',
                                    )
                                : null,
                      );
                    },
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
