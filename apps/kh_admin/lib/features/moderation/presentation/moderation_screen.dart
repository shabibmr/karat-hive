
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/moderation_query_params.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/moderation/controller/moderation_controller.dart';
import 'package:kh_admin/features/moderation/model/moderation_enums.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';
import 'package:kh_admin/features/moderation/model/moderation_review_item.dart';
import 'package:kh_admin/core/widgets/debounced_search_mixin.dart';

/// ADM-S16 · Review moderation queue — Hold-for-approval queue for reviews and vendor responses.
class ModerationScreen extends ConsumerStatefulWidget {
  const ModerationScreen({super.key});

  @override
  ConsumerState<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends ConsumerState<ModerationScreen> with DebouncedSearchMixin {
  late final TextEditingController _searchController;
  Uri? _lastSyncedUri;

  @override
  void initState() {
    super.initState();
    final query = ref.read(moderationListControllerProvider).filters.query;
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

    final parsed = ModerationQueryParams.fromUri(uri).toFilters();
    final current = ref.read(moderationListControllerProvider).filters;
    if (parsed == current) return;
    ref.read(moderationListControllerProvider.notifier).applyFilters(parsed);
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
      ref.read(moderationListControllerProvider.notifier).setSearchQuery(query);
      ref.read(moderationListControllerProvider.notifier).submitSearch();
    });
  }

  void _onSearchSubmitted() {
    ref.read(moderationListControllerProvider.notifier).setSearchQuery(_searchController.text.trim());
    ref.read(moderationListControllerProvider.notifier).submitSearch();
  }

  String _shortId(String id, [int maxLen = 8]) =>
      id.length > maxLen ? id.substring(0, maxLen) : id;

  String _formatDateTime(DateTime dt, [int maxLen = 16]) {
    final str = dt.toLocal().toString();
    return str.length >= maxLen ? str.substring(0, maxLen) : str;
  }

  void _showApproveDialog(ModerationReviewItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Approve Review #${_shortId(item.id)}'),
          content: const Text(
            'Are you sure you want to approve and publish this review? It will become publicly visible and contribute to vendor ratings and aggregates.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('moderation-confirm-approve-button'),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final success = await ref
                    .read(moderationListControllerProvider.notifier)
                    .approveReview(item.id);
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Review #${_shortId(item.id)} approved & published')),
                  );
                }
              },
              child: const Text('Approve & Publish'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(ModerationReviewItem item) {
    final rationaleController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        return AlertDialog(
          title: Text('Reject Review #${_shortId(item.id)}'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provide a rejection rationale to be communicated to the author. The review will be withheld from publication.',
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
                ),
                SizedBox(height: kh.spacing.md),
                TextField(
                  key: const Key('moderation-reject-rationale-field'),
                  controller: rationaleController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Rejection Rationale *',
                    hintText: 'e.g. Contains profanity, personally identifiable info, or unsupported claims.',
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
              key: const Key('moderation-confirm-reject-button'),
              style: FilledButton.styleFrom(backgroundColor: kh.colors.error),
              onPressed: () async {
                final rationale = rationaleController.text.trim();
                if (rationale.isEmpty) return;
                Navigator.of(dialogCtx).pop();
                final success = await ref
                    .read(moderationListControllerProvider.notifier)
                    .rejectReview(item.id, rationale);
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Review #${_shortId(item.id)} rejected')),
                  );
                }
              },
              child: const Text('Reject Review'),
            ),
          ],
        );
      },
    );
  }

  void _showRedactDialog(ModerationReviewItem item) {
    final rationaleController = TextEditingController();
    final commentController = TextEditingController(text: item.comment ?? '');
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        return AlertDialog(
          title: Text('Redact Review #${_shortId(item.id)}'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit the comment to redact offending passages. The original comment is retained internally in audit logs.',
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
                ),
                SizedBox(height: kh.spacing.md),
                TextField(
                  key: const Key('moderation-redacted-comment-field'),
                  controller: commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Redacted Comment Text *',
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                TextField(
                  key: const Key('moderation-redact-rationale-field'),
                  controller: rationaleController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Redaction Rationale *',
                    hintText: 'e.g. Removed phone number per privacy guidelines.',
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
              key: const Key('moderation-confirm-redact-button'),
              onPressed: () async {
                final rationale = rationaleController.text.trim();
                final redactedComment = commentController.text.trim();
                if (rationale.isEmpty || redactedComment.isEmpty) return;
                Navigator.of(dialogCtx).pop();
                final success = await ref
                    .read(moderationListControllerProvider.notifier)
                    .redactReview(item.id, rationale, redactedComment);
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Review #${_shortId(item.id)} redacted & updated')),
                  );
                }
              },
              child: const Text('Save & Redact'),
            ),
          ],
        );
      },
    );
  }

  void _showDetailDialog(BuildContext context, ModerationReviewItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        return AlertDialog(
          title: Text('Review Details #${item.id}'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow('Status', item.state.label),
                  _detailRow('Rating', '${'★' * item.rating}${'☆' * (5 - item.rating)} (${item.rating}/5)'),
                  _detailRow('Author', '${item.authorName ?? item.authorUserId} (${item.authorType.label})'),
                  if (item.authorEmail != null) _detailRow('Author Email', item.authorEmail!),
                  _detailRow('Subject', item.subjectName ?? item.subjectUserId),
                  if (item.subjectEmail != null) _detailRow('Subject Email', item.subjectEmail!),
                  _detailRow('Connection', item.connectionId),
                  _detailRow('Created At', _formatDateTime(item.createdAt)),
                  if (item.publishedAt != null)
                    _detailRow('Published At', _formatDateTime(item.publishedAt!)),
                  const Divider(height: 24),
                  Text('Review Comment', style: kh.typography.subtitle),
                  SizedBox(height: kh.spacing.xs),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(kh.spacing.sm),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.comment ?? '(No text comment)',
                      style: kh.typography.body.copyWith(
                        fontStyle: item.comment == null ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                  if (item.vendorResponse != null && item.vendorResponse!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text('Vendor Response', style: kh.typography.subtitle),
                    SizedBox(height: kh.spacing.xs),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(kh.spacing.sm),
                      decoration: BoxDecoration(
                        color: kh.colors.backgroundPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.vendorResponse!, style: kh.typography.body),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            if (item.state == ReviewState.pendingModeration) ...[
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  _showApproveDialog(item);
                },
                child: const Text('Approve'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  _showRedactDialog(item);
                },
                child: const Text('Redact'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  _showRejectDialog(item);
                },
                child: Text('Reject', style: TextStyle(color: kh.colors.error)),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    ref.listen<ModerationFilters>(
      moderationListControllerProvider.select((s) => s.filters),
      (prev, next) {
        if (prev != next) {
          context.updateModerationQuery(next);
        }
      },
    );

    final kh = context.kh;
    final state = ref.watch(moderationListControllerProvider);
    final controller = ref.read(moderationListControllerProvider.notifier);

    if (_searchController.text != state.filters.query &&
        !_searchController.selection.isValid) {
      _searchController.text = state.filters.query;
    }

    final pendingCount = state.items.where((i) => i.state == ReviewState.pendingModeration).length;
    final publishedCount = state.items.where((i) => i.state == ReviewState.published).length;
    final rejectedCount = state.items.where((i) => i.state == ReviewState.rejected).length;
    final redactedCount = state.items.where((i) => i.state == ReviewState.redacted).length;

    return Material(
      color: kh.colors.backgroundSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KhScreenHeader(
              eyebrow: 'Trust & Safety',
              heading: 'Review Moderation Queue',
              supportingText:
                  'Hold-for-approval queue for customer and vendor reviews and vendor responses. Approve, reject, or redact prior to public publishing.',
            ),
            SizedBox(height: kh.spacing.lg),
            // Metric cards
            Row(
              children: [
                Expanded(
                  child: KhMetricCard(
                    label: 'Pending Moderation',
                    value: state.isLoading ? '-' : '$pendingCount',
                    linkText: 'View',
                    onTap: () => controller.setStateFilter(ReviewState.pendingModeration),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Published',
                    value: state.isLoading ? '-' : '$publishedCount',
                    linkText: 'View',
                    onTap: () => controller.setStateFilter(ReviewState.published),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Rejected',
                    value: state.isLoading ? '-' : '$rejectedCount',
                    linkText: 'View',
                    onTap: () => controller.setStateFilter(ReviewState.rejected),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Redacted',
                    value: state.isLoading ? '-' : '$redactedCount',
                    linkText: 'View',
                    onTap: () => controller.setStateFilter(ReviewState.redacted),
                  ),
                ),
              ],
            ),
            SizedBox(height: kh.spacing.lg),
            // Filter bar
            _ModerationFilterBar(
              filters: state.filters,
              searchController: _searchController,
              onStateChanged: controller.setStateFilter,
              onAuthorTypeChanged: controller.setAuthorTypeFilter,
              onSearchChanged: _onSearchChanged,
              onSearchSubmitted: _onSearchSubmitted,
            ),
            SizedBox(height: kh.spacing.lg),
            if (state.isLoading)
              const Center(
                key: Key('moderation-list-loading'),
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.errorMessage != null)
              Container(
                key: const Key('moderation-list-error'),
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
                key: const Key('moderation-list-empty'),
                padding: EdgeInsets.all(kh.spacing.xxl),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kh.colors.backgroundElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kh.colors.borderStandard),
                ),
                child: Column(
                  children: [
                    Icon(Icons.rate_review_outlined, size: 48, color: kh.colors.textMuted),
                    SizedBox(height: kh.spacing.md),
                    Text('No reviews found', style: kh.typography.title),
                    SizedBox(height: kh.spacing.xs),
                    Text(
                      'No reviews match the current filters.',
                      style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
                    ),
                  ],
                ),
              )
            else
              KhDataTable(
                columns: const [
                  KhTableColumn('Date', flex: 2),
                  KhTableColumn('Rating', flex: 1),
                  KhTableColumn('Author', flex: 2),
                  KhTableColumn('Subject', flex: 2),
                  KhTableColumn('Comment', flex: 3),
                  KhTableColumn('Status', flex: 2),
                  KhTableColumn('Actions', flex: 3),
                ],
                rows: state.items.map((item) {
                  final dateStr = _formatDateTime(item.createdAt, 10);
                  KhStatusTone tone = KhStatusTone.neutral;
                  if (item.state == ReviewState.pendingModeration) {
                    tone = KhStatusTone.pending;
                  } else if (item.state == ReviewState.published) {
                    tone = KhStatusTone.success;
                  } else if (item.state == ReviewState.rejected) {
                    tone = KhStatusTone.error;
                  } else if (item.state == ReviewState.redacted) {
                    tone = KhStatusTone.moderation;
                  }

                  return KhTableRow(
                    key: ValueKey(item.id),
                    onTap: () => _showDetailDialog(context, item),
                    cells: [
                      Text(dateStr, style: kh.typography.bodySmall),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: kh.colors.warning),
                          SizedBox(width: kh.spacing.xxs),
                          Text('${item.rating}', style: kh.typography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        item.authorName ?? _shortId(item.authorUserId),
                        style: kh.typography.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.subjectName ?? _shortId(item.subjectUserId),
                        style: kh.typography.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.comment ?? '(No comment)',
                        style: kh.typography.bodySmall.copyWith(
                          fontStyle: item.comment == null ? FontStyle.italic : FontStyle.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                          if (item.state == ReviewState.pendingModeration) ...[
                            IconButton(
                              icon: Icon(Icons.check_circle_outline, size: 18, color: kh.colors.success),
                              tooltip: 'Approve & Publish',
                              onPressed: () => _showApproveDialog(item),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_note, size: 18, color: kh.colors.info),
                              tooltip: 'Redact text',
                              onPressed: () => _showRedactDialog(item),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel_outlined, size: 18, color: kh.colors.error),
                              tooltip: 'Reject review',
                              onPressed: () => _showRejectDialog(item),
                            ),
                          ],
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
                  child: const Text('Load More Reviews'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModerationFilterBar extends StatelessWidget {
  const _ModerationFilterBar({
    required this.filters,
    required this.searchController,
    required this.onStateChanged,
    required this.onAuthorTypeChanged,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
  });

  final ModerationFilters filters;
  final TextEditingController searchController;
  final ValueChanged<ReviewState?> onStateChanged;
  final ValueChanged<AuthorType?> onAuthorTypeChanged;
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
              key: const Key('moderation-search-input'),
              controller: searchController,
              onChanged: onSearchChanged,
              onSubmitted: (_) => onSearchSubmitted(),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search author, subject, comment...',
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
          DropdownButton<ReviewState?>(
            key: const Key('moderation-state-filter'),
            value: filters.state,
            hint: const Text('All States'),
            items: [
              const DropdownMenuItem<ReviewState?>(
                value: null,
                child: Text('All States'),
              ),
              ...ReviewState.values.map(
                (s) => DropdownMenuItem<ReviewState?>(
                  value: s,
                  child: Text(s.label),
                ),
              ),
            ],
            onChanged: onStateChanged,
          ),
          DropdownButton<AuthorType?>(
            key: const Key('moderation-author-type-filter'),
            value: filters.authorType,
            hint: const Text('All Authors'),
            items: [
              const DropdownMenuItem<AuthorType?>(
                value: null,
                child: Text('All Authors'),
              ),
              ...AuthorType.values.map(
                (a) => DropdownMenuItem<AuthorType?>(
                  value: a,
                  child: Text(a.label),
                ),
              ),
            ],
            onChanged: onAuthorTypeChanged,
          ),
        ],
      ),
    );
  }
}
