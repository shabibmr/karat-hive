
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/router/vendor_query_params.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/vendors/controller/vendor_list_controller.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_filters.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_item.dart';
import 'package:kh_admin/core/widgets/debounced_search_mixin.dart';

/// ADM-S05 · Vendor list — browse and search vendors with verification filters.
class VendorListScreen extends ConsumerStatefulWidget {
  const VendorListScreen({super.key});

  @override
  ConsumerState<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends ConsumerState<VendorListScreen> with DebouncedSearchMixin {
  late final TextEditingController _searchController;
  Uri? _lastSyncedUri;

  @override
  void initState() {
    super.initState();
    final query = ref.read(vendorListControllerProvider).filters.query;
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

    final parsed = VendorQueryParams.fromUri(uri).toFilters();
    final current = ref.read(vendorListControllerProvider).filters;
    if (parsed == current) return;
    ref.read(vendorListControllerProvider.notifier).applyFilters(parsed);
    if (_searchController.text != parsed.query) {
      _searchController.text = parsed.query;
    }
  }

  void _applyFilters(VendorListFilters filters) {
    ref.read(vendorListControllerProvider.notifier).applyFilters(filters);
    context.updateVendorQuery(filters);
  }

  void _commitSearch(String query) {
    final controller = ref.read(vendorListControllerProvider.notifier);
    controller.setSearchQuery(query);
    controller.submitSearch();
    context.updateVendorQuery(ref.read(vendorListControllerProvider).filters);
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
    final listState = ref.watch(vendorListControllerProvider);
    final controller = ref.read(vendorListControllerProvider.notifier);

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
              eyebrow: l10n?.vendorsEyebrow ?? 'Vendor Management',
              heading: 'Vendors',
              supportingText:
                  'Directory of registered gold businesses and jewellers in the UAE',
            ),
            SizedBox(height: kh.spacing.lg),
            _VendorFilterBar(
              key: const Key('vendor-filter-bar'),
              filters: listState.filters,
              searchController: _searchController,
              onVerificationChanged: (value) => _applyFilters(
                listState.filters.copyWith(verificationState: value),
              ),
              onAccountChanged: (value) => _applyFilters(
                listState.filters.copyWith(accountState: value),
              ),
              onSearchSubmitted: _onSearchSubmitted,
              onSearchChanged: _onSearchChanged,
            ),
            SizedBox(height: kh.spacing.lg),
            if (listState.isLoading)
              const Center(
                key: Key('vendor-list-loading'),
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (listState.error != null && listState.items.isEmpty)
              _VendorErrorView(
                message: listState.error!,
                onRetry: controller.refresh,
              )
            else if (listState.items.isEmpty)
              _VendorEmptyView(
                message: l10n?.vendorsEmptyBody ??
                    'No vendors match the current filters.',
              )
            else ...[
              _VendorTable(
                items: listState.items,
                l10n: l10n,
              ),
              SizedBox(height: kh.spacing.md),
              _VendorPaginationControls(
                listState: listState,
                controller: controller,
                l10n: l10n,
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

class _VendorFilterBar extends StatelessWidget {
  const _VendorFilterBar({
    super.key,
    required this.filters,
    required this.searchController,
    required this.onVerificationChanged,
    required this.onAccountChanged,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
  });

  final VendorListFilters filters;
  final TextEditingController searchController;
  final ValueChanged<VendorVerificationState?> onVerificationChanged;
  final ValueChanged<VendorAccountState?> onAccountChanged;
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
          width: 240,
          child: DropdownButtonFormField<VendorVerificationState?>(
            key: const Key('vendor-filter-verification'),
            initialValue: filters.verificationState,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n?.vendorsFilterVerification ?? 'Verification state',
              isDense: true,
            ),
            items: [
              DropdownMenuItem<VendorVerificationState?>(
                value: null,
                child: Text(l10n?.vendorsFilterAll ?? 'All'),
              ),
              for (final state in VendorVerificationState.values)
                DropdownMenuItem(
                  value: state,
                  child: Text(_verificationLabel(l10n, state)),
                ),
            ],
            onChanged: onVerificationChanged,
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<VendorAccountState?>(
            key: const Key('vendor-filter-account'),
            initialValue: filters.accountState,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n?.vendorsFilterAccount ?? 'Account state',
              isDense: true,
            ),
            items: [
              DropdownMenuItem<VendorAccountState?>(
                value: null,
                child: Text(l10n?.vendorsFilterAll ?? 'All'),
              ),
              for (final state in VendorAccountState.values)
                DropdownMenuItem(
                  value: state,
                  child: Text(_accountLabel(l10n, state)),
                ),
            ],
            onChanged: onAccountChanged,
          ),
        ),
        SizedBox(
          width: 300,
          child: TextField(
            key: const Key('vendor-filter-search'),
            controller: searchController,
            decoration: InputDecoration(
              labelText: l10n?.vendorsFilterSearch ?? 'Search',
              hintText: l10n?.vendorsFilterSearchHint ??
                  'Business name, licence, mobile…',
              isDense: true,
              suffixIcon: IconButton(
                key: const Key('vendor-search-button'),
                icon: const Icon(Icons.search, size: 20),
                tooltip: l10n?.vendorsFilterSearch ?? 'Search',
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

class _VendorTable extends StatelessWidget {
  const _VendorTable({
    required this.items,
    required this.l10n,
  });

  final List<VendorListItem> items;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return KhDataTable(
      key: const Key('vendor-list-table'),
      minWidth: 1080,
      columns: [
        KhTableColumn(l10n?.vendorsColumnBusiness ?? 'Business Name', flex: 3),
        const KhTableColumn('Trade Licence', flex: 2),
        const KhTableColumn('Region', flex: 2),
        KhTableColumn(l10n?.vendorsColumnVerification ?? 'Verification State', flex: 2),
        KhTableColumn(l10n?.vendorsColumnAccount ?? 'Account State', flex: 2),
        const KhTableColumn('Offer Count', flex: 1),
        const KhTableColumn('Acceptance Rate', flex: 1),
        const KhTableColumn('Rating', flex: 1),
        KhTableColumn(l10n?.vendorsColumnAction ?? 'Action', flex: 2),
      ],
      rows: [
        for (final item in items)
          KhTableRow(
            key: Key('vendor-row-${item.id}'),
            onTap: () => context.go('/vendors/${item.id}'),
            cells: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.legalBusinessName,
                    style: kh.typography.bodySmall.copyWith(
                      color: kh.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.tradingName.isNotEmpty &&
                      item.tradingName != item.legalBusinessName)
                    Text(
                      item.tradingName,
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textMuted,
                      ),
                    ),
                ],
              ),
              Text(
                item.tradeLicenceNumber ?? '—',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                ),
              ),
              Text(
                item.region ?? '—',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  KhStatusChip(
                    label: _verificationLabel(l10n, item.verificationState),
                    tone: _verificationTone(item.verificationState),
                    dense: true,
                  ),
                  if (item.verificationState ==
                          VendorVerificationState.pendingVerification &&
                      item.waitingHours != null) ...[
                    SizedBox(height: kh.spacing.xxs),
                    Text(
                      l10n?.vendorsWaitingHours(item.waitingHours!) ??
                          '${item.waitingHours}h waiting',
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.warning,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ],
              ),
              KhStatusChip(
                label: _accountLabel(l10n, item.accountState),
                tone: _accountTone(item.accountState),
                dense: true,
              ),
              Text(
                item.offerCount != null ? '${item.offerCount}' : '—',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textPrimary,
                ),
              ),
              Text(
                item.acceptanceRate != null
                    ? '${(item.acceptanceRate! * 100).toStringAsFixed(0)}%'
                    : '—',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textSecondary,
                ),
              ),
              Text(
                item.rating != null
                    ? '★ ${item.rating!.toStringAsFixed(1)}'
                    : '—',
                style: kh.typography.bodySmall.copyWith(
                  color: item.rating != null
                      ? kh.colors.goldPrimary
                      : kh.colors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _VendorRowAction(item: item, l10n: l10n),
            ],
          ),
      ],
    );
  }
}

class _VendorRowAction extends StatelessWidget {
  const _VendorRowAction({
    required this.item,
    required this.l10n,
  });

  final VendorListItem item;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final isPending =
        item.verificationState == VendorVerificationState.pendingVerification;

    return OutlinedButton(
      key: Key('vendor-action-${item.id}'),
      onPressed: () {
        if (isPending) {
          context.go('/verification?selectedId=${item.id}');
        } else {
          context.go('/vendors/${item.id}');
        }
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: kh.spacing.sm,
          vertical: kh.spacing.xxs,
        ),
        minimumSize: Size(0, kh.spacing.buttonHeight - 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        isPending
            ? (l10n?.vendorsActionReviewKyc ?? 'Review KYC')
            : (l10n?.vendorsActionView ?? 'View'),
        style: kh.typography.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _VendorPaginationControls extends StatelessWidget {
  const _VendorPaginationControls({
    required this.listState,
    required this.controller,
    required this.l10n,
  });

  final VendorListState listState;
  final VendorListController controller;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (listState.canLoadMore)
          OutlinedButton(
            key: const Key('vendor-load-more-button'),
            onPressed: listState.isLoadingMore ? null : controller.loadMore,
            child: listState.isLoadingMore
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n?.vendorsLoadMore ?? 'Load more'),
          )
        else
          const SizedBox.shrink(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              key: const Key('vendor-prev-page-button'),
              onPressed: listState.canGoPrevious
                  ? (listState.isLoadingMore ? null : controller.previousPage)
                  : null,
              child: const Text('Previous'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: kh.spacing.md),
              child: Text(
                'Page ${listState.page}',
                key: const Key('vendor-current-page'),
                style: kh.typography.caption.copyWith(
                  color: kh.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            OutlinedButton(
              key: const Key('vendor-next-page-button'),
              onPressed: listState.canGoNext
                  ? (listState.isLoadingMore ? null : controller.nextPage)
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}

class _VendorEmptyView extends StatelessWidget {
  const _VendorEmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      key: const Key('vendor-empty-view'),
      width: double.infinity,
      padding: EdgeInsets.all(kh.spacing.xl),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(Icons.storefront_outlined, size: 40, color: kh.colors.textMuted),
          SizedBox(height: kh.spacing.sm),
          Text(
            l10n?.vendorsEmptyTitle ?? 'No vendors found',
            style: kh.typography.title,
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: kh.typography.bodySmall.copyWith(
              color: kh.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorErrorView extends StatelessWidget {
  const _VendorErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      key: const Key('vendor-error-view'),
      width: double.infinity,
      padding: EdgeInsets.all(kh.spacing.xl),
      decoration: BoxDecoration(
        color: kh.colors.error.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            l10n?.vendorsErrorTitle ?? 'Unable to load vendors',
            style: kh.typography.title.copyWith(color: kh.colors.error),
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
          ElevatedButton(
            key: const Key('vendor-retry-button'),
            onPressed: onRetry,
            child: Text(l10n?.vendorsRetry ?? 'Try again'),
          ),
        ],
      ),
    );
  }
}

String _verificationLabel(AppLocalizations? l10n, VendorVerificationState state) {
  switch (state) {
    case VendorVerificationState.registered:
      return l10n?.vendorsVerificationRegistered ?? 'REGISTERED';
    case VendorVerificationState.pendingVerification:
      return l10n?.vendorsVerificationPending ?? 'PENDING VERIFICATION';
    case VendorVerificationState.verified:
      return l10n?.vendorsVerificationVerified ?? 'VERIFIED';
    case VendorVerificationState.rejected:
      return l10n?.vendorsVerificationRejected ?? 'REJECTED';
  }
}

String _accountLabel(AppLocalizations? l10n, VendorAccountState state) {
  switch (state) {
    case VendorAccountState.active:
      return l10n?.vendorsAccountActive ?? 'ACTIVE';
    case VendorAccountState.suspended:
      return l10n?.vendorsAccountSuspended ?? 'SUSPENDED';
    case VendorAccountState.deactivated:
      return l10n?.vendorsAccountDeactivated ?? 'DEACTIVATED';
  }
}

KhStatusTone _verificationTone(VendorVerificationState state) {
  switch (state) {
    case VendorVerificationState.verified:
      return KhStatusTone.success;
    case VendorVerificationState.pendingVerification:
      return KhStatusTone.pending;
    case VendorVerificationState.rejected:
      return KhStatusTone.error;
    case VendorVerificationState.registered:
      return KhStatusTone.neutral;
  }
}

KhStatusTone _accountTone(VendorAccountState state) {
  switch (state) {
    case VendorAccountState.active:
      return KhStatusTone.success;
    case VendorAccountState.suspended:
      return KhStatusTone.pending;
    case VendorAccountState.deactivated:
      return KhStatusTone.error;
  }
}
