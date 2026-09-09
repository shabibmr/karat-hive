import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/error/api_error_messages.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/dashboard/controller/dashboard_controller.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_queue_item.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_range.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';
import 'package:kh_admin/features/reports/presentation/report_chart.dart';

/// A metric tile on the dashboard.
class _DashboardMetric {
  const _DashboardMetric({
    required this.value,
    required this.label,
    required this.caption,
    required this.route,
    this.emphasized = false,
    this.tintValue = false,
  });

  final String value;
  final String label;
  final String caption;
  final String route;
  final bool emphasized;
  final bool tintValue;
}

/// Fallback metrics shown while the dashboard query is initializing.
const List<_DashboardMetric> _kPlaceholderMetrics = [
  _DashboardMetric(
    value: '—',
    label: 'Customers',
    caption: 'Customer List →',
    route: '/customers',
    emphasized: true,
  ),
  _DashboardMetric(
    value: '—',
    label: 'Vendors',
    caption: 'Vendor List →',
    route: '/vendors',
    emphasized: true,
  ),
  _DashboardMetric(
    value: '—',
    label: 'Requests',
    caption: 'All Requests →',
    route: '/requests',
  ),
  _DashboardMetric(
    value: '—',
    label: 'Offers',
    caption: 'All Active & Past Offers →',
    route: '/offers',
  ),
  _DashboardMetric(
    value: '—',
    label: 'Connections',
    caption: 'Active Connections →',
    route: '/connections',
  ),
  _DashboardMetric(
    value: '—',
    label: 'KYC Queue',
    caption: 'Verification Queue →',
    route: '/verification',
    tintValue: true,
  ),
];

/// Formats integer count with thousand separators (e.g. 1,420).
String _formatCount(int value) {
  final str = value.toString();
  final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
}

/// Constructs dynamic metric cards from [DashboardStats].
List<_DashboardMetric> _buildMetrics(DashboardStats stats) {
  return [
    _DashboardMetric(
      value: _formatCount(stats.totalCustomers),
      label: 'Customers',
      caption: 'Customer List →',
      route: '/customers',
      emphasized: true,
    ),
    _DashboardMetric(
      value: _formatCount(stats.totalVendors),
      label: 'Vendors',
      caption:
          'Vendor List (${_formatCount(stats.pendingVerificationVendors)} KYC pending) →',
      route: '/vendors',
      emphasized: true,
    ),
    _DashboardMetric(
      value: _formatCount(stats.activeRequests),
      label: 'Requests',
      caption: 'All Requests →',
      route: '/requests',
    ),
    _DashboardMetric(
      value: _formatCount(stats.activeOffers),
      label: 'Offers',
      caption: 'All Active & Past Offers →',
      route: '/offers',
    ),
    _DashboardMetric(
      value: _formatCount(stats.activeConnections),
      label: 'Connections',
      caption: 'Active Connections →',
      route: '/connections',
    ),
    _DashboardMetric(
      value: _formatCount(stats.pendingVerificationVendors),
      label: 'KYC Queue',
      caption: 'Verification Queue →',
      route: '/verification',
      tintValue: true,
    ),
  ];
}

KhStatusTone _toneForKind(DashboardQueueKind kind) {
  switch (kind) {
    case DashboardQueueKind.verification:
      return KhStatusTone.pending;
    case DashboardQueueKind.abuse:
      return KhStatusTone.error;
    case DashboardQueueKind.review:
      return KhStatusTone.moderation;
  }
}

