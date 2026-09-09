
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/customers/controller/customer_list_controller.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';
import 'package:kh_admin/features/customers/model/customer_list_item.dart';
import 'package:kh_admin/core/widgets/debounced_search_mixin.dart';

/// ADM-S03 · Customer list screen — browse and search customers with PII audit notice.
class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> with DebouncedSearchMixin {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final query = ref.read(customerListControllerProvider).filters.query;
    _searchController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    debounceSearch(() {
      ref.read(customerListControllerProvider.notifier).setSearchQuery(query);
      ref.read(customerListControllerProvider.notifier).submitSearch();
    });
  }

  void _onSearchSubmitted() {
    ref
        .read(customerListControllerProvider.notifier)
        .setSearchQuery(_searchController.text.trim());
    ref.read(customerListControllerProvider.notifier).submitSearch();
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final listState = ref.watch(customerListControllerProvider);
    final controller = ref.read(customerListControllerProvider.notifier);

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
              eyebrow: 'Customer Management',
              heading: 'Customers',
              supportingText:
                  'Directory of registered marketplace customers and buyers in the UAE',
            ),
            SizedBox(height: kh.spacing.md),
            const _PiiAuditNoticeBanner(),
            SizedBox(height: kh.spacing.lg),
            _CustomerFilterBar(
              key: const Key('customer-filter-bar'),
              filters: listState.filters,
              searchController: _searchController,
              onStateFilterChanged: (state) =>
                  controller.setAccountStateFilter(state),
              onSearchSubmitted: _onSearchSubmitted,
              onSearchChanged: _onSearchChanged,
            ),
            SizedBox(height: kh.spacing.lg),
            if (listState.isLoading)
              const Center(
                key: Key('customer-list-loading'),
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (listState.error != null && listState.items.isEmpty)
              _CustomerErrorView(
                message: listState.error!,
                onRetry: controller.refresh,
              )
            else if (listState.items.isEmpty)
              _CustomerEmptyView(
                onResetFilters: () {
                  _searchController.clear();
                  controller.applyFilters(const CustomerListFilters());
                },
              )
            else ...[
              _CustomerTable(items: listState.items),
              SizedBox(height: kh.spacing.md),
              _CustomerPaginationControls(
                listState: listState,
                controller: controller,
              ),
            ],
            if (listState.error != null && listState.items.isNotEmpty) ...[
              SizedBox(height: kh.spacing.sm),
              Text(
                listState.error!,
                style: kh.typography.bodySmall.copyWith(color: kh.colors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Prominent PII Audit Notice Banner compliant with UAE Data Protection Law.
class _PiiAuditNoticeBanner extends StatelessWidget {
  const _PiiAuditNoticeBanner();

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Container(
      key: const Key('pii-audit-notice-banner'),
      padding: EdgeInsets.symmetric(
        horizontal: kh.spacing.md,
        vertical: kh.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: kh.colors.goldPrimary.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(
          color: kh.colors.goldPrimary.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: kh.colors.goldPrimary,
            size: 20,
          ),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Text(
              'Customer personal data access is audited in accordance with UAE data protection policies.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter bar with search text field and account state filter chips.
class _CustomerFilterBar extends StatelessWidget {
  const _CustomerFilterBar({
    super.key,
    required this.filters,
    required this.searchController,
    required this.onStateFilterChanged,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
  });

  final CustomerListFilters filters;
  final TextEditingController searchController;
  final ValueChanged<CustomerAccountState?> onStateFilterChanged;
  final VoidCallback onSearchSubmitted;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  key: const Key('customer-search-input'),
                  controller: searchController,
                  onChanged: onSearchChanged,
                  onSubmitted: (_) => onSearchSubmitted(),
                  style: kh.typography.bodySmall,
                  decoration: InputDecoration(
                    hintText: 'Search by customer name, email, or mobile…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: kh.spacing.sm,
                      vertical: kh.spacing.xs,
                    ),
                    filled: true,
                    fillColor: kh.colors.backgroundElevated,
                    border: OutlineInputBorder(
                      borderRadius: kh.shapes.roundedMd,
                      borderSide: BorderSide(color: kh.colors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: kh.shapes.roundedMd,
                      borderSide: BorderSide(color: kh.colors.borderSubtle),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: kh.spacing.sm),
            ElevatedButton.icon(
              key: const Key('customer-search-submit-button'),
              onPressed: onSearchSubmitted,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kh.colors.goldPrimary,
                foregroundColor: Colors.black,
                minimumSize: const Size(100, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: kh.shapes.roundedMd,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: kh.spacing.sm),
        Wrap(
          spacing: kh.spacing.xs,
          runSpacing: kh.spacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'State:',
              style: kh.typography.caption.copyWith(
                color: kh.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            _FilterChipItem(
              key: const Key('state-filter-all'),
              label: 'All',
              isSelected: filters.accountState == null,
              onSelected: () => onStateFilterChanged(null),
            ),
            _FilterChipItem(
              key: const Key('state-filter-active'),
              label: 'Active',
              isSelected: filters.accountState == CustomerAccountState.active,
              onSelected: () =>
                  onStateFilterChanged(CustomerAccountState.active),
            ),
            _FilterChipItem(
              key: const Key('state-filter-suspended'),
              label: 'Suspended',
              isSelected: filters.accountState == CustomerAccountState.suspended,
              onSelected: () =>
                  onStateFilterChanged(CustomerAccountState.suspended),
            ),
            _FilterChipItem(
              key: const Key('state-filter-deactivated'),
              label: 'Deactivated',
              isSelected:
                  filters.accountState == CustomerAccountState.deactivated,
              onSelected: () =>
                  onStateFilterChanged(CustomerAccountState.deactivated),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: kh.typography.caption.copyWith(
        color: isSelected ? Colors.black : kh.colors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      selectedColor: kh.colors.goldPrimary,
      backgroundColor: kh.colors.backgroundElevated,
      side: BorderSide(
        color: isSelected ? kh.colors.goldPrimary : kh.colors.borderSubtle,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: kh.shapes.pill,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Data table displaying customer list rows.
class _CustomerTable extends StatelessWidget {
  const _CustomerTable({required this.items});

  final List<CustomerListItem> items;

  KhStatusTone _statusTone(CustomerAccountState state) {
    switch (state) {
      case CustomerAccountState.active:
        return KhStatusTone.success;
      case CustomerAccountState.suspended:
        return KhStatusTone.pending;
      case CustomerAccountState.deactivated:
        return KhStatusTone.error;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return KhDataTable(
      key: const Key('customer-list-table'),
      minWidth: 960,
      columns: const [
        KhTableColumn('Customer', flex: 3),
        KhTableColumn('Contact (Email / Phone)', flex: 3),
        KhTableColumn('State', flex: 2),
        KhTableColumn('Requests Count', flex: 1),
        KhTableColumn('Joined Date', flex: 2),
        KhTableColumn('Actions', flex: 1),
      ],
      rows: [
        for (final item in items)
          KhTableRow(
            key: Key('customer-row-${item.id}'),
            onTap: () => context.go('/customers/${item.id}'),
            cells: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        kh.colors.goldPrimary.withValues(alpha: 0.15),
                    child: Text(
                      item.displayName.isNotEmpty
                          ? item.displayName[0].toUpperCase()
                          : 'C',
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.goldPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: kh.spacing.sm),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.displayName.isNotEmpty
                              ? item.displayName
                              : 'Unnamed Customer',
                          overflow: TextOverflow.ellipsis,
                          style: kh.typography.bodySmall.copyWith(
                            color: kh.colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'ID: ${item.id.length > 8 ? item.id.substring(0, 8) : item.id}',
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.textMuted,
                            fontSize: 10.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.email ?? '—',
                    overflow: TextOverflow.ellipsis,
                    style: kh.typography.bodySmall.copyWith(
                      color: kh.colors.textPrimary,
                    ),
                  ),
                  if (item.mobileNumber != null && item.mobileNumber!.isNotEmpty)
                    Text(
                      item.mobileNumber!,
                      overflow: TextOverflow.ellipsis,
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textSecondary,
                      ),
                    ),
                ],
              ),
              KhStatusChip(
                label: item.accountState.displayName,
                tone: _statusTone(item.accountState),
                dense: true,
              ),
              Text(
                '${item.requestCount}',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(item.createdAt),
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                ),
              ),
              TextButton(
                key: Key('customer-action-view-${item.id}'),
                onPressed: () => context.go('/customers/${item.id}'),
                style: TextButton.styleFrom(
                  foregroundColor: kh.colors.goldPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: kh.spacing.xs,
                    vertical: kh.spacing.xxs,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('View'),
              ),
            ],
          ),
      ],
    );
  }
}

/// Pagination controls for the customer table.
class _CustomerPaginationControls extends StatelessWidget {
  const _CustomerPaginationControls({
    required this.listState,
    required this.controller,
  });

  final CustomerListState listState;
  final CustomerListController controller;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page ${listState.page} • ${listState.items.length} records shown',
          style: kh.typography.caption.copyWith(
            color: kh.colors.textSecondary,
          ),
        ),
        Row(
          children: [
            if (listState.canLoadMore) ...[
              OutlinedButton.icon(
                key: const Key('customer-load-more-button'),
                onPressed:
                    listState.isLoadingMore ? null : controller.loadMore,
                icon: listState.isLoadingMore
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add, size: 16),
                label: const Text('Load More'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kh.colors.textPrimary,
                  side: BorderSide(color: kh.colors.borderSubtle),
                ),
              ),
              SizedBox(width: kh.spacing.sm),
            ],
            IconButton.outlined(
              key: const Key('customer-prev-page-button'),
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  listState.canGoPrevious ? controller.previousPage : null,
              tooltip: 'Previous page',
            ),
            SizedBox(width: kh.spacing.xs),
            IconButton.outlined(
              key: const Key('customer-next-page-button'),
              icon: const Icon(Icons.chevron_right),
              onPressed: listState.canGoNext ? controller.nextPage : null,
              tooltip: 'Next page',
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomerEmptyView extends StatelessWidget {
  const _CustomerEmptyView({required this.onResetFilters});

  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Center(
      key: const Key('customer-list-empty'),
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: kh.colors.textMuted,
            ),
            SizedBox(height: kh.spacing.md),
            Text(
              'No customers found',
              style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
            ),
            SizedBox(height: kh.spacing.xs),
            Text(
              'No customers match the current search query or state filter.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textSecondary,
              ),
            ),
            SizedBox(height: kh.spacing.md),
            OutlinedButton(
              key: const Key('customer-reset-filters-button'),
              onPressed: onResetFilters,
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerErrorView extends StatelessWidget {
  const _CustomerErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Center(
      key: const Key('customer-list-error'),
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: kh.colors.error),
            SizedBox(height: kh.spacing.md),
            Text(
              'Failed to load customers',
              style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
            ),
            SizedBox(height: kh.spacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textSecondary,
              ),
            ),
            SizedBox(height: kh.spacing.md),
            ElevatedButton.icon(
              key: const Key('customer-retry-button'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
