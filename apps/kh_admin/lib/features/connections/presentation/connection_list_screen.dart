import 'dart:async';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/kh_theme.dart';
import '../../../core/design/widgets/kh_data_table.dart';
import '../../../core/design/widgets/kh_screen_header.dart';
import '../../../core/design/widgets/kh_status_chip.dart';
import '../controller/connection_list_controller.dart';
import '../model/connection_enums.dart';
import '../model/connection_list_filters.dart';
import '../model/connection_list_item.dart';

/// ADM-S12 · Connection list — Browse Introductions, monitor contact SLAs, and flag failed talks.
class ConnectionListScreen extends ConsumerStatefulWidget {
  const ConnectionListScreen({super.key});

  @override
  ConsumerState<ConnectionListScreen> createState() => _ConnectionListScreenState();
}

class _ConnectionListScreenState extends ConsumerState<ConnectionListScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final query = ref.read(connectionListControllerProvider).filters.query;
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
        ref.read(connectionListControllerProvider.notifier).setSearchQuery(query);
        ref.read(connectionListControllerProvider.notifier).submitSearch();
      }
    });
  }

  void _onSearchSubmitted() {
    _debounceTimer?.cancel();
    ref
        .read(connectionListControllerProvider.notifier)
        .setSearchQuery(_searchController.text.trim());
    ref.read(connectionListControllerProvider.notifier).submitSearch();
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final listState = ref.watch(connectionListControllerProvider);
    final controller = ref.read(connectionListControllerProvider.notifier);

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
              eyebrow: 'Marketplace Introductions',
              heading: 'Connections',
              supportingText:
                  'Browse customer-vendor introductions, monitor contact SLA, and flag failed Talk usage.',
            ),
            SizedBox(height: kh.spacing.lg),
            _ConnectionFilterBar(
              key: const Key('connection-filter-bar'),
              filters: listState.filters,
              searchController: _searchController,
              onStateChanged: (state) => controller.setStateFilter(state),
              onNoContactOnlyChanged: (val) => controller.applyFilters(
                listState.filters.copyWith(hasNoContactOnly: val),
              ),
              onSearchChanged: _onSearchChanged,
              onSearchSubmitted: _onSearchSubmitted,
            ),
            SizedBox(height: kh.spacing.lg),
            if (listState.isLoading)
              const Center(
                key: Key('connection-list-loading'),
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (listState.error != null && listState.items.isEmpty)
              _ConnectionErrorView(
                key: const Key('connection-error-view'),
                message: listState.error!,
                onRetry: controller.refresh,
              )
            else if (listState.items.isEmpty)
              const _ConnectionEmptyView(
                key: Key('connection-empty-view'),
                message: 'No connections match the current filter criteria.',
              )
            else ...[
              _ConnectionTable(
                items: listState.items,
              ),
              SizedBox(height: kh.spacing.md),
              _ConnectionPaginationControls(
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

class _ConnectionFilterBar extends StatelessWidget {
  const _ConnectionFilterBar({
    super.key,
    required this.filters,
    required this.searchController,
    required this.onStateChanged,
    required this.onNoContactOnlyChanged,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
  });

  final ConnectionListFilters filters;
  final TextEditingController searchController;
  final ValueChanged<ConnectionState?> onStateChanged;
  final ValueChanged<bool> onNoContactOnlyChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Wrap(
      spacing: kh.spacing.sm,
      runSpacing: kh.spacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // State Filter Tabs/Chips (All, Active, Closed)
        _StateChip(
          label: 'All',
          isSelected: filters.state == null,
          onTap: () => onStateChanged(null),
        ),
        _StateChip(
          label: 'Active',
          isSelected: filters.state == ConnectionState.active,
          onTap: () => onStateChanged(ConnectionState.active),
        ),
        _StateChip(
          label: 'Closed',
          isSelected: filters.state == ConnectionState.closed,
          onTap: () => onStateChanged(ConnectionState.closed),
        ),

        // SLA Warning Quick Filter Chip
        FilterChip(
          key: const Key('connection-filter-sla-breach'),
          selected: filters.hasNoContactOnly,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 14.0,
                color: filters.hasNoContactOnly ? kh.colors.error : kh.colors.textSecondary,
              ),
              const SizedBox(width: 4.0),
              const Text('No contact > 48h'),
            ],
          ),
          onSelected: onNoContactOnlyChanged,
        ),

        SizedBox(width: kh.spacing.sm),

        // Search Field
        SizedBox(
          width: 320.0,
          child: TextField(
            key: const Key('connection-filter-search'),
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Connection ID, customer, vendor…',
              isDense: true,
              suffixIcon: IconButton(
                key: const Key('connection-search-button'),
                icon: const Icon(Icons.search, size: 20.0),
                tooltip: 'Search connections',
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

class _StateChip extends StatelessWidget {
  const _StateChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: kh.typography.bodySmall.copyWith(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? kh.colors.goldPrimary : kh.colors.textPrimary,
      ),
      selectedColor: kh.colors.goldPrimary.withValues(alpha: 0.15),
      backgroundColor: kh.colors.backgroundElevated,
    );
  }
}

class _ConnectionTable extends StatelessWidget {
  const _ConnectionTable({
    required this.items,
  });

  final List<ConnectionListItem> items;

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
    final utc = dt.toUtc();
    final gst = utc.add(const Duration(hours: 4));
    final year = gst.year.toString().padLeft(4, '0');
    final month = gst.month.toString().padLeft(2, '0');
    final day = gst.day.toString().padLeft(2, '0');
    final hour = gst.hour.toString().padLeft(2, '0');
    final minute = gst.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  static String _formatRequestType(String? type) {
    if (type == null || type.isEmpty) return '—';
    switch (type) {
      case 'FIND_ORNAMENT':
        return 'Find Ornament';
      case 'SELL_OLD_GOLD':
        return 'Sell Old Gold';
      case 'GOLD_COIN':
        return 'Gold Coin';
      case 'GOLD_BULLION':
        return 'Gold Bullion';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return KhDataTable(
      key: const Key('connection-list-table'),
      minWidth: 1200.0,
      columns: const [
        KhTableColumn('Connection ID', flex: 2),
        KhTableColumn('Customer', flex: 3),
        KhTableColumn('Vendor', flex: 3),
        KhTableColumn('Request Type', flex: 2),
        KhTableColumn('Agreed Price (AED)', flex: 2),
        KhTableColumn('State', flex: 2),
        KhTableColumn('Contact Events', flex: 2),
        KhTableColumn('Last Contact', flex: 2),
        KhTableColumn('48h SLA Status', flex: 2),
      ],
      rows: [
        for (final item in items)
          KhTableRow(
            key: Key('connection-row-${item.id}'),
            onTap: () => context.go('/connections/${item.id}'),
            cells: [
              Text(
                item.id,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.goldPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.customerName,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.vendorName,
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                  fontSize: 13.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _formatRequestType(item.requestType),
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
              Text(
                _formatPrice(item.agreedPriceAed),
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
                '${item.contactEventsCount} event${item.contactEventsCount == 1 ? '' : 's'}',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
              Text(
                _formatDate(item.lastContactAt),
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                  fontSize: 12.0,
                ),
              ),
              if (item.hasNoContact48h)
                const KhStatusChip(
                  key: Key('sla-warning-chip'),
                  label: 'No contact > 48h',
                  tone: KhStatusTone.error,
                  dense: true,
                )
              else
                const KhStatusChip(
                  key: Key('sla-ok-chip'),
                  label: 'Within SLA',
                  tone: KhStatusTone.success,
                  dense: true,
                ),
            ],
          ),
      ],
    );
  }
}

class _ConnectionPaginationControls extends StatelessWidget {
  const _ConnectionPaginationControls({
    required this.listState,
    required this.controller,
  });

  final ConnectionListState listState;
  final ConnectionListController controller;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing ${listState.items.length} records · Page ${listState.page}',
          style: kh.typography.bodySmall.copyWith(
            color: kh.colors.textSecondary,
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              key: const Key('connection-pagination-previous'),
              icon: const Icon(Icons.chevron_left, size: 18.0),
              label: const Text('Previous'),
              onPressed: listState.canGoPrevious ? controller.previousPage : null,
            ),
            SizedBox(width: kh.spacing.sm),
            OutlinedButton.icon(
              key: const Key('connection-pagination-next'),
              icon: const Icon(Icons.chevron_right, size: 18.0),
              label: const Text('Next'),
              onPressed: listState.canGoNext ? controller.nextPage : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ConnectionErrorView extends StatelessWidget {
  const _ConnectionErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.0, color: kh.colors.error),
            SizedBox(height: kh.spacing.sm),
            Text(
              message,
              style: kh.typography.body.copyWith(color: kh.colors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kh.spacing.md),
            FilledButton.icon(
              key: const Key('connection-error-retry'),
              icon: const Icon(Icons.refresh, size: 16.0),
              label: const Text('Retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionEmptyView extends StatelessWidget {
  const _ConnectionEmptyView({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.connect_without_contact_outlined,
              size: 48.0,
              color: kh.colors.textMuted,
            ),
            SizedBox(height: kh.spacing.sm),
            Text(
              message,
              style: kh.typography.body.copyWith(color: kh.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
