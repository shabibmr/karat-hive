import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/audit/model/audit_log_filters.dart';
import 'package:kh_admin/features/audit/model/audit_log_item.dart';
import 'package:kh_admin/features/audit/repository/audit_repository.dart';

void main() {
  Map<String, dynamic> rawAuditRow({
    required String id,
    String? actorUserId = 'admin-user-001',
    String action = 'VENDOR_VERIFIED',
    String entityType = 'vendor_profile',
    String? entityId = 'ven-uuid-123',
    dynamic beforeValue,
    dynamic afterValue,
    String? ipAddress = '192.168.1.50',
    String? userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    String occurredAt = '2026-08-10T05:30:00.000Z',
  }) {
    return {
      'id': id,
      'actorUserId': actorUserId,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'beforeValue': beforeValue,
      'afterValue': afterValue,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'occurredAt': occurredAt,
    };
  }

  ApiClient buildClient({String? expectedCursor}) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;

          if (path == '/v1/admin/audit-log') {
            final cursorParam = options.queryParameters['cursor'];

            if (cursorParam == 'cursor-page-2') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': {
                      'data': [
                        rawAuditRow(
                          id: 'log-3',
                          action: 'SETTINGS_UPDATED',
                          entityType: 'platform_settings',
                          entityId: 'sett-003',
                          beforeValue: '{"vatRate": 0.05}',
                          afterValue: '{"vatRate": 0.07}',
                          occurredAt: '2026-08-11T12:00:00.000Z',
                        ),
                      ],
                      'nextCursor': null,
                    },
                    'meta': {'requestId': 'req-audit-2'},
                  },
                ),
              );
            }

            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': [
                      rawAuditRow(
                        id: 'log-1',
                        action: 'VENDOR_VERIFIED',
                        entityType: 'vendor_profile',
                        entityId: 'ven-1',
                        beforeValue: {'status': 'PENDING'},
                        afterValue: {'status': 'VERIFIED'},
                        occurredAt: '2026-08-10T05:30:00.000Z', // 09:30 GST
                      ),
                      rawAuditRow(
                        id: 'log-2',
                        action: 'CUSTOMER_SUSPENDED',
                        entityType: 'customer_profile',
                        entityId: 'cust-2',
                        actorUserId: 'admin-user-002',
                        beforeValue: '{"accountState": "ACTIVE"}',
                        afterValue: '{"accountState": "SUSPENDED", "reasonCode": "TOS_BREACH"}',
                        occurredAt: '2026-08-10T22:15:00.000Z', // 02:15 GST next day
                      ),
                    ],
                    'nextCursor': 'cursor-page-2',
                  },
                  'meta': {'requestId': 'req-audit-1'},
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

  late AuditRepository repository;

  setUp(() {
    repository = AuditRepository(buildClient());
  });

  group('AuditRepository parsing and normalization', () {
    test('normalizes raw Prisma AuditLog rows correctly', () async {
      final page = await repository.fetchAuditLogs();

      expect(page.items, hasLength(2));

      final first = page.items.first;
      expect(first.id, 'log-1');
      expect(first.actorUserId, 'admin-user-001');
      expect(first.action, 'VENDOR_VERIFIED');
      expect(first.entityType, 'vendor_profile');
      expect(first.entityId, 'ven-1');
      expect(first.beforeValue, {'status': 'PENDING'});
      expect(first.afterValue, {'status': 'VERIFIED'});
      expect(first.ip, '192.168.1.50');
      expect(first.userAgent, contains('Mozilla/5.0'));

      final second = page.items[1];
      expect(second.id, 'log-2');
      expect(second.actorUserId, 'admin-user-002');
      expect(second.action, 'CUSTOMER_SUSPENDED');
      // Verifies JSON stringified payload in before/after value is parsed to Map
      expect(second.beforeValue, isA<Map<String, dynamic>>());
      expect((second.beforeValue as Map)['accountState'], 'ACTIVE');
      expect(second.afterValue, isA<Map<String, dynamic>>());
      expect((second.afterValue as Map)['accountState'], 'SUSPENDED');
      expect((second.afterValue as Map)['reasonCode'], 'TOS_BREACH');
    });

    test('supports fallback ip field mapping when ipAddress is absent', () {
      final item = AuditLogItem.fromJson({
        'id': 'log-alt-ip',
        'action': 'AUDIT_VIEWED',
        'entityType': 'audit_log',
        'ip': '10.0.0.1',
        'occurredAt': '2026-08-10T10:00:00.000Z',
      });

      expect(item.ip, '10.0.0.1');
      expect(item.action, 'AUDIT_VIEWED');
    });
  });

  group('Gulf Standard Time (GST, UTC+4 per BR-021) formatting', () {
    test('converts UTC timestamp to GST correctly (+4 hours)', () {
      final item = AuditLogItem(
        id: 'test-gst-1',
        action: 'VENDOR_VERIFIED',
        entityType: 'vendor_profile',
        occurredAt: DateTime.parse('2026-08-10T05:30:15.000Z'),
      );

      // UTC 05:30:15 -> GST 09:30:15
      expect(item.occurredAtGst.hour, 9);
      expect(item.occurredAtGst.minute, 30);
      expect(item.occurredAtGst.second, 15);
      expect(item.formattedGst, '2026-08-10 09:30:15 GST');
    });

    test('handles date rollover into the next day in GST', () {
      final item = AuditLogItem(
        id: 'test-gst-rollover',
        action: 'CUSTOMER_SUSPENDED',
        entityType: 'customer_profile',
        occurredAt: DateTime.parse('2026-08-10T22:45:00.000Z'),
      );

      // UTC 2026-08-10 22:45:00 -> GST 2026-08-11 02:45:00 (+4 hours crosses midnight)
      expect(item.occurredAtGst.day, 11);
      expect(item.occurredAtGst.month, 8);
      expect(item.occurredAtGst.year, 2026);
      expect(item.occurredAtGst.hour, 2);
      expect(item.occurredAtGst.minute, 45);
      expect(item.formattedGst, '2026-08-11 02:45:00 GST');
      expect(
        AuditLogItem.formatDateTimeGst(DateTime.parse('2026-08-10T22:45:00.000Z')),
        '2026-08-11 02:45:00 GST',
      );
    });
  });

  group('Pagination and cursor handling', () {
    test('extracts nextCursor and sets hasMore = true when cursor is present',
        () async {
      final page = await repository.fetchAuditLogs();

      expect(page.nextCursor, 'cursor-page-2');
      expect(page.hasMore, isTrue);
      expect(page.canLoadMore, isTrue);
    });

    test('fetches next page using cursor parameter', () async {
      final secondPage =
          await repository.fetchAuditLogs(cursor: 'cursor-page-2');

      expect(secondPage.items, hasLength(1));
      expect(secondPage.items.first.id, 'log-3');
      expect(secondPage.items.first.action, 'SETTINGS_UPDATED');
      expect(secondPage.nextCursor, isNull);
      expect(secondPage.hasMore, isFalse);
      expect(secondPage.canLoadMore, isFalse);
    });
  });

  group('Client-side and parameter filtering', () {
    test('filters by action name', () async {
      final filtered = await repository.fetchAuditLogs(
        filters: const AuditLogFilters(action: 'SUSPENDED'),
      );

      expect(filtered.items, hasLength(1));
      expect(filtered.items.first.id, 'log-2');
      expect(filtered.items.first.action, 'CUSTOMER_SUSPENDED');
    });

    test('filters by entityType', () async {
      final filtered = await repository.fetchAuditLogs(
        filters: const AuditLogFilters(entityType: 'vendor_profile'),
      );

      expect(filtered.items, hasLength(1));
      expect(filtered.items.first.id, 'log-1');
      expect(filtered.items.first.entityType, 'vendor_profile');
    });

    test('filters by actorUserId', () async {
      final filtered = await repository.fetchAuditLogs(
        filters: const AuditLogFilters(actorUserId: 'admin-user-002'),
      );

      expect(filtered.items, hasLength(1));
      expect(filtered.items.first.id, 'log-2');
    });

    test('filters by date range', () async {
      final filtered = await repository.fetchAuditLogs(
        filters: AuditLogFilters(
          from: DateTime.parse('2026-08-10T12:00:00.000Z'),
          to: DateTime.parse('2026-08-10T23:59:59.000Z'),
        ),
      );

      expect(filtered.items, hasLength(1));
      expect(filtered.items.first.id, 'log-2');
    });
  });
}
