import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../model/export_job.dart';
import '../model/report_filters.dart';
import '../model/report_name.dart';
import '../model/report_result.dart';
import '../repository/reports_repository.dart';

class ReportsState {
  const ReportsState({
    this.isLoading = false,
    this.isExporting = false,
    this.name = ReportName.requestVolume,
    this.filters = const ReportFilters(),
    this.result,
    this.errorMessage,
    this.exportMessage,
    this.lastExportStatus,
  });

  final bool isLoading;
  final bool isExporting;
  final ReportName name;
  final ReportFilters filters;
  final ReportResult? result;
  final String? errorMessage;
  final String? exportMessage;
  final ExportJobStatus? lastExportStatus;

  ReportsState copyWith({
    bool? isLoading,
    bool? isExporting,
    ReportName? name,
    ReportFilters? filters,
    ReportResult? result,
    bool clearResult = false,
    String? errorMessage,
    bool clearError = false,
    String? exportMessage,
    bool clearExportMessage = false,
    ExportJobStatus? lastExportStatus,
    bool clearExportStatus = false,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      name: name ?? this.name,
      filters: filters ?? this.filters,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      exportMessage:
          clearExportMessage ? null : (exportMessage ?? this.exportMessage),
      lastExportStatus: clearExportStatus
          ? null
          : (lastExportStatus ?? this.lastExportStatus),
    );
  }
}

class ReportsController extends StateNotifier<ReportsState> {
  ReportsController(this._repository)
      : super(ReportsState(filters: ReportFilters.lastThirtyDays())) {
    loadReport();
  }

  final ReportsRepository _repository;

  Future<void> loadReport() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.fetchReport(
        name: state.name,
        filters: state.filters,
      );
      state = state.copyWith(
        isLoading: false,
        result: result,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearResult: true,
        errorMessage: _extractError(error),
      );
    }
  }

  Future<void> refresh() => loadReport();

  void setReportName(ReportName name) {
    if (state.name == name) return;
    state = state.copyWith(name: name);
    loadReport();
  }

  void setFilters(ReportFilters filters) {
    state = state.copyWith(filters: filters);
  }

  void applyFilters(ReportFilters filters) {
    state = state.copyWith(filters: filters);
    loadReport();
  }

  Future<bool> exportReport({
    required ExportFormat format,
    required String purpose,
  }) async {
    final trimmed = purpose.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        exportMessage: 'Export purpose is required for the audit watermark.',
      );
      return false;
    }

    state = state.copyWith(
      isExporting: true,
      clearExportMessage: true,
      clearExportStatus: true,
    );
    try {
      final started = await _repository.startExport(
        reportName: state.name,
        format: format,
        filters: state.filters,
        purpose: trimmed,
      );
      final job = started.status.isTerminal
          ? started
          : await _repository.pollUntilComplete(started.id);

      state = state.copyWith(
        isExporting: false,
        lastExportStatus: job.status,
        exportMessage: _messageFor(job, format),
      );

      if (job.status == ExportJobStatus.ready) {
        final downloadUrl = job.downloadUrl;
        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          _repository.openReadyDownload(job);
        } else {
          _repository.downloadClientCsv(
            reportName: state.name.apiValue,
            rows: state.result?.rows ?? const [],
          );
        }
        return true;
      }
      return false;
    } catch (error) {
      state = state.copyWith(
        isExporting: false,
        lastExportStatus: ExportJobStatus.failed,
        exportMessage: _extractError(error),
      );
      return false;
    }
  }

  String _messageFor(ExportJob job, ExportFormat format) {
    switch (job.status) {
      case ExportJobStatus.ready:
        if (job.downloadUrl == null || job.downloadUrl!.isEmpty) {
          return 'Export ready. Server download is not available yet; a CSV of the current table was downloaded instead.';
        }
        if (format != ExportFormat.csv) {
          return 'Export queued as ${format.apiValue}. Opening the server download URL (file bytes may 404 until the download route exists).';
        }
        return 'Export ready.';
      case ExportJobStatus.failed:
        return 'Export failed.';
      case ExportJobStatus.queued:
      case ExportJobStatus.running:
        return 'EXPORT_IN_PROGRESS';
    }
  }

  String _extractError(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}

final reportsControllerProvider =
    StateNotifierProvider<ReportsController, ReportsState>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);
  return ReportsController(repository);
});