/// ADM-S02 · Admin dashboard.
///
/// Platform-health landing with live metric panels and queue snapshots
/// (`FR-ADM-003`–`FR-ADM-009`). Stats from `GET /v1/admin/dashboard`; queues
/// from verification / abuse / pending-review endpoints. No GMV (`BR-015`).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kh = context.kh;
    final spacing = kh.spacing;
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(dashboardControllerProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhScreenHeader(
            eyebrow: l10n?.dashboardEyebrow ?? 'Platform Overview',
            heading: l10n?.dashboardHeading ?? 'Admin Control Center',
            trailing: KhStatusChip(
              key: const Key('dashboard-system-status-chip'),
              label: l10n?.systemOperational ?? 'SYSTEM OPERATIONAL',
              tone: KhStatusTone.success,
            ),
          ),
          SizedBox(height: spacing.lg),
          _IndicativeDataNotice(
            message: l10n?.dashboardSampleDataNotice ??
                'Live platform figures from GET /v1/admin/dashboard. Queue rows '
                    'snapshot verification, abuse reports, and pending reviews.',
          ),
          SizedBox(height: spacing.lg),
          _RangeSelector(l10n: l10n),
          SizedBox(height: spacing.lg),
          if (statsAsync.hasError) ...[
            _DashboardErrorBanner(
              message: statsAsync.error.toString(),
              onRetry: () =>
                  ref.read(dashboardControllerProvider.notifier).refresh(),
            ),
            SizedBox(height: spacing.lg),
          ],
          _buildMetricsSection(context, statsAsync),
          SizedBox(height: spacing.xl),
          KhSectionLabel(l10n?.dashboardTrendsHeading ?? 'Trends'),
          SizedBox(height: spacing.sm),
          const _TrendSection(),
          SizedBox(height: spacing.xl),
          KhSectionLabel(l10n?.quickActionQueues ?? 'Quick Action Queues'),
          SizedBox(height: spacing.sm),
          _buildQueueSection(context, ref, l10n),
        ],
      ),
    );
  }

  Widget _buildQueueSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations? l10n,
  ) {
    const kinds = DashboardQueueKind.values;
    final sources = <DashboardQueueKind, AsyncValue<List<DashboardQueueItem>>>{
      for (final kind in kinds)
        kind: ref.watch(dashboardQueueSourceProvider(kind)),
    };

    final items = <DashboardQueueItem>[
      for (final kind in kinds)
        ...(sources[kind]!.valueOrNull ?? const <DashboardQueueItem>[]),
    ];
    final errors = <_QueueSourceError>[
      for (final kind in kinds)
        if (sources[kind]!.hasError)
          _QueueSourceError(kind, sources[kind]!.error!),
    ];
    final anyLoading = sources.values.any((s) => s.isLoading);

    return _QueueTable(
      l10n: l10n,
      items: items,
      errors: errors,
      isLoading: anyLoading,
      onRetry: (kind) =>
          ref.invalidate(dashboardQueueSourceProvider(kind)),
    );
  }

  Widget _buildMetricsSection(
    BuildContext context,
    AsyncValue<DashboardStats> statsAsync,
  ) {
    if (statsAsync.isLoading && !statsAsync.hasValue) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricGrid(
            metrics: _kPlaceholderMetrics,
            isLoading: true,
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(),
        ],
      );
    }

    final stats = statsAsync.valueOrNull;
    final metrics = stats != null ? _buildMetrics(stats) : _kPlaceholderMetrics;

    return _MetricGrid(
      metrics: metrics,
      isLoading: statsAsync.isLoading,
    );
  }
}

/// Error banner with retry trigger.
class _DashboardErrorBanner extends StatelessWidget {
  const _DashboardErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;

