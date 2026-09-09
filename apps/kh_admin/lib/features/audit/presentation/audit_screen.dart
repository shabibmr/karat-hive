import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/audit_query_params.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/audit/controller/audit_controller.dart';
import 'package:kh_admin/features/audit/model/audit_log_filters.dart';
import 'package:kh_admin/features/audit/model/audit_log_item.dart';

/// Common administrative action types recorded in audit logs.
const List<String> kCommonAuditActions = [
  'ALL',
  'CUSTOMER_SUSPENDED',
  'CUSTOMER_REACTIVATED',
  'CUSTOMER_ERASURE_COMPLETED',
  'VENDOR_VERIFIED',
  'VENDOR_REJECTED',
  'VENDOR_INFO_REQUESTED',
  'VENDOR_STATE_CHANGED',
  'REQUEST_REMOVED',
  'OFFER_ACCEPTED',
  'CONNECTION_CLOSED',
  'REVIEW_APPROVED',
  'REVIEW_REJECTED',
  'REVIEW_REDACTED',
  'ABUSE_REPORT_RESOLVED',
  'ABUSE_REPORT_DISMISSED',
  'SETTINGS_UPDATED',
  'ADMIN_CREATED',
  'ADMIN_SUSPENDED',
  'ADMIN_REVOKED',
  'ANNOUNCEMENT_CREATED',
  'ANNOUNCEMENT_CANCELLED',
  'EXPORT_JOB_CREATED',
  'AUDIT_VIEWED',
];

/// Common target entity types.
const List<String> kCommonEntityTypes = [
  'ALL',
  'customer_profile',
  'vendor_profile',
  'request',
  'offer',
  'connection',
  'review',
  'abuse_report',
  'platform_settings',
  'announcement',
  'export_job',
  'admin_user',
];

