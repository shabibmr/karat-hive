import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/features/reports/model/export_job.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';
import 'package:kh_admin/features/reports/model/report_name.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';
import 'package:kh_admin/features/reports/repository/reports_repository.dart';

void main() {
  group('ReportResult.fromJson', () {
    test('parses name, generatedAt, rows, and series', () {
      final result = ReportResult.fromJson({
        'name': 'rating-distribution',
        'generatedAt': '2026-09-01T10:00:00.000Z',
        'rows': [
          {'rating': 5, 'count': 12},
          {'rating': 4, 'count': 7},
        ],
        'series': [
          {'label': '5', 'value': 12},
        ],
      });

      expect(result.name, ReportName.ratingDistribution);
      expect(result.generatedAt, DateTime.parse('2026-09-01T10:00:00.000Z'));
      expect(result.rows, hasLength(2));
      expect(result.rows.first['rating'], 5);
      expect(result.rows.first['count'], 12);
      expect(result.series, hasLength(1));
      expect(result.series.first['label'], '5');
    });

    test('treats missing rows and series as empty lists', () {
      final result = ReportResult.fromJson({
        'name': 'acquisition',
        'generatedAt': '2026-09-01T10:00:00.000Z',
      });

      expect(result.name, ReportName.acquisition);
      expect(result.rows, isEmpty);
      expect(result.series, isEmpty);
      expect(result.isEmpty, isTrue);
    });
  });

  ApiClient buildClient({
    Map<String, dynamic>? reportPayload,
    void Function(RequestOptions)? onGetReport,
    void Function(RequestOptions)? onPostExport,
    List<Map<String, dynamic>>? exportPollSequence,
    String exportCreateStatus = 'QUEUED',
  }) {
    var pollIndex = 0;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;
          final method = options.method.toUpperCase();

          if (method == 'GET' && path.startsWith('/v1/admin/reports/')) {
            onGetReport?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': reportPayload ??
                      {
                        'name': path.split('/').last,
                        'generatedAt': '2026-09-01T10:00:00.000Z',
                        'rows': [
                          {'rating': 5, 'count': 3},
                        ],
                        'series': <Map<String, dynamic>>[],
                      },
                },
              ),
            );
          }

          if (method == 'POST' && path == '/v1/admin/exports') {
            onPostExport?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 202,
                data: {
                  'data': {
                    'id': 'exp-1',
                    'status': exportCreateStatus,
                  },
                },
              ),
            );
          }

          if (method == 'GET' && path.startsWith('/v1/admin/exports/')) {
            final sequence = exportPollSequence ??
                [
                  {'id': 'exp-1', 'status': 'READY'},
                ];
            final payload = sequence[pollIndex.clamp(0, sequence.length - 1)];
            if (pollIndex < sequence.length - 1) {
              pollIndex += 1;
            }
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': payload},
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );
    return ApiClient(dio: dio);
  }

  group('ReportsRepository', () {
    test('fetches a report and parses rows', () async {
      RequestOptions? captured;
      final repo = ReportsRepository(
        buildClient(
          onGetReport: (opt) => captured = opt,
          reportPayload: {
            'name': 'request-volume',
            'generatedAt': '2026-09-01T10:00:00.000Z',
            'rows': [
              {'state': 'OPEN', 'count': 8},
              {'state': 'MATCHED', 'count': 2},
            ],
            'series': <Map<String, dynamic>>[],
          },
        ),
      );

      final result = await repo.fetchReport(
        name: ReportName.requestVolume,
        filters: ReportFilters(
          from: DateTime.utc(2026, 8, 1),
          to: DateTime.utc(2026, 9, 1),
          regionId: 'reg-1',
          categoryId: 'cat-9',
        ),
      );

      expect(captured!.path, '/v1/admin/reports/request-volume');
      expect(captured!.queryParameters['from'], '2026-08-01');
      expect(captured!.queryParameters['to'], '2026-09-01');
      expect(captured!.queryParameters['regionId'], 'reg-1');
      expect(captured!.queryParameters['categoryId'], 'cat-9');
      expect(result.name, ReportName.requestVolume);
      expect(result.rows, hasLength(2));
      expect(result.rows.first['state'], 'OPEN');
      expect(result.chartPoints, hasLength(2));
      expect(result.chartPoints.first.label, 'OPEN');
      expect(result.chartPoints.first.value, 8);
    });

    test('returns empty rows and series for an empty period without throwing',
        () async {
      final repo = ReportsRepository(
        buildClient(
          reportPayload: {
            'name': 'acquisition',
            'generatedAt': '2026-09-01T10:00:00.000Z',
            'rows': <Map<String, dynamic>>[],
            'series': <Map<String, dynamic>>[],
          },
        ),
      );

      final result = await repo.fetchReport(name: ReportName.acquisition);

      expect(result.rows, isEmpty);
      expect(result.series, isEmpty);
      expect(result.chartPoints, isEmpty);
      expect(result.isEmpty, isTrue);
    });

    test('posts export body with reportName, format, filters, and purpose',
        () async {
      RequestOptions? captured;
      final opened = <String>[];
      final repo = ReportsRepository(
        buildClient(onPostExport: (opt) => captured = opt),
        openUrl: opened.add,
        pollInterval: Duration.zero,
      );

      final job = await repo.startExport(
        reportName: ReportName.funnel,
        format: ExportFormat.csv,
        filters: const ReportFilters(regionId: 'dxb'),
        purpose: 'Quarterly operations audit',
      );

      expect(job.id, 'exp-1');
      expect(job.status, ExportJobStatus.queued);
      expect(captured!.path, '/v1/admin/exports');
      expect(captured!.data, {
        'reportName': 'funnel',
        'format': 'CSV',
        'filters': {'regionId': 'dxb'},
        'purpose': 'Quarterly operations audit',
      });
    });

    test('polls export until READY and opens downloadUrl when present', () async {
      final opened = <String>[];
      final repo = ReportsRepository(
        buildClient(
          exportPollSequence: [
            {'id': 'exp-1', 'status': 'RUNNING'},
            {
              'id': 'exp-1',
              'status': 'READY',
              'downloadUrl': '/v1/admin/exports/exp-1/download',
              'completedAt': '2026-09-01T11:00:00.000Z',
            },
          ],
        ),
        openUrl: opened.add,
        pollInterval: Duration.zero,
      );

      final job = await repo.pollUntilComplete('exp-1');

      expect(job.status, ExportJobStatus.ready);
      expect(job.downloadUrl, '/v1/admin/exports/exp-1/download');
      repo.openReadyDownload(job);
      expect(opened, ['http://localhost:3000/v1/admin/exports/exp-1/download']);
    });

    test('polls export until FAILED and does not open a download', () async {
      final opened = <String>[];
      final repo = ReportsRepository(
        buildClient(
          exportPollSequence: [
            {'id': 'exp-1', 'status': 'QUEUED'},
            {'id': 'exp-1', 'status': 'FAILED'},
          ],
        ),
        openUrl: opened.add,
        pollInterval: Duration.zero,
      );

      final job = await repo.pollUntilComplete('exp-1');

      expect(job.status, ExportJobStatus.failed);
      repo.openReadyDownload(job);
      expect(opened, isEmpty);
    });

    test('builds a client-side CSV of current rows', () {
      final csv = ReportsRepository.rowsToCsv([
        {'rating': 5, 'count': 12},
        {'rating': 4, 'count': 7},
      ]);

      expect(csv, contains('rating,count'));
      expect(csv, contains('5,12'));
      expect(csv, contains('4,7'));
    });

    test('surfaces API errors from report fetch', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 500,
                data: {
                  'error': {
                    'code': 'INTERNAL_ERROR',
                    'message': 'Reports unavailable',
                  },
                },
              ),
            );
          },
        ),
      );
      final repo = ReportsRepository(ApiClient(dio: dio));

      expect(
        () => repo.fetchReport(name: ReportName.funnel),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
