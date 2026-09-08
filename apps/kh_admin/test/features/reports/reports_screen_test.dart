import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/reports/model/export_job.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';
import 'package:kh_admin/features/reports/model/report_name.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';
import 'package:kh_admin/features/reports/presentation/reports_screen.dart';
import 'package:kh_admin/features/reports/repository/reports_repository.dart';

class _FakeReportsRepository extends ReportsRepository {
  _FakeReportsRepository() : super(ApiClient(), openUrl: (_) {});

  bool empty = false;
  bool failNext = false;
  Completer<ReportResult>? delay;
  int fetchCount = 0;
  int startExportCount = 0;
  int pollCount = 0;
  ExportFormat? lastFormat;
  String? lastPurpose;
  ReportName? lastFetchedName;
  bool clientCsvDownloaded = false;
  ExportJobStatus pollStatus = ExportJobStatus.ready;

  @override
  Future<ReportResult> fetchReport({
    required ReportName name,
    ReportFilters filters = const ReportFilters(),
  }) async {
    fetchCount += 1;
    lastFetchedName = name;
    if (delay != null) return delay!.future;
    if (failNext) {
      failNext = false;
      throw Exception('Reports backend service unavailable');
    }
    if (empty) {
      return ReportResult(
        name: name,
        generatedAt: DateTime.parse('2026-09-01T10:00:00.000Z'),
        rows: const [],
        series: const [],
      );
    }
    return ReportResult(
      name: name,
      generatedAt: DateTime.parse('2026-09-01T10:00:00.000Z'),
      rows: const [
        {'rating': 5, 'count': 12},
        {'rating': 4, 'count': 7},
      ],
      series: const [
        {'label': '5★', 'value': 12},
        {'label': '4★', 'value': 7},
      ],
    );
  }

  @override
  Future<ExportJob> startExport({
    required ReportName reportName,
    required ExportFormat format,
    ReportFilters filters = const ReportFilters(),
    required String purpose,
  }) async {
    startExportCount += 1;
    lastFormat = format;
    lastPurpose = purpose;
    return const ExportJob(id: 'exp-1', status: ExportJobStatus.queued);
  }

  @override
  Future<ExportJob> pollUntilComplete(String id) async {
    pollCount += 1;
    return ExportJob(id: id, status: pollStatus);
  }

  @override
  void downloadClientCsv({
    required String reportName,
    required List<Map<String, dynamic>> rows,
  }) {
    clientCsvDownloaded = true;
  }
}

void main() {
  Widget buildTestableScreen({required ReportsRepository repository}) {
    return ProviderScope(
      overrides: [
        reportsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: const Scaffold(body: ReportsScreen()),
      ),
    );
  }

  group('ReportsScreen', () {
    testWidgets('loads a report into the results table and chart', (tester) async {
      tester.view.physicalSize = const Size(1400, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeReportsRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Platform Analytics & Reports'), findsOneWidget);
      expect(find.text('BUSINESS INTELLIGENCE'), findsOneWidget);
      expect(find.byKey(const Key('reports-table')), findsOneWidget);
      expect(find.text('12'), findsWidgets);
      expect(find.text('7'), findsWidgets);
      expect(find.byKey(const Key('reports-chart')), findsOneWidget);
      expect(
        find.textContaining('indicative', findRichText: true),
        findsWidgets,
      );
    });

    testWidgets('shows empty period table and chart placeholder', (tester) async {
      tester.view.physicalSize = const Size(1400, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeReportsRepository()..empty = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('reports-empty')), findsOneWidget);
      expect(find.byKey(const Key('reports-chart-empty')), findsOneWidget);
      expect(find.byKey(const Key('reports-chart')), findsNothing);
    });

    testWidgets('shows error state and retries', (tester) async {
      tester.view.physicalSize = const Size(1400, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeReportsRepository()..failNext = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('reports-error')), findsOneWidget);
      expect(find.byKey(const Key('reports-retry')), findsOneWidget);

      await tester.tap(find.byKey(const Key('reports-retry')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('reports-table')), findsOneWidget);
      expect(repo.fetchCount, greaterThanOrEqualTo(2));
    });

    testWidgets('shows loading indicator while a report is in flight',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeReportsRepository()..delay = Completer<ReportResult>();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pump();

      expect(find.byKey(const Key('reports-loading')), findsOneWidget);

      repo.delay!.complete(
        ReportResult(
          name: ReportName.ratingDistribution,
          generatedAt: DateTime.parse('2026-09-01T10:00:00.000Z'),
          rows: const [],
          series: const [],
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('export requires purpose then starts and polls the job',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeReportsRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reports-export-csv')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('reports-purpose-field')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('reports-purpose-field')),
        'Monthly operations review',
      );
      await tester.tap(find.byKey(const Key('reports-export-confirm')));
      await tester.pumpAndSettle();

      expect(repo.startExportCount, 1);
      expect(repo.pollCount, 1);
      expect(repo.lastFormat, ExportFormat.csv);
      expect(repo.lastPurpose, 'Monthly operations review');
      expect(repo.clientCsvDownloaded, isTrue);
      expect(find.textContaining('50,000'), findsWidgets);
    });
  });
}
