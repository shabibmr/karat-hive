import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/json_parse.dart';
import 'package:kh_admin/core/platform/open_url.dart';
import 'package:kh_admin/features/reports/model/export_job.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';
import 'package:kh_admin/features/reports/model/report_name.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';

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
    this.maxPollInterval = const Duration(seconds: 2),
    this.maxPolls = 12,
  });

  final ApiClient _apiClient;
  final UrlOpener openUrl;
  /// Delay before the first re-check. Doubles after each attempt.
  final Duration pollInterval;

  /// Ceiling for the backoff, so a slow export still gets checked regularly.
  final Duration maxPollInterval;

  final int maxPolls;

  Future<ReportResult> fetchReport({
    required ReportName name,
    ReportFilters filters = const ReportFilters(),
  }) async {
    final response = await _apiClient.get(
      '/v1/admin/reports/${name.apiValue}',
      queryParameters: filters.toQueryParameters(),
    );
    final map = unwrapEntity(response);
    if (map['name'] == null) {
      map['name'] = name.apiValue;
    }
    return ReportResult.fromJson(map);
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
    return ExportJob.fromJson(unwrapEntity(response));
  }

  Future<ExportJob> getExport(String id) async {
    final response = await _apiClient.get('/v1/admin/exports/$id');
    return ExportJob.fromJson(unwrapEntity(response));
  }

  /// Re-checks [id] until the job reaches a terminal state or [maxPolls] is hit.
  ///
  /// The wait doubles after each attempt up to [maxPollInterval], so a job that
  /// finishes quickly is still noticed promptly while a slow one does not
  /// generate a request every [pollInterval] for the whole of its life. With
  /// the defaults that is ~21s of patience across 12 requests, where a flat
  /// 400ms interval spent 40 requests to cover ~16s.
  ///
  /// A zero [pollInterval] disables waiting entirely (used by tests).
  Future<ExportJob> pollUntilComplete(String id) async {
    var job = await getExport(id);
    var delay = pollInterval;
    var attempts = 0;
    while (!job.status.isTerminal && attempts < maxPolls) {
      attempts += 1;
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
        delay = delay * 2 > maxPollInterval ? maxPollInterval : delay * 2;
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

  static String _csvCell(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }
}
