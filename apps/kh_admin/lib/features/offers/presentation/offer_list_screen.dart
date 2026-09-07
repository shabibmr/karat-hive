import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/kh_theme.dart';
import '../../../core/design/widgets/kh_data_table.dart';
import '../../../core/design/widgets/kh_screen_header.dart';
import '../../../core/design/widgets/kh_status_chip.dart';
import '../controller/offer_list_controller.dart';
import '../model/offer_enums.dart';
import '../model/offer_list_filters.dart';
import '../model/offer_list_item.dart';

/// ADM-S10 · Offer list — Platform-wide vendor offer monitoring and inspection.
class OfferListScreen extends ConsumerStatefulWidget {
  const OfferListScreen({super.key});

  @override
  ConsumerState<OfferListScreen> createState() => _OfferListScreenState();
}

class _OfferListScreenState extends ConsumerState<OfferListScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final query = ref.read(offerListControllerProvider).filters.query;
    _searchController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        ref.read(offerListControllerProvider.notifier).setSearchQuery(query);
        ref.read(offerListControllerProvider.notifier).submitSearch();
      }
    });
  }

  void _onSearchSubmitted() {
    _debounceTimer?.cancel();
    ref
        .read(offerListControllerProvider.notifier)
        .setSearchQuery(_searchController.text.trim());
    ref.read(offerListControllerProvider.notifier).submitSearch();
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final listState = ref.watch(offerListControllerProvider);
    final controller = ref.read(offerListControllerProvider.notifier);

    if (_searchController.text != listState.filters.query &&
        !_searchController.selection.isValid) {
      _searchController.text = listState.filters.query;
    }

    return Material(
      color: kh.colors.backgroundSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KhScreenHeader(
              eyebrow: 'Marketplace Audit',
              heading: 'Offers',
              supportingText:
                  'Platform-wide vendor offer monitoring and inspection',
            ),
            SizedBox(height: kh.spacing.lg),
            _OfferFilterBar(
              key: const Key('offer-filter-bar'),
              filters: listState.filters,
              searchController: _searchController,
              onStateChanged: (value) => controller.applyFilters(
                listState.filters.copyWith(state: value),
              ),
              onTypeChanged: (value) => controller.applyFilters(
                listState.filters.copyWith(requestType: value),
              ),
              onSearchSubmitted: _onSearchSubmitted,
              onSearchChanged: _onSearchChanged,
            ),
            SizedBox(height: kh.spacing.lg),
            if (listState.isLoading)
              const Center(
                key: Key('offer-list-loading'),
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (listState.error != null && listState.items.isEmpty)
              _OfferErrorView(
                key: const Key('offer-error-view'),
                message: listState.error!,
                onRetry: controller.refresh,
              )
            else if (listState.items.isEmpty)
              const _OfferEmptyView(
                key: Key('offer-empty-view'),
                message: 'No offers match the current filter criteria.',
              )
            else ...[
              _OfferTable(
                items: listState.items,
              ),
              SizedBox(height: kh.spacing.md),
              _OfferPaginationControls(
                listState: listState,
                controller: controller,
              ),
            ],
            if (listState.error != null && listState.items.isNotEmpty) ...[
              SizedBox(height: kh.spacing.sm),
              Text(
                listState.error!,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.error,
                  fontSize: 12.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OfferFilterBar extends StatelessWidget {
  const _OfferFilterBar({
    super.key,
    required this.filters,
    required this.searchController,
    required this.onStateChanged,
    required this.onTypeChanged,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
  });

  final OfferListFilters filters;
  final TextEditingController searchController;
  final ValueChanged<OfferState?> onStateChanged;
  final ValueChanged<RequestType?> onTypeChanged;
  final VoidCallback onSearchSubmitted;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Wrap(
      spacing: kh.spacing.sm,
      runSpacing: kh.spacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220.0,
          child: DropdownButtonFormField<OfferState?>(
            key: const Key('offer-filter-state'),
            initialValue: filters.state,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Offer state',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<OfferState?>(
                value: null,
                child: Text('All States'),
              ),
              for (final state in OfferState.values)
                DropdownMenuItem(
                  value: state,
                  child: Text(state.displayName),
                ),
            ],
            onChanged: onStateChanged,
          ),
        ),
        SizedBox(
          width: 220.0,
          child: DropdownButtonFormField<RequestType?>(
            key: const Key('offer-filter-request-type'),
            initialValue: filters.requestType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Request type',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<RequestType?>(
                value: null,
                child: Text('All Types'),
              ),
              for (final type in RequestType.values)
                DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
            ],
            onChanged: onTypeChanged,
          ),
        ),
        SizedBox(
          width: 320.0,
          child: TextField(
            key: const Key('offer-filter-search'),
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Offer ID, vendor name, request ref…',
              isDense: true,
              suffixIcon: IconButton(
                key: const Key('offer-search-button'),
                icon: const Icon(Icons.search, size: 20.0),
                tooltip: 'Search offers',
                onPressed: onSearchSubmitted,
              ),
            ),
            onChanged: onSearchChanged,
            onSubmitted: (_) => onSearchSubmitted(),
            textInputAction: TextInputAction.search,
          ),
        ),
      ],
    );
  }
}