    return Container(
      key: const Key('dashboard-error-banner'),
      padding: EdgeInsets.symmetric(
        horizontal: kh.spacing.md,
        vertical: kh.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.10),
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(color: colors.error.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: colors.error),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Text(
              'Failed to load dashboard metrics: $message',
              style: kh.typography.bodySmall.copyWith(color: colors.error),
            ),
          ),
          SizedBox(width: kh.spacing.sm),
          OutlinedButton.icon(
            key: const Key('dashboard-error-retry-button'),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// Banner marking indicative figures and API source.
class _IndicativeDataNotice extends StatelessWidget {
  const _IndicativeDataNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;

    return Container(
      key: const Key('dashboard-sample-data-notice'),
      padding: EdgeInsets.symmetric(
        horizontal: kh.spacing.md,
        vertical: kh.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.10),
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(color: colors.warning.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: colors.warning),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Text(
              message,
              style: kh.typography.bodySmall.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reproduces the mock's `repeat(auto-fit, minmax(200px, 1fr))` metric grid.
class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.metrics,
    this.isLoading = false,
  });

  final List<_DashboardMetric> metrics;
  final bool isLoading;

  static const double _minTileWidth = 200;

  @override
  Widget build(BuildContext context) {
    final gap = context.kh.spacing.md;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final columns =
            ((available + gap) / (_minTileWidth + gap)).floor().clamp(1, 6);
        final tileWidth = (available - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: tileWidth,
                child: Opacity(
                  opacity: isLoading ? 0.6 : 1.0,
                  child: KhMetricCard(
                    key: Key('metric-card-${metric.label.toLowerCase()}'),
                    value: metric.value,
                    label: metric.label,
                    linkText: metric.caption,
                    emphasized: metric.emphasized,
                    valueColor: metric.tintValue
                        ? context.kh.colors.accentHighlight
                        : null,
                    onTap: () => context.go(metric.route),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A queue source that threw, kept alongside its [DashboardQueueKind] so the
/// screen can render a per-source retry (`TR-S6-02`).
class _QueueSourceError {
  const _QueueSourceError(this.kind, this.error);

  final DashboardQueueKind kind;
  final Object error;
}

String _queueSourceLabel(DashboardQueueKind kind, AppLocalizations? l10n) {
  switch (kind) {
    case DashboardQueueKind.verification:
      return l10n?.queueSourceVerification ?? 'verification queue';
    case DashboardQueueKind.abuse:
      return l10n?.queueSourceAbuse ?? 'abuse reports';
    case DashboardQueueKind.review:
      return l10n?.queueSourceReview ?? 'pending reviews';
  }
}

class _QueueTable extends StatelessWidget {
  const _QueueTable({
    required this.l10n,
    required this.items,
    required this.errors,
    required this.isLoading,
    required this.onRetry,
  });

  final AppLocalizations? l10n;
  final List<DashboardQueueItem> items;
  final List<_QueueSourceError> errors;
  final bool isLoading;
  final void Function(DashboardQueueKind kind) onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final isEmpty = !isLoading && items.isEmpty && errors.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final err in errors) ...[
          _QueueSourceErrorChip(
            kind: err.kind,
            message: resolveApiErrorMessage(err.error, l10n),
            sourceLabel: _queueSourceLabel(err.kind, l10n),
            retryLabel: l10n?.dashboardQueueRetry ?? 'Retry',
            onRetry: () => onRetry(err.kind),
          ),
          SizedBox(height: kh.spacing.sm),
        ],
        KhDataTable(
          key: const Key('dashboard-queue-table'),
          columns: [
            KhTableColumn(l10n?.queueColumnItem ?? 'Queue Item', flex: 4),
            KhTableColumn(l10n?.queueColumnType ?? 'Type', flex: 2),
            KhTableColumn(l10n?.queueColumnSubmitted ?? 'Submitted', flex: 2),
            KhTableColumn(l10n?.queueColumnStatus ?? 'Status', flex: 3),
            KhTableColumn(l10n?.queueColumnAction ?? 'Action', flex: 2),
          ],
          minWidth: 720,
          rows: [
            for (final item in items)
              KhTableRow(
                key: Key('queue-row-${item.kind.name}-${item.id}'),
                cells: [
                  RichText(
                    text: TextSpan(
                      style: kh.typography.bodySmall
                          .copyWith(color: kh.colors.textSecondary),
                      children: [
                        TextSpan(
                          text: item.subject,
                          style: kh.typography.bodySmall.copyWith(
                            color: kh.colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: '  (${item.reference})'),
                      ],
                    ),
                  ),
                  Text(
                    item.type,
                    style: kh.typography.bodySmall
                        .copyWith(color: kh.colors.textSecondary),
                  ),
                  Text(
                    item.submittedLabel,
                    style: kh.typography.bodySmall
                        .copyWith(color: kh.colors.textMuted),
                  ),
                  KhStatusChip(
                    label: item.status,
                    tone: _toneForKind(item.kind),
                    dense: true,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton(
                      onPressed: () => context.go(item.route),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: kh.spacing.sm,
                          vertical: kh.spacing.xxs,
                        ),
                        minimumSize: Size(0, kh.spacing.buttonHeight - 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        item.actionLabel,
                        style: kh.typography.caption
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (isEmpty) ...[
          SizedBox(height: kh.spacing.sm),
          Text(
            'No items in the action queues.',
            key: const Key('dashboard-queue-empty'),
            style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
          ),
        ],
      ],
    );
  }
}

/// Inline error strip with a Retry — shared by the queue sources and the trend
/// series (`TR-S6-02`, `TR-S6-04`).
class _DashboardInlineError extends StatelessWidget {
  const _DashboardInlineError({
    required this.errorKey,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.retryKey,
  });

  final Key errorKey;
  final Key? retryKey;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;

    return Container(
      key: errorKey,
      padding: EdgeInsets.symmetric(
        horizontal: kh.spacing.md,
        vertical: kh.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.10),
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(color: colors.error.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: colors.error),
          SizedBox(width: kh.spacing.sm),
          Expanded(
            child: Text(
              message,
              style: kh.typography.bodySmall.copyWith(color: colors.error),
            ),
          ),
          SizedBox(width: kh.spacing.sm),
          OutlinedButton.icon(
            key: retryKey,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(retryLabel),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _QueueSourceErrorChip extends StatelessWidget {
  const _QueueSourceErrorChip({
    required this.kind,
    required this.message,
    required this.sourceLabel,
    required this.retryLabel,
    required this.onRetry,
  });

  final DashboardQueueKind kind;
  final String message;
  final String sourceLabel;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _DashboardInlineError(
      errorKey: Key('dashboard-queue-source-error-${kind.name}'),
      retryKey: Key('dashboard-queue-source-retry-${kind.name}'),
      message: "Couldn't load $sourceLabel — $message",
      retryLabel: retryLabel,
      onRetry: onRetry,
    );
  }
}

String _rangeLabel(DashboardRange range, AppLocalizations? l10n) {
  switch (range) {
    case DashboardRange.last7Days:
      return l10n?.dashboardRange7 ?? range.fallbackLabel;
    case DashboardRange.last30Days:
      return l10n?.dashboardRange30 ?? range.fallbackLabel;
    case DashboardRange.last90Days:
      return l10n?.dashboardRange90 ?? range.fallbackLabel;
  }
}

/// ADM-S02 date-range selector (`TR-S6-03`). `Wrap` of chips so it reflows
/// instead of overflowing at narrow widths.
class _RangeSelector extends ConsumerWidget {
  const _RangeSelector({required this.l10n});

  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kh = context.kh;
    final selected = ref.watch(dashboardRangeProvider);

    return Column(
      key: const Key('dashboard-range-selector'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.dashboardRangeLabel ?? 'Date range',
          style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
        ),
        SizedBox(height: kh.spacing.xs),
        Wrap(
          spacing: kh.spacing.sm,
          runSpacing: kh.spacing.xs,
          children: [
            for (final range in DashboardRange.values)
              ChoiceChip(
                key: Key('dashboard-range-chip-${range.days}'),
                label: Text(_rangeLabel(range, l10n)),
                selected: range == selected,
                onSelected: (isSelected) {
                  if (isSelected) {
                    ref.read(dashboardRangeProvider.notifier).state = range;
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// ADM-S02 trend series (`TR-S6-04`). Range-scoped request-volume figures — the
/// only range-aware data the backend exposes today (GAP-ADM-10).
class _TrendSection extends ConsumerWidget {
  const _TrendSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final trendAsync = ref.watch(dashboardTrendProvider);

    return Column(
      key: const Key('dashboard-trend-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n?.dashboardTrendCaption ??
              'Request volume by state over the selected range.',
          style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
        ),
        SizedBox(height: kh.spacing.sm),
        trendAsync.when(
          loading: () => const SizedBox(
            key: Key('dashboard-trend-loading'),
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => _DashboardInlineError(
            errorKey: const Key('dashboard-trend-error'),
            retryKey: const Key('dashboard-trend-retry'),
            message: resolveApiErrorMessage(error, l10n),
            retryLabel: l10n?.dashboardQueueRetry ?? 'Retry',
            onRetry: () => ref.invalidate(dashboardTrendProvider),
          ),
          data: (result) => _trendBody(context, result, l10n),
        ),
      ],
    );
  }

  Widget _trendBody(
    BuildContext context,
    ReportResult result,
    AppLocalizations? l10n,
  ) {
    final kh = context.kh;
    final points = result.chartPoints;

    if (points.isEmpty) {
      return Container(
        key: const Key('dashboard-trend-empty'),
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kh.colors.backgroundElevated,
          borderRadius: kh.shapes.roundedSm,
          border: Border.all(color: kh.colors.borderSubtle),
        ),
        child: Text(
          l10n?.dashboardTrendEmpty ?? 'No trend data for this range.',
          style:
              kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
        ),
      );
    }

    return Container(
      key: const Key('dashboard-trend-chart'),
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: ReportChart(points: points),
    );
  }
}
