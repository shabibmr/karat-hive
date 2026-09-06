import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/kh_theme.dart';
import '../../../core/design/widgets/kh_data_table.dart';
import '../../../core/design/widgets/kh_metric_card.dart';
import '../../../core/design/widgets/kh_screen_header.dart';
import '../../../core/design/widgets/kh_section_label.dart';
import '../../../core/design/widgets/kh_status_chip.dart';
import '../../../l10n/app_localizations.dart';

/// A metric tile on the dashboard.
///
/// [value] and [caption] are **sample** figures — see [_kSampleMetrics].
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

/// Placeholder figures lifted from `ui-mock/screens/admin/ADM-S02-dashboard.html`.
///
/// `GET /v1/admin/dashboard` (`FR-ADM-003`–`009`, API-Route-Inventory L1689) is
/// not implemented — `backend/src/modules/admin/` holds no controller yet — so
/// these are hard-coded and the screen says so above the grid. When the
/// endpoint lands, replace this list with its response; the tiles need no
/// other change.
const List<_DashboardMetric> _kSampleMetrics = [
  _DashboardMetric(
    value: '1,420',
    label: 'Customers',
    caption: 'Customer List →',
    route: '/customers',
    emphasized: true,
  ),
  _DashboardMetric(
    value: '185',
    label: 'Vendors',
    caption: 'Vendor List (7 KYC pending) →',
    route: '/vendors',
    emphasized: true,
  ),
  _DashboardMetric(
    value: '890',
    label: 'Requests',
    caption: 'All Requests (68% w/ Offers) →',
    route: '/requests',
  ),
  _DashboardMetric(
    value: '2,340',
    label: 'Offers',
    caption: 'All Active & Past Offers →',
    route: '/offers',
  ),
  _DashboardMetric(
    value: '512',
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

/// A row in the Quick Action Queues table. Sample data, as above.
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

/// ADM-S02 · Admin dashboard.
///
/// Platform-health landing with metric panels and actionable queue counts
/// (`FR-ADM-003`–`FR-ADM-009`). Figures are indicative sample data until the
/// dashboard endpoint exists; the notice above the grid says so, because
/// unlabelled placeholder numbers on a landing screen read as live platform
/// state.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final spacing = kh.spacing;
    final l10n = AppLocalizations.of(context);

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
                'Indicative sample figures. The admin dashboard endpoint '
                    '(GET /v1/admin/dashboard) is not implemented yet — no '
                    'number below reflects live platform data.',
          ),
          SizedBox(height: spacing.lg),
          const _MetricGrid(),
          SizedBox(height: spacing.xl),
          KhSectionLabel(l10n?.quickActionQueues ?? 'Quick Action Queues'),
          SizedBox(height: spacing.sm),
          _QueueTable(l10n: l10n),
        ],
      ),
    );
  }
}

/// Banner marking every figure on the screen as placeholder data.
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
  const _MetricGrid();

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
            for (final metric in _kSampleMetrics)
              SizedBox(
                width: tileWidth,
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
