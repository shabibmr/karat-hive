import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../controller/customer_home_controller.dart';
import 'customer_copy.dart';
import 'widgets/owner_request_card.dart';

/// CUS-S02 — Home (my Requests).
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
        onPressed: () => context.push('/customer/create'),
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
                state.error is Failure
                    ? state.error as Failure
                    : ServerFailure(message: state.error?.toString()),
                s,
                'cus.home.error',
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
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                  KhEmptyView(
                    message: s.s('cus.home.empty'),
                    icon: Icons.diamond_outlined,
                  ),
                ],
              ),
            );
          }

          return KhPullToRefresh(
            onRefresh: controller.refresh,
            child: ListView.builder(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                tokens.space.md,
                tokens.space.md,
                tokens.space.md,
                tokens.space.xl * 3,
              ),
              itemCount: state.items.length,
              itemBuilder: (context, i) {
                final req = state.items[i];
                return OwnerRequestCard(
                  request: req,
                  onOpen: () => context.push('/customer/requests/${req.id}'),
                  onViewOffers: () =>
                      context.push('/customer/requests/${req.id}/offers'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
