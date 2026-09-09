
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/router/request_query_params.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/requests/controller/request_list_controller.dart';
import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/features/requests/model/request_list_filters.dart';
import 'package:kh_admin/features/requests/model/request_list_item.dart';
import 'package:kh_admin/core/format/kh_formats.dart';
import 'package:kh_admin/core/widgets/debounced_search_mixin.dart';

/// ADM-S08 · Request list — browse all requests across the marketplace with unmasked customer names.
class RequestListScreen extends ConsumerStatefulWidget {
  const RequestListScreen({super.key});

  @override
  ConsumerState<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends ConsumerState<RequestListScreen> with DebouncedSearchMixin {
  late final TextEditingController _searchController;
  Uri? _lastSyncedUri;

  @override
  void initState() {
    super.initState();
    final query = ref.read(requestListControllerProvider).filters.query;
    _searchController = TextEditingController(text: query);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFiltersFromUri();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncFiltersFromUri() {
    Uri uri;
    try {
      uri = GoRouterState.of(context).uri;
    } on Object catch (_) {
      return;
    }
    if (uri == _lastSyncedUri) return;
    _lastSyncedUri = uri;

    final parsed = RequestQueryParams.fromUri(uri).toFilters();
    final current = ref.read(requestListControllerProvider).filters;
    if (parsed == current) return;
    ref.read(requestListControllerProvider.notifier).applyFilters(parsed);
    if (_searchController.text != parsed.query) {
      _searchController.text = parsed.query;
    }
  }

  void _applyFilters(RequestListFilters filters) {
    ref.read(requestListControllerProvider.notifier).applyFilters(filters);
    context.updateRequestQuery(filters);
  }

  void _commitSearch(String query) {
    final controller = ref.read(requestListControllerProvider.notifier);
    controller.setSearchQuery(query);
    controller.submitSearch();
    context.updateRequestQuery(ref.read(requestListControllerProvider).filters);
  }

  void _onSearchChanged(String query) {
    debounceSearch(() {
      _commitSearch(query);
    });
  }

  void _onSearchSubmitted() {
    cancelSearchDebounce();
    _commitSearch(_searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final listState = ref.watch(requestListControllerProvider);
    final controller = ref.read(requestListControllerProvider.notifier);

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
            KhScreenHeader(
              eyebrow: l10n?.requestsListEyebrow ?? 'Marketplace Audit',
              heading: l10n?.requestsListHeading ?? 'Requests',
              supportingText: l10n?.requestsListSubtitle ??
                  'Platform requests oversight and inspection',
            ),
            SizedBox(height: kh.spacing.lg),
            _RequestFilterBar(
              key: const Key('request-filter-bar'),
              filters: listState.filters,
              searchController: _searchController,
              onTypeChanged: (type) => _applyFilters(
                listState.filters.copyWith(requestType: type),
              ),
              onDirectionChanged: (dir) => _applyFilters(
                listState.filters.copyWith(direction: dir),
              ),
              onStateChanged: (state) => _applyFilters(
                listState.filters.copyWith(state: state),
              ),
              onZeroOffersToggled: (val) => _applyFilters(
                listState.filters.copyWith(zeroOffersOnly: val ?? false),
              ),
              onSearchSubmitted: _onSearchSubmitted,
              onSearchChanged: _onSearchChanged,
            ),
            SizedBox(height: kh.spacing.lg),
            if (listState.isLoading)
              const Center(
                key: Key('request-list-loading'),
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (listState.error != null && listState.items.isEmpty)
              _RequestErrorView(
                message: listState.error!,
                onRetry: controller.refresh,
              )
            else if (listState.items.isEmpty)
              _RequestEmptyView(
                key: const Key('request-list-empty'),
                message: l10n?.requestsEmptyBody ??
                    'No requests match the current filters.',
              )
            else ...[
              _RequestTable(items: listState.items),
              SizedBox(height: kh.spacing.md),
              _RequestPaginationControls(
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

class _RequestFilterBar extends StatelessWidget {
  const _RequestFilterBar({
    super.key,
    required this.filters,
    required this.searchController,
    required this.onTypeChanged,
    required this.onDirectionChanged,
    required this.onStateChanged,
    required this.onZeroOffersToggled,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
  });

  final RequestListFilters filters;
  final TextEditingController searchController;
  final ValueChanged<RequestType?> onTypeChanged;
  final ValueChanged<Direction?> onDirectionChanged;
  final ValueChanged<RequestState?> onStateChanged;
  final ValueChanged<bool?> onZeroOffersToggled;
  final VoidCallback onSearchSubmitted;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: kh.spacing.sm,
      runSpacing: kh.spacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220.0,
          child: DropdownButtonFormField<RequestType?>(
            key: const Key('request-filter-type'),
            initialValue: filters.requestType,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n?.requestsFilterType ?? 'Request Type',
              isDense: true,
            ),
            items: [
              DropdownMenuItem<RequestType?>(
                value: null,
                child: Text(l10n?.requestsFilterAllTypes ?? 'All Types'),
              ),
              for (final type in RequestType.values)
                DropdownMenuItem<RequestType?>(
                  value: type,
                  child: Text(type.label),
                ),
            ],
            onChanged: onTypeChanged,
          ),
        ),
        SizedBox(
          width: 170.0,
          child: DropdownButtonFormField<Direction?>(
            key: const Key('request-filter-direction'),
            initialValue: filters.direction,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n?.requestsFilterDirection ?? 'Direction',
              isDense: true,
            ),
            items: [
              DropdownMenuItem<Direction?>(
                value: null,
                child: Text(l10n?.requestsFilterAllDirections ?? 'All Directions'),
              ),
              for (final dir in Direction.values)
                DropdownMenuItem<Direction?>(
                  value: dir,
                  child: Text(dir.label),
                ),
            ],
            onChanged: onDirectionChanged,
          ),
        ),
        SizedBox(
          width: 200.0,
          child: DropdownButtonFormField<RequestState?>(
            key: const Key('request-filter-state'),
            initialValue: filters.state,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n?.requestsFilterStatus ?? 'Status',
              isDense: true,
            ),
            items: [
              DropdownMenuItem<RequestState?>(
                value: null,
                child: Text(l10n?.requestsFilterAllStates ?? 'All States'),
              ),
              for (final state in RequestState.values)
                DropdownMenuItem<RequestState?>(
                  value: state,
                  child: Text(state.label),
                ),
            ],
            onChanged: onStateChanged,
          ),
        ),
        SizedBox(
          width: 280.0,
          child: TextField(
            key: const Key('request-filter-search'),
            controller: searchController,
            decoration: InputDecoration(
              labelText: l10n?.requestsFilterSearch ?? 'Search',
              hintText:
                  l10n?.requestsFilterSearchHint ?? 'Reference, notes, customer…',
              isDense: true,
              suffixIcon: IconButton(
                key: const Key('request-search-button'),
                icon: const Icon(Icons.search, size: 20.0),
                tooltip: l10n?.requestsFilterSearchTooltip ?? 'Search',
                onPressed: onSearchSubmitted,
              ),
            ),
            onChanged: onSearchChanged,
            onSubmitted: (_) => onSearchSubmitted(),
            textInputAction: TextInputAction.search,
          ),
        ),
        FilterChip(
          key: const Key('request-filter-zero-offers'),
          label: Text(l10n?.requestsFilterZeroOffers ?? 'Zero Offers'),
          selected: filters.zeroOffersOnly,
          onSelected: onZeroOffersToggled,
          showCheckmark: true,
          selectedColor: kh.colors.goldPrimary.withValues(alpha: 0.25),
          checkmarkColor: kh.colors.goldPrimary,
        ),
      ],
    );
  }
}

class _RequestTable extends StatelessWidget {
  const _RequestTable({
    required this.items,
  });

