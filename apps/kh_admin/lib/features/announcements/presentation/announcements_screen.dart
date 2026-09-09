import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/announcement_query_params.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/features/announcements/controller/announcement_controller.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/announcement_detail_dialog.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/announcement_filter_bar.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/announcement_formatters.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/announcement_metrics_row.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/announcement_table.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/cancel_announcement_dialog.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/compose_announcement_dialog.dart';
import 'package:kh_admin/core/widgets/debounced_search_mixin.dart';

/// ADM-S18 · Announcement Composer — Broadcast system alerts and marketing notifications.
///
/// Composition root only: metric cards, filter bar, table and the compose /
/// detail / cancel dialogs each live in `presentation/widgets/` (TR-S2-08,
/// TR-S2-09).
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

  void _showComposeDialog(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => ComposeAnnouncementDialog(
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

  void _openDetail(AnnouncementItem item) {
    showAnnouncementDetailDialog(
      context,
      item,
      onCancel: () => _handleCancel(item),
    );
  }

  Future<void> _handleCancel(AnnouncementItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showCancelAnnouncementDialog(context, item);
    if (!confirmed) return;
    final success = await ref
        .read(announcementListControllerProvider.notifier)
        .cancelAnnouncement(item.id);
    if (!mounted || !success) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text('Announcement #${announcementShortId(item.id)} cancelled'),
      ),
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
            AnnouncementMetricsRow(
              isLoading: state.isLoading,
              totalCount: totalCount,
              scheduledCount: scheduledCount,
              dispatchedCount: dispatchedCount,
              cancelledCount: cancelledCount,
              onFilter: controller.setStatusFilter,
            ),
            SizedBox(height: kh.spacing.lg),
            AnnouncementFilterBar(
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
              AnnouncementTable(
                items: state.items,
                onRowTap: _openDetail,
                onCancel: _handleCancel,
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
