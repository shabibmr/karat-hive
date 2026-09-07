import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/kh_theme.dart';
import '../../../core/design/widgets/kh_data_table.dart';
import '../../../core/design/widgets/kh_metric_card.dart';
import '../../../core/design/widgets/kh_screen_header.dart';
import '../../../core/design/widgets/kh_section_label.dart';
import '../../../core/design/widgets/kh_status_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/dashboard_controller.dart';
import '../model/dashboard_stats.dart';

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
    value: 'AED 4.2M',
    label: 'Platform Statistics',
    caption: 'Reports & Analytics →',
    route: '/reports',
    tintValue: true,
  ),
];

/// A row in the Quick Action Queues table.
class _QueueItem {
  const _QueueItem({
    required this.subject,
    required this.reference,
    required this.type,
    required this.submitted,
    required this.status,
    required this.tone,
    required this.actionLabel,
    required this.route,
  });

  final String subject;
  final String reference;
  final String type;
  final String submitted;
  final String status;
  final KhStatusTone tone;
  final String actionLabel;
  final String route;
}

const List<_QueueItem> _kSampleQueue = [
  _QueueItem(
    subject: 'Al Noor Jewellery LLC',
    reference: 'CN-1092834',
    type: 'KYC Verification',
    submitted: '10 Aug 05:30',
    status: 'PENDING',
    tone: KhStatusTone.pending,
    actionLabel: 'Review KYC',
    route: '/verification',
  ),
  _QueueItem(
    subject: 'Report #AB-2026-081',
    reference: 'Inappropriate quote',
    type: 'Abuse Report',
    submitted: '10 Aug 04:12',
    status: 'HIGH PRIORITY',
    tone: KhStatusTone.error,
    actionLabel: 'Inspect',
    route: '/abuse',
  ),
  _QueueItem(
    subject: 'Review #REV-9912',
    reference: 'By Fatima M.',
    type: 'Review Moderation',
    submitted: '09 Aug 22:40',
    status: 'MODERATION',
    tone: KhStatusTone.moderation,
    actionLabel: 'Approve',
    route: '/moderation',
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
    const _DashboardMetric(
      value: 'AED 4.2M',
      label: 'Platform Statistics',
      caption: 'Reports & Analytics →',
      route: '/reports',
      tintValue: true,
    ),
  ];
}

/// ADM-S02 · Admin dashboard.
///
/// Platform-health landing with live metric panels and actionable queue counts
/// (`FR-ADM-003`–`FR-ADM-009`). Dynamically loads stats from `GET /v1/admin/dashboard`.
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
                'Indicative figures synchronized with the admin dashboard endpoint '
                    '(GET /v1/admin/dashboard). Platform analytics reflect operational metrics.',
          ),
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
          KhSectionLabel(l10n?.quickActionQueues ?? 'Quick Action Queues'),
          SizedBox(height: spacing.sm),
          _QueueTable(l10n: l10n),
        ],
      ),
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

class _QueueTable extends StatelessWidget {
  const _QueueTable({required this.l10n});

  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return KhDataTable(
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
        for (final item in _kSampleQueue)
          KhTableRow(
            key: Key('queue-row-${item.route.substring(1)}'),
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
                item.submitted,
                style: kh.typography.bodySmall
                    .copyWith(color: kh.colors.textMuted),
              ),
              KhStatusChip(label: item.status, tone: item.tone, dense: true),
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
    );
  }
}
