import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/platform/open_url.dart';
import '../model/export_job.dart';
import '../model/report_filters.dart';
import '../model/report_name.dart';
import '../model/report_result.dart';

typedef UrlOpener = void Function(String url);

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReportsRepository(client);
});

/// Typed repository for ADM-S17 reports and async exports.
class ReportsRepository {
  ReportsRepository(
    this._apiClient, {
    this.openUrl = openUrlInNewTab,
    this.pollInterval = const Duration(milliseconds: 400),
    this.maxPolls = 40,
  });

  final ApiClient _apiClient;
  final UrlOpener openUrl;
  final Duration pollInterval;
  final int maxPolls;

  Future<ReportResult> fetchReport({
    required ReportName name,
    ReportFilters filters = const ReportFilters(),
  }) async {
    final response = await _apiClient.get(
      '/v1/admin/reports/${name.apiValue}',
      queryParameters: filters.toQueryParameters(),
    );
    return ReportResult.fromJson(_unwrapEntity(response, fallbackName: name));
  }

  Future<ExportJob> startExport({
    required ReportName reportName,
    required ExportFormat format,
    ReportFilters filters = const ReportFilters(),
    required String purpose,
  }) async {
    final trimmed = purpose.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Export purpose is required (NFR-016).');
    }

    final response = await _apiClient.post(
      '/v1/admin/exports',
      data: {
        'reportName': reportName.apiValue,
        'format': format.apiValue,
        'filters': filters.toJson(),
        'purpose': trimmed,
      },
    );
    return ExportJob.fromJson(_unwrapMap(response));
  }

  Future<ExportJob> getExport(String id) async {
    final response = await _apiClient.get('/v1/admin/exports/$id');
    return ExportJob.fromJson(_unwrapMap(response));
  }

  Future<ExportJob> pollUntilComplete(String id) async {
    var job = await getExport(id);
    var attempts = 0;
    while (!job.status.isTerminal && attempts < maxPolls) {
      attempts += 1;
      if (pollInterval > Duration.zero) {
        await Future<void>.delayed(pollInterval);
      }
      job = await getExport(id);
    }
    return job;
  }

  /// Opens the server download when a relative or absolute `downloadUrl` is present.
  ///
  /// There is currently no `/v1/admin/exports/:id/download` route; callers should
  /// still invoke this and fall back to [downloadClientCsv].
  void openReadyDownload(ExportJob job) {
    if (job.status != ExportJobStatus.ready) return;
    final url = job.downloadUrl;
    if (url == null || url.trim().isEmpty) return;
    openUrl(_resolveDownloadUrl(url.trim()));
  }

  void downloadClientCsv({
    required String reportName,
    required List<Map<String, dynamic>> rows,
  }) {
    final csv = rowsToCsv(rows);
    final dataUrl = Uri.dataFromString(
      '\uFEFF$csv',
      mimeType: 'text/csv',
      encoding: utf8,
    ).toString();
    openUrl(dataUrl);
  }

  static String rowsToCsv(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return '';
    final keys = <String>[];
    for (final row in rows) {
      for (final key in row.keys) {
        if (!keys.contains(key)) keys.add(key);
      }
    }
    final buffer = StringBuffer()..writeln(keys.map(_csvCell).join(','));
    for (final row in rows) {
      buffer.writeln(keys.map((key) => _csvCell(row[key])).join(','));
    }
    return buffer.toString();
  }

  String _resolveDownloadUrl(String downloadUrl) {
    if (downloadUrl.startsWith('http://') || downloadUrl.startsWith('https://')) {
      return downloadUrl;
    }
    if (downloadUrl.startsWith('/')) return '$khApiBase$downloadUrl';
    return '$khApiBase/$downloadUrl';
  }

  Map<String, dynamic> _unwrapEntity(
    dynamic response, {
    required ReportName fallbackName,
  }) {
    final map = _unwrapMap(response);
    if (map['name'] == null) {
      map['name'] = fallbackName.apiValue;
    }
    return map;
  }

  Map<String, dynamic> _unwrapMap(dynamic response) {
    if (response is! Map) {
      return <String, dynamic>{};
    }
    final map = Map<String, dynamic>.from(response);
    if (map['data'] is Map && map['id'] == null && map['name'] == null && map['status'] == null) {
      return Map<String, dynamic>.from(map['data'] as Map);
    }
    return map;
  }

  static String _csvCell(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }
}