  final List<RequestListItem> items;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final currencyFormat = khNumberFormat;
    final dateFormat = khDateFormat;

    return KhDataTable(
      key: const Key('request-list-table'),
      minWidth: 1200.0,
      columns: [
        KhTableColumn(l10n?.requestsColumnReference ?? 'Reference', flex: 3),
        KhTableColumn(l10n?.requestsColumnType ?? 'Type', flex: 2),
        KhTableColumn(l10n?.requestsColumnDirection ?? 'Direction', flex: 1),
        KhTableColumn(l10n?.requestsColumnCustomer ?? 'Customer', flex: 3),
        KhTableColumn(l10n?.requestsColumnCategory ?? 'Category', flex: 2),
        KhTableColumn(l10n?.requestsColumnRegion ?? 'Region', flex: 2),
        KhTableColumn(
            l10n?.requestsColumnIndicativeValue ?? 'Indicative Value', flex: 2),
        KhTableColumn(l10n?.requestsColumnOffers ?? 'Offers', flex: 1),
        KhTableColumn(l10n?.requestsColumnState ?? 'State', flex: 2),
        KhTableColumn(l10n?.requestsColumnDate ?? 'Date', flex: 2),
        KhTableColumn(l10n?.requestsColumnAction ?? 'Action', flex: 2),
      ],
      rows: [
        for (final item in items)
          KhTableRow(
            key: Key('request-row-${item.id}'),
            onTap: () => context.go('/requests/${item.id}'),
            cells: [
              // Reference
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.reference ?? '—',
                    style: kh.typography.bodySmall.copyWith(
                      color: kh.colors.goldPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.0,
                    ),
                  ),
                  if (item.ornamentType != null && item.ornamentType!.isNotEmpty)
                    Text(
                      item.ornamentType!,
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textMuted,
                        fontSize: 11.0,
                      ),
                    ),
                ],
              ),
              // Type
              Text(
                item.requestType.label,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                  fontSize: 13.0,
                ),
              ),
              // Direction
              Text(
                item.direction.label,
                style: kh.typography.bodySmall.copyWith(
                  color: item.direction == Direction.buy
                      ? kh.colors.success
                      : kh.colors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                ),
              ),
              // Customer (unmasked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.customerName,
                    style: kh.typography.bodySmall.copyWith(
                      color: kh.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0,
                    ),
                  ),
                  if (item.customerPhone != null && item.customerPhone!.isNotEmpty)
                    Text(
                      item.customerPhone!,
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textSecondary,
                        fontSize: 10.0,
                      ),
                    ),
                ],
              ),
              // Category
              Text(
                item.categoryName,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
              // Region
              Text(
                item.regionName,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
              // Indicative Value
              Text(
                item.indicativeValue != null
                    ? 'AED ${currencyFormat.format(item.indicativeValue)}'
                    : (item.budgetMax != null
                        ? 'AED ${currencyFormat.format(item.budgetMax)}'
                        : '—'),
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                ),
              ),
              // Offer Count
              Text(
                '${item.offerCount}',
                style: kh.typography.bodySmall.copyWith(
                  color: item.offerCount > 0
                      ? kh.colors.goldPrimary
                      : kh.colors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.0,
                ),
              ),
              // State
              KhStatusChip(
                label: item.state.label,
                tone: _stateTone(item.state),
                dense: true,
              ),
              // Date
              Text(
                item.publishedAt != null
                    ? dateFormat.format(item.publishedAt!)
                    : (item.createdAt != null
                        ? dateFormat.format(item.createdAt!)
                        : '—'),
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 11.0,
                ),
              ),
              // Action
              OutlinedButton(
                key: Key('request-action-${item.id}'),
                onPressed: () => context.go('/requests/${item.id}'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: kh.spacing.sm,
                    vertical: kh.spacing.xxs,
                  ),
                  minimumSize: Size(0, kh.spacing.buttonHeight - 8.0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n?.requestsActionInspect ?? 'Inspect',
                  style: kh.typography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.0,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  KhStatusTone _stateTone(RequestState state) {
    switch (state) {
      case RequestState.draft:
        return KhStatusTone.neutral;
      case RequestState.published:
        return KhStatusTone.moderation;
      case RequestState.offersReceived:
        return KhStatusTone.pending;
      case RequestState.accepted:
        return KhStatusTone.success;
      case RequestState.closed:
      case RequestState.expired:
        return KhStatusTone.neutral;
      case RequestState.cancelled:
      case RequestState.removed:
        return KhStatusTone.error;
    }
  }
}

class _RequestPaginationControls extends StatelessWidget {
  const _RequestPaginationControls({
    required this.listState,
    required this.controller,
  });

  final RequestListState listState;
  final RequestListController controller;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (listState.canLoadMore)
          OutlinedButton(
            key: const Key('request-load-more-button'),
            onPressed: listState.isLoadingMore ? null : controller.loadMore,
            child: listState.isLoadingMore
                ? const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
                : Text(l10n?.requestsLoadMore ?? 'Load more'),
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            OutlinedButton(
              key: const Key('request-page-prev'),
              onPressed: listState.canGoPrevious ? controller.previousPage : null,
              child: Text(l10n?.requestsPaginationPrevious ?? 'Previous'),
            ),
            SizedBox(width: kh.spacing.sm),
            Text(
              l10n?.requestsPaginationPage(listState.page) ??
                  'Page ${listState.page}',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textSecondary,
                fontSize: 12.0,
              ),
            ),
            SizedBox(width: kh.spacing.sm),
            OutlinedButton(
              key: const Key('request-page-next'),
              onPressed: listState.canGoNext ? controller.nextPage : null,
              child: Text(l10n?.requestsPaginationNext ?? 'Next'),
            ),
          ],
        ),
      ],
    );
  }
}

class _RequestEmptyView extends StatelessWidget {
  const _RequestEmptyView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48.0,
              color: kh.colors.textMuted,
            ),
            SizedBox(height: kh.spacing.md),
            Text(
              message,
              style: kh.typography.body.copyWith(
                color: kh.colors.textSecondary,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestErrorView extends StatelessWidget {
  const _RequestErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.0, color: kh.colors.error),
            SizedBox(height: kh.spacing.md),
            Text(
              message,
              style: kh.typography.body.copyWith(
                color: kh.colors.error,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kh.spacing.md),
            OutlinedButton(
              key: const Key('request-retry-button'),
              onPressed: onRetry,
              child: Text(l10n?.requestsRetry ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