/// ADM-S22 · Audit Log viewer screen.
///
/// Search immutable audit trail of security and administrative operations
/// (`FR-ADM-033`, `FR-SYS-011`). Viewing this log is itself audited per §39.
class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  late final TextEditingController _actionSearchController;
  late final TextEditingController _actorSearchController;
  late final TextEditingController _ipSearchController;

  Uri? _lastSyncedUri;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(auditControllerProvider).filters;
    _actionSearchController = TextEditingController(text: filters.action ?? '');
    _actorSearchController =
        TextEditingController(text: filters.actorUserId ?? '');
    _ipSearchController = TextEditingController(text: filters.ip ?? '');
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

    final parsed = AuditQueryParams.fromUri(uri).filters;
    final current = ref.read(auditControllerProvider).filters;
    if (parsed == current) return;
    ref.read(auditControllerProvider.notifier).applyFilters(parsed);
    if (_actionSearchController.text != (parsed.action ?? '')) {
      _actionSearchController.text = parsed.action ?? '';
    }
    if (_actorSearchController.text != (parsed.actorUserId ?? '')) {
      _actorSearchController.text = parsed.actorUserId ?? '';
    }
    if (_ipSearchController.text != (parsed.ip ?? '')) {
      _ipSearchController.text = parsed.ip ?? '';
    }
  }

  @override
  void dispose() {
    _actionSearchController.dispose();
    _actorSearchController.dispose();
    _ipSearchController.dispose();
    super.dispose();
  }

  KhStatusTone _toneForAction(String action) {
    final act = action.toUpperCase();
    if (act.contains('SUSPEND') ||
        act.contains('REJECT') ||
        act.contains('CLOSE') ||
        act.contains('REVOKE') ||
        act.contains('CANCEL') ||
        act.contains('ERASURE')) {
      return KhStatusTone.error;
    }
    if (act.contains('VERIF') ||
        act.contains('REACTIVATE') ||
        act.contains('APPROVE') ||
        act.contains('RESOLVE') ||
        act.contains('CREATED')) {
      return KhStatusTone.success;
    }
    if (act.contains('INFO') || act.contains('REDACT')) {
      return KhStatusTone.moderation;
    }
    return KhStatusTone.neutral;
  }

  Future<void> _pickDateRange(
    BuildContext context,
    AuditLogFilters filters,
  ) async {
    final now = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: filters.from ?? now.subtract(const Duration(days: 30)),
      end: filters.to ?? now,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: initialDateRange,
      helpText: 'Select GST Audit Date Range',
    );

    if (picked != null) {
      ref.read(auditControllerProvider.notifier).setDateRange(
            picked.start,
            DateTime(
              picked.end.year,
              picked.end.month,
              picked.end.day,
              23,
              59,
              59,
            ),
          );
    }
  }

  void _showDetailModal(BuildContext context, AuditLogItem item) {
    final kh = context.kh;
    final colors = kh.colors;
    final spacing = kh.spacing;

    String prettyJson(dynamic val) {
      if (val == null) return 'null';
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(val);
      } on Object catch (_) {
        return val.toString();
      }
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: colors.backgroundElevated,
          shape: RoundedRectangleBorder(borderRadius: kh.shapes.roundedLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 720),
            child: Padding(
              padding: EdgeInsets.all(spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AUDIT ENTRY DETAIL',
                              style: kh.typography.caption.copyWith(
                                color: colors.goldPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: spacing.xxs),
                            Text(
                              item.action,
                              style: kh.typography.headline,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  Divider(color: colors.borderSubtle),
                  SizedBox(height: spacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetadataGrid(context, item),
                          SizedBox(height: spacing.lg),
                          Text(
                            'State Change Diff (SAM-GAP-12)',
                            style: kh.typography.title,
                          ),
                          SizedBox(height: spacing.xs),
                          Text(
                            'Before and after state values captured at execution.',
                            style: kh.typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: spacing.sm),
                          _buildDiffSection(
                            context,
                            item.beforeValue,
                            item.afterValue,
                            prettyJson,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataGrid(BuildContext context, AuditLogItem item) {
    final kh = context.kh;
    final colors = kh.colors;

    Widget metadataTile(String label, String value, {bool copyable = false}) {
      return Container(
        padding: EdgeInsets.all(kh.spacing.sm),
        decoration: BoxDecoration(
          color: colors.backgroundSurface,
          borderRadius: kh.shapes.roundedSm,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: kh.typography.caption.copyWith(
                color: colors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            SizedBox(height: kh.spacing.xxs),
            SelectableText(
              value,
              style: kh.typography.bodySmall.copyWith(
                color: colors.textPrimary,
                fontFamily: copyable ? 'monospace' : null,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final colCount = isWide ? 2 : 1;

        return GridView.count(
          crossAxisCount: colCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: kh.spacing.sm,
          crossAxisSpacing: kh.spacing.sm,
          childAspectRatio: isWide ? 3.8 : 4.5,
          children: [
            metadataTile('Record ID', item.id, copyable: true),
            metadataTile('Occurred At (GST UTC+4)', item.formattedGst),
            metadataTile('Occurred At (UTC)', item.occurredAt.toUtc().toIso8601String()),
            metadataTile(
              'Actor User ID',
              item.actorUserId ?? 'System / Anonymous',
              copyable: true,
            ),
            metadataTile('Target Entity Type', item.entityType),
            metadataTile('Target Entity ID', item.entityId ?? 'None', copyable: true),
            metadataTile('Client IP Address', item.ip ?? '—'),
            metadataTile('Client User Agent', item.userAgent ?? '—'),
          ],
        );
      },
    );
  }

  Widget _buildDiffSection(
    BuildContext context,
    dynamic before,
    dynamic after,
    String Function(dynamic) prettyJson,
  ) {
    final kh = context.kh;
    final colors = kh.colors;

    if (before == null && after == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(kh.spacing.md),
        decoration: BoxDecoration(
          color: colors.backgroundSurface,
          borderRadius: kh.shapes.roundedSm,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Text(
          'No state payload diff recorded for this entry.',
          style: kh.typography.bodySmall.copyWith(color: colors.textMuted),
        ),
      );
    }

    Widget payloadBox(String title, dynamic val, Color accentColor) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.all(kh.spacing.sm),
          decoration: BoxDecoration(
            color: colors.backgroundSurface,
            borderRadius: kh.shapes.roundedSm,
            border: Border.all(color: accentColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: kh.spacing.xs),
                  Text(
                    title,
                    style: kh.typography.caption.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: kh.spacing.xs),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(kh.spacing.xs),
                decoration: BoxDecoration(
                  color: colors.backgroundElevated,
                  borderRadius: kh.shapes.roundedSm,
                ),
                child: SelectableText(
                  val == null ? 'None' : prettyJson(val),
                  style: kh.typography.bodySmall.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        payloadBox('BEFORE VALUE', before, colors.error),
        SizedBox(width: kh.spacing.md),
        payloadBox('AFTER VALUE', after, colors.success),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuditLogFilters>(
      auditControllerProvider.select((s) => s.filters),
      (prev, next) {
        if (prev != next) {
          context.updateAuditQuery(next);
        }
      },
    );

    final kh = context.kh;
    final colors = kh.colors;
    final spacing = kh.spacing;
    final auditState = ref.watch(auditControllerProvider);
    final controller = ref.read(auditControllerProvider.notifier);

    return Material(
      color: colors.backgroundSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KhScreenHeader(
              eyebrow: 'COMPLIANCE & SECURITY',
              heading: 'Audit Log',
              supportingText:
                  'Immutable audit trail of security and administrative operations (FR-ADM-033, BR-021, NFR-021)',
            ),
            SizedBox(height: spacing.md),
            const _SelfViewAuditNotice(),
            SizedBox(height: spacing.lg),
            _buildFiltersToolbar(context, auditState, controller),
            SizedBox(height: spacing.lg),
            if (auditState.isLoading)
              const Center(
                key: Key('audit-loading-indicator'),
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (auditState.error != null && auditState.items.isEmpty)
              _buildErrorView(context, auditState.error!, controller.refresh)
            else if (auditState.items.isEmpty)
              _buildEmptyView(context)
            else ...[
              _buildDataTable(context, auditState.items),
              SizedBox(height: spacing.md),
              _buildPaginationControls(context, auditState, controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersToolbar(
    BuildContext context,
    AuditState state,
    AuditController controller,
  ) {
    final kh = context.kh;
    final colors = kh.colors;
    final filters = state.filters;

    String dateRangeLabel() {
      if (filters.from == null && filters.to == null) {
        return 'All Dates';
      }
      final fromStr = filters.from != null
          ? '${filters.from!.year}-${filters.from!.month.toString().padLeft(2, '0')}-${filters.from!.day.toString().padLeft(2, '0')}'
          : '—';
      final toStr = filters.to != null
          ? '${filters.to!.year}-${filters.to!.month.toString().padLeft(2, '0')}-${filters.to!.day.toString().padLeft(2, '0')}'
          : '—';
      return '$fromStr to $toStr';
    }

    return Container(
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Wrap(
        spacing: kh.spacing.md,
        runSpacing: kh.spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Action Filter Dropdown
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              key: const Key('audit-action-filter-dropdown'),
              initialValue: filters.action != null &&
                      kCommonAuditActions.contains(filters.action)
                  ? filters.action
                  : 'ALL',
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Action Type',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: kh.shapes.roundedSm),
              ),
              items: kCommonAuditActions.map((action) {
                return DropdownMenuItem<String>(
                  value: action,
                  child: Text(
                    action,
                    style: kh.typography.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                controller.setActionFilter(val == 'ALL' ? null : val);
              },
            ),
          ),
          // Entity Type Filter Dropdown
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              key: const Key('audit-entity-filter-dropdown'),
              initialValue: filters.entityType != null &&
                      kCommonEntityTypes.contains(filters.entityType)
                  ? filters.entityType
                  : 'ALL',
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Target Entity',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: kh.shapes.roundedSm),
              ),
              items: kCommonEntityTypes.map((entity) {
                return DropdownMenuItem<String>(
                  value: entity,
                  child: Text(
                    entity,
                    style: kh.typography.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                controller.setEntityTypeFilter(val == 'ALL' ? null : val);
              },
            ),
          ),
          // Actor Search field
          SizedBox(
            width: 200,
            child: TextField(
              key: const Key('audit-actor-search-input'),
              controller: _actorSearchController,
              decoration: InputDecoration(
                labelText: 'Actor User ID',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: kh.shapes.roundedSm),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 18),
                  onPressed: () =>
                      controller.setActorFilter(_actorSearchController.text.trim()),
                ),
              ),
              onSubmitted: (val) => controller.setActorFilter(val.trim()),
            ),
          ),
          SizedBox(
            width: 160,
            child: TextField(
              key: const Key('audit-ip-search-input'),
              controller: _ipSearchController,
              decoration: InputDecoration(
                labelText: 'Client IP',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: kh.shapes.roundedSm),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 18),
                  onPressed: () =>
                      controller.setIpFilter(_ipSearchController.text.trim()),
                ),
              ),
              onSubmitted: (val) => controller.setIpFilter(val.trim()),
            ),
          ),
          // Date Range picker button
          OutlinedButton.icon(
            key: const Key('audit-date-range-button'),
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(dateRangeLabel()),
            onPressed: () => _pickDateRange(context, filters),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: kh.spacing.md,
                vertical: kh.spacing.sm,
              ),
            ),
          ),
          // Clear filters button
          if (filters.hasActiveFilters)
            TextButton.icon(
              key: const Key('audit-clear-filters-button'),
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Reset'),
              onPressed: () {
                _actionSearchController.clear();
                _actorSearchController.clear();
                _ipSearchController.clear();
                controller.clearFilters();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, List<AuditLogItem> items) {
    final kh = context.kh;
    final colors = kh.colors;

    return KhDataTable(
      key: const Key('audit-data-table'),
      minWidth: 840,
      columns: const [
        KhTableColumn('Occurred At (GST)', flex: 3),
        KhTableColumn('Action', flex: 3),
        KhTableColumn('Actor (User ID)', flex: 2),
        KhTableColumn('Target Entity', flex: 3),
        KhTableColumn('Metadata', flex: 2),
        KhTableColumn('Details', flex: 1),
      ],
      rows: [
        for (final item in items)
          KhTableRow(
            key: Key('audit-row-${item.id}'),
            onTap: () => _showDetailModal(context, item),
            cells: [
              Text(
                item.formattedGst,
                style: kh.typography.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              KhStatusChip(
                label: item.action,
                tone: _toneForAction(item.action),
                dense: true,
              ),
              Text(
                item.actorUserId != null && item.actorUserId!.length > 12
                    ? '${item.actorUserId!.substring(0, 8)}…'
                    : (item.actorUserId ?? 'System'),
                style: kh.typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: kh.typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: item.entityType,
                      style: kh.typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.entityId != null)
                      TextSpan(
                        text: ' · ${item.entityId!.length > 8 ? "${item.entityId!.substring(0, 8)}…" : item.entityId}',
                        style: kh.typography.bodySmall.copyWith(
                          color: colors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                item.ip ?? '—',
                style: kh.typography.bodySmall.copyWith(
                  color: colors.textMuted,
                  fontSize: 11,
                ),
              ),
              OutlinedButton(
                onPressed: () => _showDetailModal(context, item),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: kh.spacing.xs,
                    vertical: kh.spacing.xxs,
                  ),
                  minimumSize: Size(0, kh.spacing.buttonHeight - 10),
                ),
                child: Text(
                  'Inspect',
                  style: kh.typography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPaginationControls(
    BuildContext context,
    AuditState state,
    AuditController controller,
  ) {
    final kh = context.kh;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page ${state.page} · Showing ${state.items.length} records',
          style: kh.typography.bodySmall.copyWith(
            color: kh.colors.textSecondary,
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              key: const Key('audit-prev-page-button'),
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('Previous'),
              onPressed: state.canGoPrevious ? controller.previousPage : null,
            ),
            SizedBox(width: kh.spacing.sm),
            OutlinedButton.icon(
              key: const Key('audit-next-page-button'),
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text('Next'),
              onPressed: state.canGoNext ? controller.nextPage : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final kh = context.kh;

    return Center(
      key: const Key('audit-empty-view'),
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.shield_outlined,
              size: 48,
              color: kh.colors.textMuted,
            ),
            SizedBox(height: kh.spacing.md),
            Text(
              'No audit records found',
              style: kh.typography.title,
            ),
            SizedBox(height: kh.spacing.xs),
            Text(
              'No log events match your current filter criteria.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    final kh = context.kh;
    final colors = kh.colors;

    return Container(
      key: const Key('audit-error-view'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.error),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Text(
              'Failed to load audit trail: $error',
              style: kh.typography.body.copyWith(color: colors.error),
            ),
          ),
          SizedBox(width: kh.spacing.md),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// Banner reminding operators that audit log views are self-audited.
class _SelfViewAuditNotice extends StatelessWidget {
  const _SelfViewAuditNotice();

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;

    return Container(
      key: const Key('audit-self-view-notice'),
      padding: EdgeInsets.symmetric(
        horizontal: kh.spacing.md,
        vertical: kh.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.accentHighlight.withValues(alpha: 0.08),
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(
          color: colors.accentHighlight.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: colors.accentHighlight,
          ),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Text(
              'Audit access log: Viewing this log generates an immutable AUDIT_VIEWED entry.',
              style: kh.typography.bodySmall.copyWith(
                color: colors.accentHighlight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
