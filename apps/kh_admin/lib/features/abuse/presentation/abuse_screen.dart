
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/abuse/controller/abuse_controller.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_item.dart';
import 'package:kh_admin/core/router/abuse_query_params.dart';
import 'package:kh_admin/core/widgets/debounced_search_mixin.dart';

/// ADM-S21 · Abuse report queue — Triage customer and vendor abuse reports.
class AbuseScreen extends ConsumerStatefulWidget {
  const AbuseScreen({super.key});

  @override
  ConsumerState<AbuseScreen> createState() => _AbuseScreenState();
}

class _AbuseScreenState extends ConsumerState<AbuseScreen> with DebouncedSearchMixin {
  late final TextEditingController _searchController;
  Uri? _lastSyncedUri;

  /// Report id from a `?selected=` deep-link (dashboard drill-down, `TR-S6-05`).
  /// Opened once the matching row has loaded, then cleared.
  String? _pendingSelectedId;

  @override
  void initState() {
    super.initState();
    final query = ref.read(abuseListControllerProvider).filters.query;
    _searchController = TextEditingController(text: query);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFromUri();
  }

  void _syncFromUri() {
    Uri uri;
    try {
      uri = GoRouterState.of(context).uri;
    } on Object catch (_) {
      return;
    }
    if (uri == _lastSyncedUri) return;
    _lastSyncedUri = uri;

    final deepLink = AbuseQueryParams.fromUri(uri);
    if (deepLink.selectedId != null && deepLink.selectedId!.isNotEmpty) {
      _pendingSelectedId = deepLink.selectedId;
    }

    final parsed = deepLink.toFilters();
    final current = ref.read(abuseListControllerProvider).filters;
    if (parsed == current) return;
    ref.read(abuseListControllerProvider.notifier).applyFilters(parsed);
    if (_searchController.text != parsed.query) {
      _searchController.text = parsed.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    debounceSearch(() {
      ref.read(abuseListControllerProvider.notifier).setSearchQuery(query);
      ref.read(abuseListControllerProvider.notifier).submitSearch();
    });
  }

  void _onSearchSubmitted() {
    ref.read(abuseListControllerProvider.notifier).setSearchQuery(_searchController.text.trim());
    ref.read(abuseListControllerProvider.notifier).submitSearch();
  }

  String _shortId(String id, [int maxLen = 8]) =>
      id.length > maxLen ? id.substring(0, maxLen) : id;

  String _formatDateTime(DateTime dt, [int maxLen = 16]) {
    final str = dt.toLocal().toString();
    return str.length >= maxLen ? str.substring(0, maxLen) : str;
  }

  /// FR-ADM-032 AC3 — one rationale-gated dialog for all four resolutions
  /// (dismiss / warn / suspend / deactivate).
  void _showActionDialog(AbuseReportItem item, AbuseReportAction action) {
    final rationaleController = TextEditingController();
    final reportedLabel = item.reportedName ?? _shortId(item.reportedUserId);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        final destructive =
            action != AbuseReportAction.warn && action != AbuseReportAction.dismiss;
        return AlertDialog(
          title: Text('${action.label} · Report #${_shortId(item.id)}'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (action) {
                    AbuseReportAction.dismiss =>
                      'Closes the report as DISMISSED with no sanction. Explain why no violation was found.',
                    AbuseReportAction.warn =>
                      'Records a formal warning against $reportedLabel and resolves the report. Their account is not changed.',
                    AbuseReportAction.suspend =>
                      'Suspends $reportedLabel\'s account and resolves the report. They regain access only on Admin reactivation.',
                    AbuseReportAction.deactivate =>
                      'Deactivates $reportedLabel\'s account and resolves the report.',
                  },
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
                ),
                SizedBox(height: kh.spacing.md),
                TextField(
                  key: const Key('abuse-action-rationale-field'),
                  controller: rationaleController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Rationale *',
                    hintText:
                        'e.g. Repeated off-platform solicitation after a prior caution.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('abuse-confirm-action-button'),
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: kh.colors.error)
                  : null,
              onPressed: () async {
                final rationale = rationaleController.text.trim();
                if (rationale.isEmpty) return;
                Navigator.of(dialogCtx).pop();
                final success = await ref
                    .read(abuseListControllerProvider.notifier)
                    .actionReport(item.id, action, rationale);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Report #${_shortId(item.id)} ${action.pastTense}'
                          : 'Could not action report #${_shortId(item.id)} — please retry'),
                    ),
                  );
                }
              },
              child: Text(action.label),
            ),
          ],
        );
      },
    );
  }

  /// Action menu shown on open / under-review reports. Pass [child] to render a
  /// labelled trigger (detail dialog) instead of the compact icon (table row).
  Widget _actionMenu(AbuseReportItem item, {required Key key, Widget? child}) {
    return PopupMenuButton<AbuseReportAction>(
      key: key,
      tooltip: 'Take action',
      icon: child == null ? const Icon(Icons.gavel_outlined, size: 18) : null,
      child: child,
      onSelected: (action) => _showActionDialog(item, action),
      itemBuilder: (context) => [
        for (final action in AbuseReportAction.values)
          PopupMenuItem<AbuseReportAction>(
            value: action,
            child: Text(action.label),
          ),
      ],
    );
  }

  void _showDetailDialog(BuildContext context, AbuseReportItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        return AlertDialog(
          title: Text('Abuse Report Detail #${item.id}'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow('Status', item.state.label),
                  _detailRow('Category', item.category),
                  _detailRow('Date Created', _formatDateTime(item.createdAt)),
                  _detailRow('Target Entity', '${item.entityType.label} (${item.entityId})'),
                  _detailRow('Reported Party', item.reportedName ?? item.reportedUserId),
                  if (item.reportedEmail != null) _detailRow('Reported Email', item.reportedEmail!),
                  if (item.reportedPhone != null) _detailRow('Reported Mobile', item.reportedPhone!),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Text('Reporter Info', style: kh.typography.subtitle),
                      SizedBox(width: kh.spacing.xs),
                      Text('(Confidential - Admin only)',
                          style: kh.typography.bodySmall.copyWith(color: kh.colors.warning)),
                    ],
                  ),
                  SizedBox(height: kh.spacing.xs),
                  _detailRow('Reporter Name', item.reporterName ?? item.reporterUserId),
                  if (item.reporterEmail != null) _detailRow('Reporter Email', item.reporterEmail!),
                  if (item.reporterPhone != null) _detailRow('Reporter Mobile', item.reporterPhone!),
                  const Divider(height: 24),
                  Text('Description / Evidence', style: kh.typography.subtitle),
                  SizedBox(height: kh.spacing.xs),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(kh.spacing.sm),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(item.description, style: kh.typography.body),
                  ),
                  if (item.resolution != null && item.resolution!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text('Resolution', style: kh.typography.subtitle),
                    SizedBox(height: kh.spacing.xs),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(kh.spacing.sm),
                      decoration: BoxDecoration(
                        color: kh.colors.backgroundPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.resolution!, style: kh.typography.body),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            if (item.state == AbuseReportState.open ||
                item.state == AbuseReportState.underReview)
              _actionMenu(
                item,
                key: const Key('abuse-detail-action-menu'),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: kh.spacing.md,
                    vertical: kh.spacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Take action'),
                      Icon(Icons.arrow_drop_down, size: 18),
                    ],
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _navigateToEntity(BuildContext context, AbuseReportItem item) {
    switch (item.entityType) {
      case AbuseEntityType.request:
        context.go('/requests/${item.entityId}');
        break;
      case AbuseEntityType.offer:
        context.go('/offers/${item.entityId}');
        break;
      case AbuseEntityType.connection:
        context.go('/connections/${item.entityId}');
        break;
      case AbuseEntityType.vendor:
        context.go('/vendors/${item.entityId}');
        break;
      case AbuseEntityType.customer:
        context.go('/customers/${item.entityId}');
        break;
      case AbuseEntityType.review:
        context.go('/moderation');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AbuseReportFilters>(
      abuseListControllerProvider.select((s) => s.filters),
      (prev, next) {
        if (prev != next) {
          context.updateAbuseQuery(next);
        }
      },
    );

    final kh = context.kh;
    final state = ref.watch(abuseListControllerProvider);
    final controller = ref.read(abuseListControllerProvider.notifier);

    if (_searchController.text != state.filters.query &&
        !_searchController.selection.isValid) {
      _searchController.text = state.filters.query;
    }

    final openCount = state.items.where((i) => i.state == AbuseReportState.open).length;
    final underReviewCount = state.items.where((i) => i.state == AbuseReportState.underReview).length;
    final resolvedCount = state.items.where((i) => i.state == AbuseReportState.resolved).length;
    final dismissedCount = state.items.where((i) => i.state == AbuseReportState.dismissed).length;

    // Dashboard drill-down (`TR-S6-05`): open the deep-linked report once its row
    // has loaded.
    if (_pendingSelectedId != null && !state.isLoading) {
      final targetId = _pendingSelectedId!;
      _pendingSelectedId = null;
      final matches = state.items.where((i) => i.id == targetId).toList();
      if (matches.isNotEmpty) {
        final match = matches.first;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showDetailDialog(context, match);
        });
      }
    }

    return Material(
      color: kh.colors.backgroundSurface,
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KhScreenHeader(
              eyebrow: 'Trust & Safety Queue',
              heading: 'Abuse Report Queue',
              supportingText:
                  'Triage customer and vendor abuse reports, investigate infractions, and resolve or dismiss with mandatory rationale. Reporter identity is never disclosed to reported parties.',
            ),
            SizedBox(height: kh.spacing.lg),
            // Metric cards
            Row(
              children: [
                Expanded(
                  child: KhMetricCard(
                    label: 'Open Reports',
                    value: state.isLoading ? '-' : '$openCount',
                    linkText: 'View',
                    onTap: () => controller.setStateFilter(AbuseReportState.open),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Under Review',
                    value: state.isLoading ? '-' : '$underReviewCount',
                    linkText: 'View',
                    onTap: () => controller.setStateFilter(AbuseReportState.underReview),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Resolved',
                    value: state.isLoading ? '-' : '$resolvedCount',
                    linkText: 'View',
                    onTap: () => controller.setStateFilter(AbuseReportState.resolved),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Dismissed',
                    value: state.isLoading ? '-' : '$dismissedCount',
                    linkText: 'View',
                    onTap: () => controller.setStateFilter(AbuseReportState.dismissed),
                  ),
                ),
              ],
            ),
            SizedBox(height: kh.spacing.lg),
            // Filter bar
            _AbuseFilterBar(
              filters: state.filters,
              searchController: _searchController,
              onStateChanged: controller.setStateFilter,
              onEntityTypeChanged: controller.setEntityTypeFilter,
              onSearchChanged: _onSearchChanged,
              onSearchSubmitted: _onSearchSubmitted,
            ),
            SizedBox(height: kh.spacing.lg),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return const Center(
                      key: Key('abuse-list-loading'),
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (state.errorMessage != null) {
                    return Container(
                      key: const Key('abuse-list-error'),
                      padding: EdgeInsets.all(kh.spacing.lg),
                      decoration: BoxDecoration(
                        color: kh.colors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kh.colors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: kh.colors.error),
                          SizedBox(width: kh.spacing.md),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: kh.typography.body.copyWith(color: kh.colors.error),
                            ),
                          ),
                          TextButton(
                            onPressed: controller.refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state.items.isEmpty) {
                    return Container(
                      key: const Key('abuse-list-empty'),
                      padding: EdgeInsets.all(kh.spacing.xxl),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kh.colors.backgroundElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kh.colors.borderStandard),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 48, color: kh.colors.textMuted),
                          SizedBox(height: kh.spacing.md),
                          Text('No abuse reports found', style: kh.typography.title),
                          SizedBox(height: kh.spacing.xs),
                          Text(
                            'No reports match the current filters.',
                            style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: KhDataTable(
                          columns: const [
                            KhTableColumn('Date', flex: 2),
                            KhTableColumn('Category', flex: 2),
                            KhTableColumn('Reported Party', flex: 2),
                            KhTableColumn('Target Entity', flex: 2),
                            KhTableColumn('Status', flex: 2),
                            KhTableColumn('Actions', flex: 3),
                          ],
                          rows: state.items.map((item) {
                            final dateStr = _formatDateTime(item.createdAt, 10);
                            KhStatusTone tone = KhStatusTone.neutral;
                            if (item.state == AbuseReportState.open) {
                              tone = KhStatusTone.error;
                            } else if (item.state == AbuseReportState.underReview) {
                              tone = KhStatusTone.pending;
                            } else if (item.state == AbuseReportState.resolved) {
                              tone = KhStatusTone.success;
                            }

                            return KhTableRow(
                              key: ValueKey(item.id),
                              onTap: () => _showDetailDialog(context, item),
                              cells: [
                                Text(dateStr, style: kh.typography.bodySmall),
                                Text(
                                  item.category,
                                  style: kh.typography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  item.reportedName ?? _shortId(item.reportedUserId),
                                  style: kh.typography.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                InkWell(
                                  onTap: () => _navigateToEntity(context, item),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.entityType.label,
                                        style: kh.typography.bodySmall.copyWith(
                                          color: kh.colors.accentPrimary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      SizedBox(width: kh.spacing.xxs),
                                      Icon(Icons.open_in_new, size: 14, color: kh.colors.accentPrimary),
                                    ],
                                  ),
                                ),
                                KhStatusChip(
                                  label: item.state.label,
                                  tone: tone,
                                  dense: true,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info_outline, size: 18),
                                      tooltip: 'View details',
                                      onPressed: () => _showDetailDialog(context, item),
                                    ),
                                    if (item.state == AbuseReportState.open ||
                                        item.state == AbuseReportState.underReview)
                                      _actionMenu(
                                        item,
                                        key: Key('abuse-action-menu-${item.id}'),
                                      ),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      if (state.hasMore) ...[
                        SizedBox(height: kh.spacing.lg),
                        Center(
                          child: OutlinedButton(
                            onPressed: controller.loadMore,
                            child: const Text('Load More Reports'),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbuseFilterBar extends StatelessWidget {
  const _AbuseFilterBar({
    required this.filters,
    required this.searchController,
    required this.onStateChanged,
    required this.onEntityTypeChanged,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
  });

  final AbuseReportFilters filters;
  final TextEditingController searchController;
  final ValueChanged<AbuseReportState?> onStateChanged;
  final ValueChanged<AbuseEntityType?> onEntityTypeChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Container(
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kh.colors.borderStandard),
      ),
      child: Wrap(
        spacing: kh.spacing.md,
        runSpacing: kh.spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 240,
            child: TextField(
              key: const Key('abuse-search-input'),
              controller: searchController,
              onChanged: onSearchChanged,
              onSubmitted: (_) => onSearchSubmitted(),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search description, entity, party...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                          onSearchSubmitted();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
          DropdownButton<AbuseReportState?>(
            key: const Key('abuse-state-filter'),
            value: filters.state,
            hint: const Text('All States'),
            items: [
              const DropdownMenuItem<AbuseReportState?>(
                value: null,
                child: Text('All States'),
              ),
              ...AbuseReportState.values.map(
                (s) => DropdownMenuItem<AbuseReportState?>(
                  value: s,
                  child: Text(s.label),
                ),
              ),
            ],
            onChanged: onStateChanged,
          ),
          DropdownButton<AbuseEntityType?>(
            key: const Key('abuse-entity-filter'),
            value: filters.entityType,
            hint: const Text('All Entities'),
            items: [
              const DropdownMenuItem<AbuseEntityType?>(
                value: null,
                child: Text('All Entities'),
              ),
              ...AbuseEntityType.values.map(
                (e) => DropdownMenuItem<AbuseEntityType?>(
                  value: e,
                  child: Text(e.label),
                ),
              ),
            ],
            onChanged: onEntityTypeChanged,
          ),
        ],
      ),
    );
  }
}
