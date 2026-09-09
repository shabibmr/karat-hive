import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';
import 'package:kh_admin/features/abuse/repository/abuse_repository.dart';

void main() {
  Map<String, dynamic> rawAbuseReportRow({
    required String id,
    String state = 'OPEN',
    String entityType = 'VENDOR',
    String entityId = 'ven-1',
    String category = 'INAPPROPRIATE_TERMS',
    String description = 'Vendor demanded off-platform advance payment',
  }) {
    return {
      'id': id,
      'reporterUserId': 'user-rep-$id',
      'reportedUserId': 'user-tgt-$id',
      'entityType': entityType,
      'entityId': entityId,
      'category': category,
      'description': description,
      'state': state,
      'resolution': state == 'RESOLVED' ? 'Action taken' : null,
      'resolvedByAdminId': null,
      'createdAt': '2026-09-01T10:00:00.000Z',
      'updatedAt': '2026-09-01T10:00:00.000Z',
      'reporter': {
        'id': 'user-rep-$id',
        'email': 'reporter@example.com',
        'mobileNumber': '+971501111111',
        'customerProfile': {'displayName': 'Sara Customer'},
      },
      'reported': {
        'id': 'user-tgt-$id',
        'email': 'vendor@example.com',
        'mobileNumber': '+971502222222',
        'vendorProfile': {'tradingName': 'Al Noor Jewellers'},
      },
    };
  }

  ApiClient buildClient({
    void Function(RequestOptions)? onPostResolve,
    void Function(RequestOptions)? onPostDismiss,
  }) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;

          if (path == '/v1/admin/abuse-reports') {
            final query = options.queryParameters;
            var rows = [
              rawAbuseReportRow(id: 'ab-1', state: 'OPEN', entityType: 'VENDOR'),
              rawAbuseReportRow(id: 'ab-2', state: 'RESOLVED', entityType: 'CUSTOMER'),
            ];

            if (query['state'] != null) {
              rows = rows.where((r) => r['state'] == query['state']).toList();
            }
            if (query['entityType'] != null) {
              rows = rows.where((r) => r['entityType'] == query['entityType']).toList();
            }
            if (query['q'] != null) {
              final q = query['q'].toString().toLowerCase();
              rows = rows
                  .where((r) =>
                      r['id'].toString().toLowerCase().contains(q) ||
                      r['description'].toString().toLowerCase().contains(q))
                  .toList();
            }

            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': rows,
                    'nextCursor': 'ab-2',
                  },
                  'meta': {'nextCursor': 'ab-2'},
                },
              ),
            );
          }

          if (path.startsWith('/v1/admin/abuse-reports/') && path.endsWith('/resolve')) {
            onPostResolve?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': {'id': 'ab-1', 'state': 'RESOLVED'}},
              ),
            );
          }

          if (path.startsWith('/v1/admin/abuse-reports/') && path.endsWith('/dismiss')) {
            onPostDismiss?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': {'id': 'ab-1', 'state': 'DISMISSED'}},
              ),
            );
          }

          if (path == '/v1/admin/abuse-reports/ab-1') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': rawAbuseReportRow(id: 'ab-1')},
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );
    return ApiClient(dio: dio);
  }

  group('AbuseRepository', () {
    test('fetches abuse reports and parses rows correctly', () async {
      final client = buildClient();
      final repo = AbuseRepository(client);

      final page = await repo.fetchAbuseReports();

      expect(page.items.length, 2);
      expect(page.items.first.id, 'ab-1');
      expect(page.items.first.state, AbuseReportState.open);
      expect(page.items.first.entityType, AbuseEntityType.vendor);
      expect(page.items.first.reporterName, 'Sara Customer');
      expect(page.items.first.reportedName, 'Al Noor Jewellers');
      expect(page.hasMore, true);
      expect(page.nextCursor, 'ab-2');
    });

    test('filters abuse reports by query via query parameters', () async {
      final client = buildClient();
      final repo = AbuseRepository(client);

      final page = await repo.fetchAbuseReports(
        filters: const AbuseReportFilters(query: 'ab-1'),
      );

      expect(page.items.length, 1);
      expect(page.items.first.id, 'ab-1');
    });

    test('filters abuse reports by entityType via query parameters', () async {
      final client = buildClient();
      final repo = AbuseRepository(client);

      final page = await repo.fetchAbuseReports(
        filters: const AbuseReportFilters(entityType: AbuseEntityType.customer),
      );

      expect(page.items.length, 1);
      expect(page.items.first.id, 'ab-2');
    });

    test('calls resolve endpoint with rationale', () async {
      RequestOptions? captured;
      final client = buildClient(onPostResolve: (opt) => captured = opt);
      final repo = AbuseRepository(client);

      await repo.resolveAbuseReport('ab-1', resolution: 'Vendor warned');

      expect(captured, isNotNull);
      expect(captured!.path, '/v1/admin/abuse-reports/ab-1/resolve');
      expect(captured!.data, {'resolution': 'Vendor warned'});
    });

    test('calls dismiss endpoint with rationale', () async {
      RequestOptions? captured;
      final client = buildClient(onPostDismiss: (opt) => captured = opt);
      final repo = AbuseRepository(client);

      await repo.dismissAbuseReport('ab-1', resolution: 'No violation found');

      expect(captured, isNotNull);
      expect(captured!.path, '/v1/admin/abuse-reports/ab-1/dismiss');
      expect(captured!.data, {'resolution': 'No violation found'});
    });

    test('fetches single abuse report detail', () async {
      final client = buildClient();
      final repo = AbuseRepository(client);

      final item = await repo.getAbuseReport('ab-1');

      expect(item.id, 'ab-1');
      expect(item.description, 'Vendor demanded off-platform advance payment');
    });
  });
}
