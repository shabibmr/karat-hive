import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../request_manage/controller/owner_request_detail_controller.dart';
import '../../request_manage/presentation/customer_copy.dart';
import '../controller/offers_list_controller.dart';
import 'widgets/customer_offer_row.dart';

/// CUS-S11 — Offers list. Polls while visible (Architecture-Frontend §11.3).
class CustomerOffersListScreen extends ConsumerStatefulWidget {
  const CustomerOffersListScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<CustomerOffersListScreen> createState() =>
      _CustomerOffersListScreenState();
}

class _CustomerOffersListScreenState
    extends ConsumerState<CustomerOffersListScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      ref.read(offersListControllerProvider(widget.requestId)).refresh();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(offersListControllerProvider(widget.requestId));
    final selected = ref.watch(compareSelectionProvider);
    final requestAsync =
        ref.watch(ownerRequestDetailProvider(widget.requestId));
    final tokens = context.tokens;
    final s = KhStrings.of(context);
    final canCompare = selected.length >= 2 && selected.length <= 4;

    return Scaffold(
      key: const Key('customer-offers-list-screen'),
      appBar: AppBar(
        title: Text(s.s('cus.s11.title')),
        actions: [
          PopupMenuButton<String>(
            key: const Key('offers-sort'),
            onSelected: (v) {
              final f = ref.read(offerListFiltersProvider);
              ref.read(offerListFiltersProvider.notifier).update(
                    f.copyWith(sort: v),
                  );
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'PRICE_ASC', child: Text('Price ↑')),
              PopupMenuItem(value: 'PRICE_DESC', child: Text('Price ↓')),
              PopupMenuItem(value: 'RATING', child: Text('Rating')),
              PopupMenuItem(value: 'NEWEST', child: Text('Newest')),
              PopupMenuItem(value: 'OLDEST', child: Text('Oldest')),
              PopupMenuItem(value: 'EXPIRING', child: Text('Expiring')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: KhButton(
            label: canCompare
                ? s.s('cus.s11.compare')
                : s.s('cus.s11.compareHint'),
            onPressed: canCompare
                ? () {
                    final ids = selected.join(',');
                    context.push(
                      '/customer/requests/${widget.requestId}/compare?ids=$ids',
                    );
                  }
                : null,
          ),
        ),
      ),
      body: Column(
        children: [
          requestAsync.maybeWhen(
            data: (d) {
              final req = d.request;
              return Padding(
                padding: EdgeInsets.all(tokens.space.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        req.reference ?? req.id,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (req.expiresAt != null)
                      ExpiryCountdown(expiresAt: req.expiresAt!),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: ValueListenableBuilder<PagedListState<OfferForCustomer>>(
              valueListenable: controller,
              builder: (context, state, _) {
                if (state.isInitialLoading) return const KhLoadingView();
                if (state.isInitialError) {
                  return KhErrorView(
                    message: customerFailureMessage(
                      state.error is Failure
                          ? state.error as Failure
                          : ServerFailure(message: state.error?.toString()),
                      s,
                      'cus.s11.error',
                    ),
                    onRetry: controller.retry,
                    retryLabel: s.s('common.retry'),
                  );
                }
                if (state.isEmpty) {
                  return KhPullToRefresh(
                    onRefresh: controller.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.18,
                        ),
                        KhEmptyView(message: s.s('cus.s11.empty')),
                      ],
                    ),
                  );
                }
                return KhPullToRefresh(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(tokens.space.md),
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final offer = state.items[i];
                      return CustomerOfferRow(
                        offer: offer,
                        selected: selected.contains(offer.id),
                        onToggleSelect: () => ref
                            .read(compareSelectionProvider.notifier)
                            .toggle(offer.id),
                        onOpen: () =>
                            context.push('/customer/offers/${offer.id}'),
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
