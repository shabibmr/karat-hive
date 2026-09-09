import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_queue_item.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/dashboard/repository/dashboard_repository.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';

void main() {
  Map<String, dynamic> vendorProfile({
    required String id,
    String legalBusinessName = 'Live Gold Trading LLC',
    String tradeLicenceNumber = 'CN-555001',
    String createdAt = '2026-08-10T01:30:00.000Z',
  }) {
    return {
      'id': id,
      'legalBusinessName': legalBusinessName,
      'tradingName': 'Live Gold',
      'tradeLicenceNumber': tradeLicenceNumber,
      'verificationState': 'PENDING_VERIFICATION',
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> abuseRow({
    required String id,
    String description = 'Off-platform payment demand',
    String createdAt = '2026-08-10T00:12:00.000Z',
  }) {
    return {
      'id': id,
      'reporterUserId': 'user-rep-$id',
      'reportedUserId': 'user-tgt-$id',
      'entityType': 'VENDOR',
      'entityId': 'ven-1',
      'category': 'INAPPROPRIATE_TERMS',
      'description': description,
      'state': 'OPEN',
      'createdAt': createdAt,
      'updatedAt': createdAt,
    };
  }

  Map<String, dynamic> reviewRow({
    required String id,
    String authorName = 'Sara Customer',
    String createdAt = '2026-08-09T18:40:00.000Z',
  }) {
    return {
      'id': id,
      'connectionId': 'conn-$id',
      'authorType': 'CUSTOMER',
      'authorUserId': 'user-auth-$id',
      'subjectUserId': 'user-subj-$id',
      'rating': 5,
      'comment': 'Excellent workmanship',
      'state': 'PENDING_MODERATION',
      'createdAt': createdAt,
      'author': {
        'id': 'user-auth-$id',
        'customerProfile': {'displayName': authorName},
      },
    };
  }

  ApiClient buildClient({
    dynamic dashboardData,
    List<Map<String, dynamic>>? verificationItems,
    List<Map<String, dynamic>>? abuseItems,
    List<Map<String, dynamic>>? reviewItems,
    Set<String> failingPaths = const {},
    void Function(RequestOptions)? onRequest,
  }) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          onRequest?.call(options);
          final path = options.path;
          if (failingPaths.contains(path)) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 500,
                data: {
                  'error': {
                    'code': 'INTERNAL',
                    'message': 'boom',
                  },
                },
              ),
            );
          }

          if (path == '/v1/admin/dashboard') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: dashboardData ??
                    {
                      'data': {
                        'totalCustomers': 1420,
                        'totalVendors': 185,
                        'pendingVerificationVendors': 7,
                        'activeRequests': 890,
                        'activeOffers': 2340,
                        'activeConnections': 512,
                      },
                    },
              ),
            );
          }

          if (path == '/v1/admin/verification-queue') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': verificationItems ??
                      [
                        vendorProfile(id: 'ven-1'),
                        vendorProfile(
                          id: 'ven-2',
                          legalBusinessName: 'Second Vendor LLC',
                          tradeLicenceNumber: 'CN-555002',
                        ),
                        vendorProfile(
                          id: 'ven-3',
                          legalBusinessName: 'Third Vendor LLC',
                          tradeLicenceNumber: 'CN-555003',
                        ),
                      ],
                },
              ),
            );
          }

          if (path == '/v1/admin/abuse-reports') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': abuseItems ??
                        [
                          abuseRow(id: 'ab-1'),
                          abuseRow(id: 'ab-2', description: 'Spam terms'),
                          abuseRow(id: 'ab-3', description: 'Should be truncated'),
                        ],
                    'nextCursor': 'ab-3',
                  },
                  'meta': {'nextCursor': 'ab-3'},
                },
              ),
            );
          }

          if (path == '/v1/admin/reports/request-volume') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'name': 'request-volume',
                    'generatedAt': '2026-09-09T00:00:00.000Z',
                    'rows': [
                      {'state': 'OPEN', 'count': 42},
                      {'state': 'CONNECTED', 'count': 17},
                      {'state': 'EXPIRED', 'count': 9},
                    ],
                    'series': <dynamic>[],
                  },
                  'meta': {'serverTime': '2026-09-09T00:00:00.000Z'},
                },
              ),
            );
          }

          if (path == '/v1/admin/reviews') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': reviewItems ??
                        [
                          reviewRow(id: 'rev-1'),
                          reviewRow(id: 'rev-2', authorName: 'Omar Vendor'),
                          reviewRow(id: 'rev-3', authorName: 'Extra'),
                        ],
                    'nextCursor': 'rev-3',
                  },
                  'meta': {'nextCursor': 'rev-3'},
                },
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );
    return ApiClient(baseUrl: 'http://localhost:3000', dio: dio);
  }

  group('DashboardQueueItem public parse', () {
    test('parses a vendor-profile verification row and GST submitted label', () {
      final item = DashboardQueueItem.fromVerificationJson(
        vendorProfile(id: 'ven-1'),
      );

      expect(item.id, 'ven-1');
      expect(item.subject, 'Live Gold Trading LLC');
      expect(item.reference, 'CN-555001');
      expect(item.type, 'KYC Verification');
      expect(item.status, 'PENDING');
      expect(item.actionLabel, 'Review KYC');
      expect(item.route, '/verification');
      expect(item.kind, DashboardQueueKind.verification);
      expect(item.submittedLabel, '10 Aug 05:30');
    });

    test('parses an abuse-report row', () {
      final item = DashboardQueueItem.fromAbuseJson(abuseRow(id: 'ab-1'));

      expect(item.subject, 'Report #ab-1');
      expect(item.reference, 'Off-platform payment demand');
      expect(item.type, 'Abuse Report');
      expect(item.status, 'OPEN');
      expect(item.actionLabel, 'Inspect');
      expect(item.route, '/abuse');
      expect(item.kind, DashboardQueueKind.abuse);
      expect(item.submittedLabel, '10 Aug 04:12');
    });

    test('parses a pending-review row including nested author name', () {
      final item = DashboardQueueItem.fromReviewJson(reviewRow(id: 'rev-1'));

      expect(item.subject, 'Review #rev-1');
      expect(item.reference, 'By Sara Customer');
      expect(item.type, 'Review Moderation');
      expect(item.status, 'MODERATION');
      expect(item.actionLabel, 'Approve');
      expect(item.route, '/moderation');
      expect(item.kind, DashboardQueueKind.review);
      expect(item.submittedLabel, '09 Aug 22:40');
    });
  });

  group('DashboardRepository with real backend envelope shapes', () {
    test('parses stats from standard unwrapped backend envelope', () async {
      final client = buildClient();
      final repository = DashboardRepository(client);
      final stats = await repository.fetchStats();

      expect(stats.totalCustomers, 1420);
      expect(stats.totalVendors, 185);
      expect(stats.pendingVerificationVendors, 7);
      expect(stats.activeRequests, 890);
      expect(stats.activeOffers, 2340);
      expect(stats.activeConnections, 512);
    });

    test('parses stats from double-wrapped NestJS envelope interceptor',
        () async {
      // NestJS EnvelopeInterceptor wraps { data } into { data: { data: ... }, meta: ... }
      final client = buildClient(
        dashboardData: {
          'data': {
            'data': {
              'totalCustomers': 500,
              'totalVendors': 75,
              'pendingVerificationVendors': 3,
              'activeRequests': 120,
              'activeOffers': 340,
              'activeConnections': 88,
            },
          },
          'meta': {
            'requestId': 'req-dash-001',
            'serverTime': '2026-08-10T10:00:00.000Z',
          },
        },
      );

      final repository = DashboardRepository(client);
      final stats = await repository.fetchStats();

      expect(stats.totalCustomers, 500);
      expect(stats.totalVendors, 75);
      expect(stats.pendingVerificationVendors, 3);
      expect(stats.activeRequests, 120);
      expect(stats.activeOffers, 340);
      expect(stats.activeConnections, 88);
    });

    test('gracefully coerces strings and numbers into integers', () {
      final stats = DashboardStats.fromJson({
        'totalCustomers': '1420',
        'totalVendors': 185.0,
        'pendingVerificationVendors': '12',
        'activeRequests': 90,
        'activeOffers': '240',
        'activeConnections': 15,
      });

      expect(stats.totalCustomers, 1420);
      expect(stats.totalVendors, 185);
      expect(stats.pendingVerificationVendors, 12);
      expect(stats.activeRequests, 90);
      expect(stats.activeOffers, 240);
      expect(stats.activeConnections, 15);
    });

    test('handles empty / zero-valued payload', () {
      final stats = DashboardStats.fromJson({});

      expect(stats.totalCustomers, 0);
      expect(stats.totalVendors, 0);
      expect(stats.pendingVerificationVendors, 0);
      expect(stats.activeRequests, 0);
      expect(stats.activeOffers, 0);
      expect(stats.activeConnections, 0);
    });

    test('supports copyWith and equality comparison', () {
      const initial = DashboardStats(
        totalCustomers: 10,
        totalVendors: 5,
        pendingVerificationVendors: 1,
        activeRequests: 2,
        activeOffers: 3,
        activeConnections: 4,
      );

      final modified = initial.copyWith(totalCustomers: 20);
      expect(modified.totalCustomers, 20);
      expect(modified.totalVendors, 5);

      final identicalCopy = initial.copyWith();
      expect(identicalCopy, equals(initial));
      expect(identicalCopy.hashCode, equals(initial.hashCode));
      expect(initial.toString(), contains('customers: 10'));
    });

    test('fetchVerificationSnapshot takes the first two vendor profiles',
        () async {
      final client = buildClient();
      final repository = DashboardRepository(client);

      final items = await repository.fetchVerificationSnapshot();

      expect(items.length, 2);
      expect(items.first.id, 'ven-1');
      expect(items.first.subject, 'Live Gold Trading LLC');
      expect(items.last.id, 'ven-2');
    });

    test('fetchAbuseSnapshot uses getCollection and caps at two rows',
        () async {
      RequestOptions? captured;
      final client = buildClient(onRequest: (opt) {
        if (opt.path == '/v1/admin/abuse-reports') captured = opt;
      });
      final repository = DashboardRepository(client);

      final items = await repository.fetchAbuseSnapshot();

      expect(items.length, 2);
      expect(items.first.id, 'ab-1');
      expect(items.first.subject, 'Report #ab-1');
      expect(captured, isNotNull);
      expect(captured!.queryParameters['limit'], '2');
    });

    test('fetchPendingReviewsSnapshot filters PENDING_MODERATION and caps at two',
        () async {
      RequestOptions? captured;
      final client = buildClient(onRequest: (opt) {
        if (opt.path == '/v1/admin/reviews') captured = opt;
      });
      final repository = DashboardRepository(client);

      final items = await repository.fetchPendingReviewsSnapshot();

      expect(items.length, 2);
      expect(items.first.id, 'rev-1');
      expect(items.first.reference, 'By Sara Customer');
      expect(captured, isNotNull);
      expect(captured!.queryParameters['limit'], '2');
      expect(captured!.queryParameters['state'], 'PENDING_MODERATION');
    });

    test('snapshot fetches throw independently when a source returns 500',
        () async {
      final client = buildClient(
        failingPaths: {'/v1/admin/abuse-reports'},
      );
      final repository = DashboardRepository(client);

      final verification = await repository.fetchVerificationSnapshot();
      expect(verification, isNotEmpty);

      await expectLater(
        repository.fetchAbuseSnapshot(),
        throwsA(isA<ApiException>()),
      );

      final reviews = await repository.fetchPendingReviewsSnapshot();
      expect(reviews, isNotEmpty);
    });

    test('fetchStats forwards from/to as yyyy-MM-dd query params (TR-S6-03)',
        () async {
      RequestOptions? captured;
      final client = buildClient(onRequest: (opt) {
        if (opt.path == '/v1/admin/dashboard') captured = opt;
      });
      final repository = DashboardRepository(client);

      await repository.fetchStats(
        from: DateTime.utc(2026, 8, 10),
        to: DateTime.utc(2026, 9, 9),
      );

      expect(captured, isNotNull);
      expect(captured!.queryParameters['from'], '2026-08-10');
      expect(captured!.queryParameters['to'], '2026-09-09');
    });

    test('fetchStats sends no query params when no range is given', () async {
      RequestOptions? captured;
      final client = buildClient(onRequest: (opt) {
        if (opt.path == '/v1/admin/dashboard') captured = opt;
      });
      final repository = DashboardRepository(client);

      await repository.fetchStats();

      expect(captured!.queryParameters.containsKey('from'), isFalse);
      expect(captured!.queryParameters.containsKey('to'), isFalse);
    });

    test('fetchTrend parses request-volume into chart points (TR-S6-04)',
        () async {
      RequestOptions? captured;
      final client = buildClient(onRequest: (opt) {
        if (opt.path == '/v1/admin/reports/request-volume') captured = opt;
      });
      final repository = DashboardRepository(client);

      final result = await repository.fetchTrend(
        const ReportFilters(),
      );

      expect(result.chartPoints, isNotEmpty);
      expect(result.chartPoints.first.value, 42);
      expect(captured, isNotNull);
    });

    test('fetchTrend passes the range through as query params', () async {
      RequestOptions? captured;
      final client = buildClient(onRequest: (opt) {
        if (opt.path == '/v1/admin/reports/request-volume') captured = opt;
      });
      final repository = DashboardRepository(client);

      await repository.fetchTrend(
        ReportFilters(
          from: DateTime.utc(2026, 8, 10),
          to: DateTime.utc(2026, 9, 9),
        ),
      );

      expect(captured!.queryParameters['from'], '2026-08-10');
      expect(captured!.queryParameters['to'], '2026-09-09');
    });
  });
}
