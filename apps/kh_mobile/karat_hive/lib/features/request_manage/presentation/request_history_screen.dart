import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../controller/history_controller.dart';
import 'customer_copy.dart';
import 'widgets/owner_request_card.dart';

/// CUS-S17 — terminal Request history (CU-17).
class RequestHistoryScreen extends ConsumerStatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  ConsumerState<RequestHistoryScreen> createState() =>
      _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends ConsumerState<RequestHistoryScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.offset >= _scroll.position.maxScrollExtent - 200) {
      ref.read(historyControllerProvider).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(historyControllerProvider);
    final tokens = context.tokens;
    final s = KhStrings.of(context);

    return Scaffold(
      key: const Key('request-history-screen'),
      appBar: AppBar(title: Text(s.s('cus.s17.title'))),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.space.md),
            child: KhTextField(
              label: s.s('cus.s17.search'),
              controller: _search,
              onChanged: (value) {
                final q = ref.read(historyQueryProvider);
                ref.read(historyQueryProvider.notifier).update(
                      q.copyWith(q: value, clearQ: value.trim().isEmpty),
                    );
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<PagedListState<RequestForCustomer>>(
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
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
                        KhEmptyView(message: s.s('cus.s17.empty')),
                      ],
                    ),
                  );
                }
                return KhPullToRefresh(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(tokens.space.md),
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final req = state.items[i];
                      return OwnerRequestCard(
                        request: req,
                        onOpen: () =>
                            context.push('/customer/requests/${req.id}'),
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
