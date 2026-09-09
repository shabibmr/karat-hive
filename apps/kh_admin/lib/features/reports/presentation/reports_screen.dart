import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/reports/controller/reports_controller.dart';
import 'package:kh_admin/features/reports/model/export_job.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';
import 'package:kh_admin/features/reports/model/report_name.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';
import 'package:kh_admin/features/reports/presentation/report_chart.dart';

/// ADM-S17 · Reports & analytics.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  late final TextEditingController _regionController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(reportsControllerProvider).filters;
    _fromController = TextEditingController(
      text: filters.from != null ? ReportFilters.toIsoDate(filters.from!) : '',
    );
    _toController = TextEditingController(
      text: filters.to != null ? ReportFilters.toIsoDate(filters.to!) : '',
    );
    _regionController = TextEditingController(text: filters.regionId ?? '');
    _categoryController = TextEditingController(text: filters.categoryId ?? '');
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _regionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(reportsControllerProvider);
    final controller = ref.read(reportsControllerProvider.notifier);

    ref.listen<ReportsState>(reportsControllerProvider, (previous, next) {
      if (next.exportMessage != null &&
          next.exportMessage != previous?.exportMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.exportMessage!)),
        );
      }
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KhScreenHeader(
            eyebrow: l10n?.reportsEyebrow ?? 'BUSINESS INTELLIGENCE',
            heading: l10n?.reportsHeading ?? 'Platform Analytics & Reports',
            supportingText: l10n?.reportsSubtitle ??
                'Operational reports over a date range, filtered by Region and Category.',
            trailing: KhStatusChip(
              label: state.result?.name.fallbackLabel ?? state.name.fallbackLabel,
              tone: KhStatusTone.moderation,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          _indicativeBanner(context, l10n),
          SizedBox(height: kh.spacing.md),
          _metrics(context, state),
          SizedBox(height: kh.spacing.lg),
          _filters(context, l10n, state, controller),
          SizedBox(height: kh.spacing.md),
          _exportBar(context, l10n, state),
          SizedBox(height: kh.spacing.lg),
          if (state.isLoading && state.result == null)
            Center(
              key: const Key('reports-loading'),
              child: Padding(
                padding: EdgeInsets.all(kh.spacing.xl),
                child: const CircularProgressIndicator(),
              ),
            )
          else if (state.errorMessage != null && state.result == null)
            _errorState(context, l10n, state.errorMessage!, controller)
          else
            _results(context, l10n, state),
        ],
      ),
    );
  }

  Widget _indicativeBanner(BuildContext context, AppLocalizations? l10n) {
    final kh = context.kh;
    return Container(
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.backgroundSurface,
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Text(
        l10n?.reportsIndicativeNote ??
            'Figures are indicative operational metrics, not settlement or GMV. Settlement happens off-platform. Units: AED, grams, karat/fineness. Timestamps display as Gulf Standard Time.',
        style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
      ),
    );
  }

  Widget _metrics(BuildContext context, ReportsState state) {
    final result = state.result;
    final rowCount = result?.rows.length ?? 0;
    final generated = result == null
        ? '—'
        : _formatGst(result.generatedAt);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 36) / 4;
        final minWidth = cardWidth > 200 ? cardWidth : 200.0;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '$rowCount',
                label: 'RESULT ROWS',
                linkText: 'Current period',
              ),
            ),
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${result?.numericTotal ?? 0}',
                label: 'INDICATIVE TOTAL',
                linkText: 'Sum of count fields',
              ),
            ),
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${result?.chartPoints.length ?? 0}',
                label: 'CHART POINTS',
                linkText: 'Series or rows',
              ),
            ),
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: generated,
                label: 'GENERATED AT (GST)',
                linkText: 'Server timestamp',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _filters(
    BuildContext context,
    AppLocalizations? l10n,
    ReportsState state,
    ReportsController controller,
  ) {
    final kh = context.kh;
    return Wrap(
      spacing: kh.spacing.md,
      runSpacing: kh.spacing.md,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: 320,
          child: DropdownButtonFormField<ReportName>(
            key: const Key('reports-type-selector'),
            initialValue: state.name,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n?.reportsTypeLabel ?? 'Report type',
              isDense: true,
            ),
            items: [
              for (final name in ReportName.all)
                DropdownMenuItem(
                  value: name,
                  child: Text(
                    _labelFor(name, l10n),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) controller.setReportName(value);
            },
          ),
        ),
        SizedBox(
          width: 160,
          child: TextField(
            key: const Key('reports-from-field'),
            controller: _fromController,
            decoration: InputDecoration(
              labelText: l10n?.reportsFrom ?? 'From (YYYY-MM-DD)',
            ),
          ),
        ),
        SizedBox(
          width: 160,
          child: TextField(
            key: const Key('reports-to-field'),
            controller: _toController,
            decoration: InputDecoration(
              labelText: l10n?.reportsTo ?? 'To (YYYY-MM-DD)',
            ),
          ),
        ),
        SizedBox(
          width: 180,
          child: TextField(
            key: const Key('reports-region-field'),
            controller: _regionController,
            decoration: InputDecoration(
              labelText: l10n?.reportsRegionId ?? 'Region ID (optional)',
            ),
          ),
        ),
        SizedBox(
          width: 180,
          child: TextField(
            key: const Key('reports-category-field'),
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: l10n?.reportsCategoryId ?? 'Category ID (optional)',
            ),
          ),
        ),
        ElevatedButton(
          key: const Key('reports-apply-button'),
          onPressed: state.isLoading
              ? null
              : () => controller.applyFilters(_readFilters()),
          child: Text(l10n?.reportsApply ?? 'Apply'),
        ),
      ],
    );
  }

  Widget _exportBar(
    BuildContext context,
    AppLocalizations? l10n,
    ReportsState state,
  ) {
    final kh = context.kh;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: kh.spacing.sm,
          runSpacing: kh.spacing.sm,
          children: [
            OutlinedButton.icon(
              key: const Key('reports-export-csv'),
              onPressed: state.isExporting
                  ? null
                  : () => _promptExport(context, l10n, ExportFormat.csv),
              icon: const Icon(Icons.table_view_outlined, size: 16),
              label: Text(l10n?.reportsExportCsv ?? 'Export CSV'),
            ),
            OutlinedButton.icon(
              key: const Key('reports-export-xlsx'),
              onPressed: state.isExporting
                  ? null
                  : () => _promptExport(context, l10n, ExportFormat.xlsx),
              icon: const Icon(Icons.grid_on_outlined, size: 16),
              label: Text(l10n?.reportsExportXlsx ?? 'Export XLSX'),
            ),
            OutlinedButton.icon(
              key: const Key('reports-export-png'),
              onPressed: state.isExporting
                  ? null
                  : () => _promptExport(context, l10n, ExportFormat.png),
              icon: const Icon(Icons.image_outlined, size: 16),
              label: Text(l10n?.reportsExportPng ?? 'Export chart PNG'),
            ),
            if (state.isExporting)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        SizedBox(height: kh.spacing.sm),
        Text(
          key: const Key('reports-async-notice'),
          l10n?.reportsExportAsyncNotice ??
              'Exports over 50,000 rows are generated asynchronously and delivered as a time-limited download link. Personal-data exports are watermarked with admin, time, and purpose (NFR-016).',
          style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
        ),
      ],
    );
  }

  Widget _errorState(
    BuildContext context,
    AppLocalizations? l10n,
    String message,
    ReportsController controller,
  ) {
    final kh = context.kh;
    return Container(
      key: const Key('reports-error'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(message, style: kh.typography.body),
          SizedBox(height: kh.spacing.md),
          ElevatedButton(
            key: const Key('reports-retry'),
            onPressed: controller.refresh,
            child: Text(l10n?.reportsRetry ?? 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _results(
    BuildContext context,
    AppLocalizations? l10n,
    ReportsState state,
  ) {
    final kh = context.kh;
    final result = state.result;
    final points = result?.chartPoints ?? const <ReportChartPoint>[];
    final isEmpty = result == null || result.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (points.isEmpty)
          Container(
            key: const Key('reports-chart-empty'),
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kh.colors.backgroundElevated,
              borderRadius: kh.shapes.roundedSm,
              border: Border.all(color: kh.colors.borderSubtle),
            ),
            child: Text(
              l10n?.reportsEmptyChart ?? 'No chart data for this period.',
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
            ),
          )
        else
          Container(
            key: const Key('reports-chart'),
            padding: EdgeInsets.all(kh.spacing.md),
            decoration: BoxDecoration(
              color: kh.colors.backgroundElevated,
              borderRadius: kh.shapes.roundedSm,
              border: Border.all(color: kh.colors.borderSubtle),
            ),
            child: ReportChart(points: points),
          ),
        SizedBox(height: kh.spacing.lg),
        if (isEmpty)
          Container(
            key: const Key('reports-empty'),
            padding: EdgeInsets.all(kh.spacing.lg),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kh.colors.backgroundElevated,
              borderRadius: kh.shapes.roundedSm,
              border: Border.all(color: kh.colors.borderSubtle),
            ),
            child: Text(
              l10n?.reportsEmptyPeriod ??
                  'No rows for this period. Try a different date range, Region, or Category.',
              style: kh.typography.body.copyWith(color: kh.colors.textSecondary),
            ),
          )
        else
          KhDataTable(
            key: const Key('reports-table'),
            columns: [
              for (final column in result.columnKeys)
                KhTableColumn(_humanize(column)),
            ],
            rows: [
              for (final row in result.rows)
                KhTableRow(
                  cells: [
                    for (final column in result.columnKeys)
                      Text(
                        '${row[column] ?? ''}',
                        style: kh.typography.bodySmall,
                      ),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  ReportFilters _readFilters() {
    return ReportFilters(
      from: DateTime.tryParse(_fromController.text.trim()),
      to: DateTime.tryParse(_toController.text.trim()),
      regionId: _regionController.text.trim(),
      categoryId: _categoryController.text.trim(),
    );
  }

  Future<void> _promptExport(
    BuildContext context,
    AppLocalizations? l10n,
    ExportFormat format,
  ) async {
    final confirmed = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _ExportPurposeDialog(l10n: l10n),
    );
    if (confirmed == null || !mounted) return;
    await ref.read(reportsControllerProvider.notifier).exportReport(
          format: format,
          purpose: confirmed,
        );
  }

  String _labelFor(ReportName name, AppLocalizations? l10n) {
    switch (name) {
      case ReportName.acquisition:
        return l10n?.reportsTypeAcquisition ?? name.fallbackLabel;
      case ReportName.vendorLeague:
        return l10n?.reportsTypeVendorLeague ?? name.fallbackLabel;
      case ReportName.requestVolume:
        return l10n?.reportsTypeRequestVolume ?? name.fallbackLabel;
      case ReportName.offerCompetitiveness:
        return l10n?.reportsTypeOfferCompetitiveness ?? name.fallbackLabel;
      case ReportName.funnel:
        return l10n?.reportsTypeFunnel ?? name.fallbackLabel;
      case ReportName.liquidityGaps:
        return l10n?.reportsTypeLiquidityGaps ?? name.fallbackLabel;
      case ReportName.ratingDistribution:
        return l10n?.reportsTypeRatingDistribution ?? name.fallbackLabel;
    }
  }

  String _humanize(String key) {
    if (key.isEmpty) return key;
    final spaced = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    );
    return spaced.replaceAll('_', ' ').replaceAll('-', ' ');
  }

  String _formatGst(DateTime value) {
    final gst = value.toUtc().add(const Duration(hours: 4));
    return '${DateFormat('yyyy-MM-dd HH:mm').format(gst)} GST';
  }
}

class _ExportPurposeDialog extends StatefulWidget {
  const _ExportPurposeDialog({this.l10n});

  final AppLocalizations? l10n;

  @override
  State<_ExportPurposeDialog> createState() => _ExportPurposeDialogState();
}

class _ExportPurposeDialogState extends State<_ExportPurposeDialog> {
  late final TextEditingController _purposeController;

  @override
  void initState() {
    super.initState();
    _purposeController = TextEditingController();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n?.reportsExportPurposeTitle ?? 'Export purpose'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.reportsExportPurposeHint ??
                  'Required for the audit watermark (admin, timestamp, purpose).',
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('reports-purpose-field'),
              controller: _purposeController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n?.reportsExportPurposeLabel ?? 'Purpose',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.reportsExportCancel ?? 'Cancel'),
        ),
        ElevatedButton(
          key: const Key('reports-export-confirm'),
          onPressed: () {
            final purpose = _purposeController.text.trim();
            if (purpose.isEmpty) return;
            Navigator.of(context).pop(purpose);
          },
          child: Text(l10n?.reportsExportConfirm ?? 'Start export'),
        ),
      ],
    );
  }
}
