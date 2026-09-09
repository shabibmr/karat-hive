
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/announcement_query_params.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/announcements/controller/announcement_controller.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/model/create_announcement_dto.dart';
import 'package:kh_admin/core/widgets/debounced_search_mixin.dart';

/// ADM-S18 · Announcement Composer — Broadcast system alerts and marketing notifications.
class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> with DebouncedSearchMixin {
  late final TextEditingController _searchController;
  Uri? _lastSyncedUri;

  @override
  void initState() {
    super.initState();
    final query = ref.read(announcementListControllerProvider).filters.query;
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

    final parsed = AnnouncementQueryParams.fromUri(uri).toFilters();
    final current = ref.read(announcementListControllerProvider).filters;
    if (parsed == current) return;
    ref.read(announcementListControllerProvider.notifier).applyFilters(parsed);
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
      ref.read(announcementListControllerProvider.notifier).setSearchQuery(query);
      ref.read(announcementListControllerProvider.notifier).submitSearch();
    });
  }

  void _onSearchSubmitted() {
    ref
        .read(announcementListControllerProvider.notifier)
        .setSearchQuery(_searchController.text.trim());
    ref.read(announcementListControllerProvider.notifier).submitSearch();
  }

  String _shortId(String id, [int maxLen = 8]) =>
      id.length > maxLen ? id.substring(0, maxLen) : id;

  String _formatDateTime(DateTime? dt, [int maxLen = 16]) {
    if (dt == null) return '-';
    final str = dt.toLocal().toString();
    return str.length >= maxLen ? str.substring(0, maxLen) : str;
  }

  void _showComposeDialog(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _ComposeAnnouncementDialog(
        onSubmit: (dto) async {
          final success = await ref
              .read(announcementListControllerProvider.notifier)
              .createAnnouncement(dto);
          if (!mounted || !success) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(dto.scheduledFor != null
                  ? 'Announcement scheduled successfully'
                  : 'Announcement published successfully'),
            ),
          );
        },
      ),
    );
  }

  void _showDetailDialog(BuildContext context, AnnouncementItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        KhStatusTone tone = KhStatusTone.neutral;
        switch (item.status) {
          case AnnouncementStatus.scheduled:
            tone = KhStatusTone.pending;
            break;
          case AnnouncementStatus.dispatched:
            tone = KhStatusTone.success;
            break;
          case AnnouncementStatus.cancelled:
            tone = KhStatusTone.error;
            break;
          case AnnouncementStatus.draft:
            tone = KhStatusTone.neutral;
            break;
        }

        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Announcement #${_shortId(item.id)}',
                  style: kh.typography.title,
                ),
              ),
              KhStatusChip(label: item.status.label, tone: tone, dense: true),
            ],
          ),
          content: SizedBox(
            width: 580,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badges row
                  Wrap(
                    spacing: kh.spacing.sm,
                    runSpacing: kh.spacing.xs,
                    children: [
                      Chip(
                        label: Text('Audience: ${item.audienceType.label}'),
                        backgroundColor: kh.colors.backgroundElevated,
                        side: BorderSide(color: kh.colors.borderSubtle),
                      ),
                      Chip(
                        label: Text('Channels: ${item.channels.displayString}'),
                        backgroundColor: kh.colors.backgroundElevated,
                        side: BorderSide(color: kh.colors.borderSubtle),
                      ),
                      if (item.critical)
                        Chip(
                          avatar: Icon(Icons.warning_amber_rounded,
                              size: 16, color: kh.colors.error),
                          label: Text(
                            'CRITICAL',
                            style: TextStyle(
                              color: kh.colors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: kh.colors.error.withValues(alpha: 0.12),
                          side: BorderSide(color: kh.colors.error.withValues(alpha: 0.3)),
                        ),
                    ],
                  ),
                  SizedBox(height: kh.spacing.md),
                  // English Content
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(kh.spacing.md),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundElevated,
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ENGLISH CONTENT',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.goldPrimary,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(height: kh.spacing.xs),
                        Text(item.titleEn,
                            style: kh.typography.body.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: kh.spacing.xs),
                        Text(item.bodyEn, style: kh.typography.bodySmall),
                      ],
                    ),
                  ),
                  SizedBox(height: kh.spacing.md),
                  // Arabic Content
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(kh.spacing.md),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundElevated,
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('المحتوى باللغة العربية',
                              style: kh.typography.caption.copyWith(
                                color: kh.colors.goldPrimary,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(height: kh.spacing.xs),
                          Text(item.titleAr,
                              style: kh.typography.body.copyWith(fontWeight: FontWeight.bold)),
                          SizedBox(height: kh.spacing.xs),
                          Text(item.bodyAr, style: kh.typography.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: kh.spacing.md),
                  // Delivery & Schedule Metadata
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(kh.spacing.md),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundElevated,
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DISPATCH & SCHEDULE DETAILS',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.goldPrimary,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(height: kh.spacing.xs),
                        Text('Created By: ${item.createdByDisplayName ?? "Admin"}',
                            style: kh.typography.bodySmall),
                        Text('Created At: ${_formatDateTime(item.createdAt)}',
                            style: kh.typography.bodySmall),
                        if (item.scheduledFor != null)
                          Text('Scheduled For: ${_formatDateTime(item.scheduledFor)}',
                              style: kh.typography.bodySmall),
                        if (item.cancelledAt != null)
                          Text('Cancelled At: ${_formatDateTime(item.cancelledAt)}',
                              style: kh.typography.bodySmall.copyWith(color: kh.colors.error)),
                        SizedBox(height: kh.spacing.sm),
                        // Delivery Stats
                        if (item.dispatchStats != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: KhMetricCard(
                                  label: 'Sent',
                                  value: '${item.dispatchStats!.sent}',
                                  linkText: 'Dispatched',
                                  valueColor: kh.colors.info,
                                ),
                              ),
                              SizedBox(width: kh.spacing.md),
                              Expanded(
                                child: KhMetricCard(
                                  label: 'Delivered',
                                  value: '${item.dispatchStats!.delivered}',
                                  linkText: 'Confirmed',
                                  valueColor: kh.colors.success,
                                ),
                              ),
                              SizedBox(width: kh.spacing.md),
                              Expanded(
                                child: KhMetricCard(
                                  label: 'Opened',
                                  value: '${item.dispatchStats!.opened}',
                                  linkText: 'Read',
                                  valueColor: kh.colors.goldPrimary,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            padding: EdgeInsets.all(kh.spacing.sm),
                            decoration: BoxDecoration(
                              color: kh.colors.gold400.withValues(alpha: 0.08),
                              borderRadius: kh.shapes.roundedSm,
                              border: Border.all(color: kh.colors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: kh.colors.goldPrimary),
                                SizedBox(width: kh.spacing.xs),
                                Expanded(
                                  child: Text(
                                    'SAM-GAP-10: Recipient counts are evaluated dynamically at scheduled dispatch.',
                                    style: kh.typography.caption.copyWith(color: kh.colors.goldPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (item.canCancel)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: kh.colors.error),
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  _showCancelDialog(context, item);
                },
                child: const Text('Cancel Announcement'),
              ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  void _showCancelDialog(BuildContext context, AnnouncementItem item) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        return AlertDialog(
          title: Text('Cancel Announcement #${_shortId(item.id)}'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to cancel "${item.titleEn}"? This announcement will not be dispatched.',
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
                ),
                SizedBox(height: kh.spacing.sm),
                Text(
                  'Note: Announcements cannot be cancelled once dispatch has begun.',
                  style: kh.typography.caption.copyWith(color: kh.colors.warning),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Back'),
            ),
            FilledButton(
              key: const Key('announcement-confirm-cancel-button'),
              style: FilledButton.styleFrom(backgroundColor: kh.colors.error),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final success = await ref
                    .read(announcementListControllerProvider.notifier)
                    .cancelAnnouncement(item.id);
                if (!mounted || !success) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Announcement #${_shortId(item.id)} cancelled'),
                  ),
                );
              },
              child: const Text('Cancel Announcement'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AnnouncementFilters>(
      announcementListControllerProvider.select((s) => s.filters),
      (prev, next) {
        if (prev != next) {
          context.updateAnnouncementQuery(next);
        }
      },
    );

    final kh = context.kh;
    final state = ref.watch(announcementListControllerProvider);
    final controller = ref.read(announcementListControllerProvider.notifier);

    if (_searchController.text != state.filters.query &&
        !_searchController.selection.isValid) {
      _searchController.text = state.filters.query;
    }

    final totalCount = state.items.length;
    final scheduledCount =
        state.items.where((i) => i.status == AnnouncementStatus.scheduled).length;
    final dispatchedCount =
        state.items.where((i) => i.status == AnnouncementStatus.dispatched).length;
    final cancelledCount =
        state.items.where((i) => i.status == AnnouncementStatus.cancelled).length;

    return Material(
      color: kh.colors.backgroundSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KhScreenHeader(
              eyebrow: 'Broadcast Communications',
              heading: 'Announcement Composer',
              supportingText:
                  'Broadcast system alerts or marketing notifications to Customers or Vendors.',
              trailing: FilledButton.icon(
                key: const Key('compose-announcement-button'),
                icon: const Icon(Icons.campaign),
                label: const Text('Compose Announcement'),
                onPressed: () => _showComposeDialog(context),
              ),
            ),
            SizedBox(height: kh.spacing.lg),
            // Metric cards
            Row(
              children: [
                Expanded(
                  child: KhMetricCard(
                    label: 'Total Announcements',
                    value: state.isLoading ? '-' : '$totalCount',
                    linkText: 'View All',
                    onTap: () => controller.setStatusFilter(null),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Scheduled',
                    value: state.isLoading ? '-' : '$scheduledCount',
                    linkText: 'Filter',
                    onTap: () => controller.setStatusFilter(AnnouncementStatus.scheduled),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Dispatched',
                    value: state.isLoading ? '-' : '$dispatchedCount',
                    linkText: 'Filter',
                    onTap: () => controller.setStatusFilter(AnnouncementStatus.dispatched),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Cancelled',
                    value: state.isLoading ? '-' : '$cancelledCount',
                    linkText: 'Filter',
                    onTap: () => controller.setStatusFilter(AnnouncementStatus.cancelled),
                  ),
                ),
              ],
            ),
            SizedBox(height: kh.spacing.lg),
            // Filter Bar
            _AnnouncementFilterBar(
              filters: state.filters,
              searchController: _searchController,
              onStatusChanged: controller.setStatusFilter,
              onAudienceChanged: controller.setAudienceFilter,
              onSearchChanged: _onSearchChanged,
              onSearchSubmitted: _onSearchSubmitted,
            ),
            SizedBox(height: kh.spacing.lg),
            if (state.isLoading)
              const Center(
                key: Key('announcement-list-loading'),
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.errorMessage != null)
              Container(
                key: const Key('announcement-list-error'),
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
              )
            else if (state.items.isEmpty)
              Container(
                key: const Key('announcement-list-empty'),
                padding: EdgeInsets.all(kh.spacing.xxl),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kh.colors.backgroundElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kh.colors.borderStandard),
                ),
                child: Column(
                  children: [
                    Icon(Icons.campaign_outlined, size: 48, color: kh.colors.textMuted),
                    SizedBox(height: kh.spacing.md),
                    Text('No announcements found', style: kh.typography.title),
                    SizedBox(height: kh.spacing.xs),
                    Text(
                      'No announcements match the current filters.',
                      style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
                    ),
                  ],
                ),
              )
            else
              KhDataTable(
                rowHeight: 64,
                columns: const [
                  KhTableColumn('Title', flex: 3),
                  KhTableColumn('Audience', flex: 2),
                  KhTableColumn('Channels', flex: 2),
                  KhTableColumn('Status', flex: 2),
                  KhTableColumn('Dispatch Progress', flex: 2),
                  KhTableColumn('Created By', flex: 2),
                  KhTableColumn('Date', flex: 2),
                  KhTableColumn('Actions', flex: 2),
                ],
                rows: state.items.map((item) {
                  KhStatusTone tone = KhStatusTone.neutral;
                  switch (item.status) {
                    case AnnouncementStatus.scheduled:
                      tone = KhStatusTone.pending;
                      break;
                    case AnnouncementStatus.dispatched:
                      tone = KhStatusTone.success;
                      break;
                    case AnnouncementStatus.cancelled:
                      tone = KhStatusTone.error;
                      break;
                    case AnnouncementStatus.draft:
                      tone = KhStatusTone.neutral;
                      break;
                  }

                  final dateStr = _formatDateTime(item.scheduledFor ?? item.createdAt, 10);
                  String progressStr = '-';
                  if (item.dispatchStats != null) {
                    progressStr =
                        '${item.dispatchStats!.sent} sent (${item.dispatchStats!.delivered} deliv.)';
                  } else if (item.status == AnnouncementStatus.scheduled) {
                    progressStr = 'Pending dispatch';
                  }

                  return KhTableRow(
                    key: ValueKey(item.id),
                    onTap: () => _showDetailDialog(context, item),
                    cells: [
                      // Title Cell
                      Row(
                        children: [
                          if (item.critical) ...[
                            Icon(Icons.warning_amber_rounded, size: 16, color: kh.colors.error),
                            SizedBox(width: kh.spacing.xxs),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.titleEn,
                                  style: kh.typography.bodySmall
                                      .copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.titleAr.isNotEmpty)
                                  Text(
                                    item.titleAr,
                                    style: kh.typography.caption
                                        .copyWith(color: kh.colors.textMuted),
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.rtl,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Audience Cell
                      Text(item.audienceType.label, style: kh.typography.bodySmall),
                      // Channels Cell
                      Text(item.channels.displayString, style: kh.typography.bodySmall),
                      // Status Cell
                      KhStatusChip(
                        label: item.status.label,
                        tone: tone,
                        dense: true,
                      ),
                      // Dispatch Progress Cell
                      Text(
                        progressStr,
                        style: kh.typography.bodySmall.copyWith(
                          color: item.dispatchStats != null
                              ? kh.colors.success
                              : kh.colors.textMuted,
                        ),
                      ),
                      // Created By Cell
                      Text(
                        item.createdByDisplayName ?? 'Admin',
                        style: kh.typography.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Date Cell
                      Text(dateStr, style: kh.typography.bodySmall),
                      // Actions Cell
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline, size: 18),
                            tooltip: 'View details',
                            onPressed: () => _showDetailDialog(context, item),
                          ),
                          if (item.canCancel)
                            IconButton(
                              icon: Icon(Icons.cancel_outlined,
                                  size: 18, color: kh.colors.error),
                              tooltip: 'Cancel',
                              onPressed: () => _showCancelDialog(context, item),
                            ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            if (state.hasMore) ...[
              SizedBox(height: kh.spacing.lg),
              Center(
                child: OutlinedButton(
                  onPressed: controller.loadMore,
                  child: const Text('Load More'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnnouncementFilterBar extends StatelessWidget {
  const _AnnouncementFilterBar({
    required this.filters,
    required this.searchController,
    required this.onStatusChanged,
    required this.onAudienceChanged,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
  });

  final AnnouncementFilters filters;
  final TextEditingController searchController;
  final ValueChanged<AnnouncementStatus?> onStatusChanged;
  final ValueChanged<AudienceType?> onAudienceChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Container(
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Wrap(
        spacing: kh.spacing.md,
        runSpacing: kh.spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Field
          SizedBox(
            width: 280,
            child: TextField(
              key: const Key('announcement-search-field'),
              controller: searchController,
              onChanged: onSearchChanged,
              onSubmitted: (_) => onSearchSubmitted(),
              decoration: InputDecoration(
                hintText: 'Search announcements...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          // Status Dropdown
          DropdownButton<AnnouncementStatus?>(
            key: const Key('announcement-status-filter'),
            value: filters.status,
            hint: const Text('All Statuses'),
            items: [
              const DropdownMenuItem<AnnouncementStatus?>(
                value: null,
                child: Text('All Statuses'),
              ),
              ...AnnouncementStatus.values.map(
                (s) => DropdownMenuItem<AnnouncementStatus?>(
                  value: s,
                  child: Text(s.label),
                ),
              ),
            ],
            onChanged: onStatusChanged,
          ),
          // Audience Dropdown
          DropdownButton<AudienceType?>(
            key: const Key('announcement-audience-filter'),
            value: filters.audienceType,
            hint: const Text('All Audiences'),
            items: [
              const DropdownMenuItem<AudienceType?>(
                value: null,
                child: Text('All Audiences'),
              ),
              ...AudienceType.values.map(
                (a) => DropdownMenuItem<AudienceType?>(
                  value: a,
                  child: Text(a.label),
                ),
              ),
            ],
            onChanged: onAudienceChanged,
          ),
        ],
      ),
    );
  }
}

/// Comprehensive Compose Announcement Modal with bilingual fields,
/// audience & channel selection, scheduling, and SAM-GAP-10 notice.
class _ComposeAnnouncementDialog extends StatefulWidget {
  const _ComposeAnnouncementDialog({required this.onSubmit});

  final Future<void> Function(CreateAnnouncementDto dto) onSubmit;

  @override
  State<_ComposeAnnouncementDialog> createState() => _ComposeAnnouncementDialogState();
}

class _ComposeAnnouncementDialogState extends State<_ComposeAnnouncementDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _bodyEnController = TextEditingController();
  final _bodyArController = TextEditingController();

  AudienceType _selectedAudience = AudienceType.all;
  bool _channelInApp = true;
  bool _channelPush = false;
  bool _channelEmail = false;
  bool _isCritical = false;

  bool _scheduleForLater = false;
  DateTime? _scheduledDateTime;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleEnController.dispose();
    _titleArController.dispose();
    _bodyEnController.dispose();
    _bodyArController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduleDateTime() async {
    final now = DateTime.now();
    final initialDate = _scheduledDateTime ?? now.add(const Duration(hours: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _scheduledDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);

    final titleEn = _titleEnController.text.trim();
    final titleAr = _titleArController.text.trim();
    final bodyEn = _bodyEnController.text.trim();
    final bodyAr = _bodyArController.text.trim();

    if (titleEn.isEmpty || bodyEn.isEmpty) {
      setState(() => _errorMessage = 'Please complete the English title and body.');
      _tabController.animateTo(0);
      return;
    }

    if (titleAr.isEmpty || bodyAr.isEmpty) {
      setState(() => _errorMessage = 'Please complete the Arabic title and body.');
      _tabController.animateTo(1);
      return;
    }

    if (!_channelInApp && !_channelPush && !_channelEmail) {
      setState(() => _errorMessage = 'Select at least one delivery channel.');
      return;
    }

    if (_scheduleForLater) {
      if (_scheduledDateTime == null) {
        setState(() => _errorMessage = 'Please select a scheduled date and time.');
        return;
      }
      if (_scheduledDateTime!.isBefore(DateTime.now())) {
        setState(() => _errorMessage = 'Scheduled time must be in the future.');
        return;
      }
    }

    final dto = CreateAnnouncementDto(
      titleEn: titleEn,
      titleAr: titleAr,
      bodyEn: bodyEn,
      bodyAr: bodyAr,
      audience: {'userType': _selectedAudience.wireValue},
      channels: {
        'inApp': _channelInApp,
        'push': _channelPush,
        'email': _channelEmail,
      },
      critical: _isCritical,
      scheduledFor: _scheduleForLater ? _scheduledDateTime : null,
    );

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(dto);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.campaign, color: kh.colors.goldPrimary),
          SizedBox(width: kh.spacing.sm),
          Text('Compose Announcement', style: kh.typography.title),
        ],
      ),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    key: const Key('announcement-form-error'),
                    padding: EdgeInsets.all(kh.spacing.sm),
                    margin: EdgeInsets.only(bottom: kh.spacing.md),
                    decoration: BoxDecoration(
                      color: kh.colors.error.withValues(alpha: 0.1),
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 18, color: kh.colors.error),
                        SizedBox(width: kh.spacing.xs),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: kh.typography.bodySmall.copyWith(color: kh.colors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Bilingual Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: kh.colors.goldPrimary,
                  unselectedLabelColor: kh.colors.textMuted,
                  indicatorColor: kh.colors.goldPrimary,
                  tabs: const [
                    Tab(text: 'English'),
                    Tab(text: 'العربية (Arabic)'),
                  ],
                ),
                SizedBox(height: kh.spacing.md),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // English Fields
                      Column(
                        children: [
                          TextField(
                            key: const Key('announcement-title-en-field'),
                            controller: _titleEnController,
                            decoration: const InputDecoration(
                              labelText: 'Announcement Title (English) *',
                              hintText: 'e.g. Gold Souk Holiday Trading Hours',
                              isDense: true,
                            ),
                          ),
                          SizedBox(height: kh.spacing.sm),
                          Expanded(
                            child: TextField(
                              key: const Key('announcement-body-en-field'),
                              controller: _bodyEnController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Message Body (English) *',
                                hintText:
                                    'Enter full announcement broadcast text in English...',
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Arabic Fields
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          children: [
                            TextField(
                              key: const Key('announcement-title-ar-field'),
                              controller: _titleArController,
                              textDirection: TextDirection.rtl,
                              decoration: const InputDecoration(
                                labelText: 'عنوان الإعلان (بالعربية) *',
                                hintText: 'مثال: مواعيد عمل سوق الذهب خلال العيد',
                                isDense: true,
                              ),
                            ),
                            SizedBox(height: kh.spacing.sm),
                            Expanded(
                              child: TextField(
                                key: const Key('announcement-body-ar-field'),
                                controller: _bodyArController,
                                maxLines: 4,
                                textDirection: TextDirection.rtl,
                                decoration: const InputDecoration(
                                  labelText: 'نص الرسالة (بالعربية) *',
                                  hintText: 'أدخل نص الإعلان كاملاً باللغة العربية...',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                const Divider(),
                SizedBox(height: kh.spacing.sm),
                // Target Audience
                Text('TARGET AUDIENCE',
                    style: kh.typography.caption.copyWith(
                      color: kh.colors.goldPrimary,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(height: kh.spacing.xs),
                DropdownButtonFormField<AudienceType>(
                  key: const Key('announcement-audience-select'),
                  initialValue: _selectedAudience,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: AudienceType.values
                      .map((a) => DropdownMenuItem(value: a, child: Text(a.label)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAudience = val);
                  },
                ),
                SizedBox(height: kh.spacing.md),
                // Delivery Channels
                Text('DELIVERY CHANNELS',
                    style: kh.typography.caption.copyWith(
                      color: kh.colors.goldPrimary,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(height: kh.spacing.xs),
                Wrap(
                  spacing: kh.spacing.lg,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          key: const Key('announcement-channel-inapp'),
                          value: _channelInApp,
                          onChanged: (val) => setState(() => _channelInApp = val ?? false),
                        ),
                        const Text('In-App Notification'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          key: const Key('announcement-channel-push'),
                          value: _channelPush,
                          onChanged: (val) => setState(() => _channelPush = val ?? false),
                        ),
                        const Text('Mobile Push'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          key: const Key('announcement-channel-email'),
                          value: _channelEmail,
                          onChanged: (val) => setState(() => _channelEmail = val ?? false),
                        ),
                        const Text('Email'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: kh.spacing.sm),
                // Critical Notice Switch
                SwitchListTile(
                  key: const Key('announcement-critical-switch'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Critical Announcement'),
                  subtitle: Text(
                    'Flags priority alert and overrides user notification preferences for outages or policy changes.',
                    style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
                  ),
                  value: _isCritical,
                  onChanged: (val) => setState(() => _isCritical = val),
                ),
                SizedBox(height: kh.spacing.sm),
                SwitchListTile(
                  key: const Key('announcement-schedule-radio'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Schedule for later'),
                  subtitle: Text(
                    _scheduleForLater
                        ? 'Dispatch at the selected date and time (GST).'
                        : 'Dispatch immediately after compose.',
                    style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
                  ),
                  value: _scheduleForLater,
                  onChanged: (val) => setState(() => _scheduleForLater = val),
                ),
                if (_scheduleForLater) ...[
                  SizedBox(height: kh.spacing.xs),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        key: const Key('announcement-pick-datetime-button'),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _scheduledDateTime != null
                              ? 'Scheduled: ${_scheduledDateTime!.toLocal().toString().substring(0, 16)}'
                              : 'Select Date & Time',
                        ),
                        onPressed: _pickScheduleDateTime,
                      ),
                      if (_scheduledDateTime != null) ...[
                        SizedBox(width: kh.spacing.sm),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          tooltip: 'Clear schedule',
                          onPressed: () => setState(() => _scheduledDateTime = null),
                        ),
                      ],
                    ],
                  ),
                ],
                SizedBox(height: kh.spacing.md),
                // SAM-GAP-10 Notice
                Container(
                  padding: EdgeInsets.all(kh.spacing.sm),
                  decoration: BoxDecoration(
                    color: kh.colors.gold400.withValues(alpha: 0.08),
                    borderRadius: kh.shapes.roundedSm,
                    border: Border.all(color: kh.colors.borderSubtle),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: kh.colors.goldPrimary),
                      SizedBox(width: kh.spacing.xs),
                      Expanded(
                        child: Text(
                          'Dynamic Recipient Evaluation (SAM-GAP-10): Pre-send recipient counts are not previewed. The target audience is evaluated dynamically at the scheduled dispatch moment.',
                          style: kh.typography.caption.copyWith(color: kh.colors.goldPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('announcement-submit-button'),
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_scheduleForLater ? 'Schedule Announcement' : 'Broadcast Now'),
        ),
      ],
    );
  }
}