class _OfferTable extends StatelessWidget {
  const _OfferTable({
    required this.items,
  });

  final List<OfferListItem> items;

  static String _formatPrice(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return 'AED $whole.${parts[1]}';
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return KhDataTable(
      key: const Key('offer-list-table'),
      minWidth: 1120.0,
      columns: const [
        KhTableColumn('Offer Reference/ID', flex: 2),
        KhTableColumn('Parent Request', flex: 2),
        KhTableColumn('Vendor Name', flex: 3),
        KhTableColumn('Offered Price (AED)', flex: 2),
        KhTableColumn('State', flex: 2),
        KhTableColumn('Submission Date', flex: 2),
        KhTableColumn('Expiry Date', flex: 2),
        KhTableColumn('Outcome', flex: 2),
        KhTableColumn('Action', flex: 1),
      ],
      rows: [
        for (final item in items)
          KhTableRow(
            key: Key('offer-row-${item.id}'),
            onTap: () => context.go('/offers/${item.id}'),
            cells: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.reference ?? item.id,
                    style: kh.typography.bodySmall.copyWith(
                      color: kh.colors.goldPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.0,
                    ),
                  ),
                  if (item.reference != null && item.reference != item.id)
                    Text(
                      item.id,
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textMuted,
                        fontSize: 10.0,
                      ),
                    ),
                ],
              ),
              Text(
                item.requestReference ?? item.requestId,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
              Text(
                item.vendorName,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
              Text(
                _formatPrice(item.offeredPrice),
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.goldPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.0,
                ),
              ),
              KhStatusChip(
                label: item.state.displayName.toUpperCase(),
                tone: item.state.statusTone,
                dense: true,
              ),
              Text(
                _formatDate(item.submittedAt),
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
              Text(
                _formatDate(item.expiresAt),
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
              Text(
                item.outcome ??
                    (item.state == OfferState.accepted
                        ? 'Accepted by Customer'
                        : (item.state == OfferState.rejected
                            ? 'Rejected'
                            : (item.state == OfferState.expired
                                ? 'Expired'
                                : 'Pending'))),
                style: kh.typography.bodySmall.copyWith(
                  color: item.state == OfferState.accepted
                      ? kh.colors.success
                      : (item.state == OfferState.rejected
                          ? kh.colors.error
                          : kh.colors.textSecondary),
                  fontSize: 12.0,
                ),
              ),
              OutlinedButton(
                key: Key('inspect-offer-${item.id}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  minimumSize: const Size(60.0, 30.0),
                ),
                onPressed: () => context.go('/offers/${item.id}'),
                child: const Text('Inspect', style: TextStyle(fontSize: 12.0)),
              ),
            ],
          ),
      ],
    );
  }
}

class _OfferPaginationControls extends StatelessWidget {
  const _OfferPaginationControls({
    required this.listState,
    required this.controller,
  });

  final OfferListState listState;
  final OfferListController controller;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing ${listState.items.length} offers${listState.totalCount != null ? ' of ${listState.totalCount}' : ''}',
          style: kh.typography.caption.copyWith(
            color: kh.colors.textMuted,
            fontSize: 11.0,
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              key: const Key('offer-page-prev'),
              icon: const Icon(Icons.chevron_left, size: 18.0),
              label: const Text('Previous', style: TextStyle(fontSize: 12.0)),
              onPressed:
                  listState.canGoPrevious ? controller.previousPage : null,
            ),
            SizedBox(width: kh.spacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: kh.colors.backgroundElevated,
                borderRadius: kh.shapes.roundedSm,
                border: Border.all(color: kh.colors.borderSubtle),
              ),
              child: Text(
                'Page ${listState.page}',
                style: kh.typography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                ),
              ),
            ),
            SizedBox(width: kh.spacing.sm),
            OutlinedButton.icon(
              key: const Key('offer-page-next'),
              icon: const Icon(Icons.chevron_right, size: 18.0),
              label: const Text('Next', style: TextStyle(fontSize: 12.0)),
              onPressed: listState.canGoNext ? controller.nextPage : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _OfferEmptyView extends StatelessWidget {
  const _OfferEmptyView({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kh.spacing.xxl),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 48.0,
            color: kh.colors.gold400.withValues(alpha: 0.6),
          ),
          SizedBox(height: kh.spacing.md),
          Text(
            'No offers found',
            style: kh.typography.title.copyWith(
              color: kh.colors.textPrimary,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: kh.typography.bodySmall.copyWith(
              color: kh.colors.textSecondary,
              fontSize: 13.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferErrorView extends StatelessWidget {
  const _OfferErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kh.spacing.xxl),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.0,
            color: kh.colors.error,
          ),
          SizedBox(height: kh.spacing.md),
          Text(
            'Failed to load offers',
            style: kh.typography.title.copyWith(
              color: kh.colors.error,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: kh.typography.bodySmall.copyWith(
              color: kh.colors.textSecondary,
              fontSize: 13.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          ElevatedButton.icon(
            key: const Key('offer-retry-button'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18.0),
            label: const Text('Retry', style: TextStyle(fontSize: 13.0)),
          ),
        ],
      ),
    );
  }
}
