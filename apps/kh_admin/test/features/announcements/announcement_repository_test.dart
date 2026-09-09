import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/announcements/model/create_announcement_dto.dart';
import 'package:kh_admin/features/announcements/repository/announcement_repository.dart';

void main() {
  Map<String, dynamic> rawAnnouncementRow({
    required String id,
    String titleEn = 'Eid Holiday Hours',
    String titleAr = 'ساعات عمل العيد',
    String bodyEn = 'Gold Souk will operate on holiday schedule.',
    String bodyAr = 'سوق الذهب سيعمل وفق ساعات العيد.',
    String userType = 'ALL',
    bool inApp = true,
    bool push = true,
    bool email = false,
    bool critical = false,
    String? scheduledFor,
    String? cancelledAt,
    Map<String, dynamic>? dispatchStats,
  }) {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleAr': titleAr,
      'bodyEn': bodyEn,
      'bodyAr': bodyAr,
      'audience': {'userType': userType},
      'channels': {'inApp': inApp, 'push': push, 'email': email},
      'critical': critical,
      'scheduledFor': scheduledFor,
      'cancelledAt': cancelledAt,
      'dispatchStats': dispatchStats,
      'createdBy': {'displayName': 'Super Admin'},
      'createdAt': '2026-09-01T10:00:00.000Z',
      'updatedAt': '2026-09-01T10:00:00.000Z',
    };
  }

  ApiClient buildClient({
    void Function(RequestOptions)? onPostCreate,
    void Function(RequestOptions)? onPostCancel,
  }) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;

          if (path == '/v1/admin/announcements' && options.method == 'GET') {
            final query = options.queryParameters;
            var rows = [
              rawAnnouncementRow(
                id: 'ann-1',
                titleEn: 'Eid Holiday Hours',
                userType: 'ALL',
                scheduledFor: '2026-09-15T10:00:00.000Z',
              ),
              rawAnnouncementRow(
                id: 'ann-2',
                titleEn: 'Vendor Commission Policy',
                userType: 'VENDOR',
                dispatchStats: {'sent': 150, 'delivered': 148, 'opened': 95},
              ),
              rawAnnouncementRow(
                id: 'ann-3',
                titleEn: 'Cancelled Alert',
                cancelledAt: '2026-09-02T12:00:00.000Z',
              ),
            ];

            if (query['status'] != null) {
              final status = query['status'];
              rows = rows.where((r) {
                if (status == 'SCHEDULED') return r['scheduledFor'] != null;
                if (status == 'DISPATCHED') return r['dispatchStats'] != null;
                if (status == 'CANCELLED') return r['cancelledAt'] != null;
                return true;
              }).toList();
            }
            if (query['audienceType'] != null) {
              final aud = query['audienceType'];
              rows = rows.where((r) => (r['audience'] as Map)['userType'] == aud).toList();
            }
            if (query['q'] != null) {
              final q = query['q'].toString().toLowerCase();
              rows = rows
                  .where((r) =>
                      r['titleEn'].toString().toLowerCase().contains(q) ||
                      r['id'].toString().toLowerCase().contains(q))
                  .toList();
            }

            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': rows,
                    'nextCursor': 'ann-3',
                  },
                  'meta': {'nextCursor': 'ann-3'},
                },
              ),
            );
          }

          if (path == '/v1/admin/announcements' && options.method == 'POST') {
            onPostCreate?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'data': rawAnnouncementRow(
                    id: 'ann-new',
                    titleEn: options.data['titleEn']?.toString() ?? '',
                  ),
                },
              ),
            );
          }

          if (path.startsWith('/v1/admin/announcements/') && path.endsWith('/cancel')) {
            onPostCancel?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': rawAnnouncementRow(
                    id: 'ann-1',
                    cancelledAt: '2026-09-08T00:00:00.000Z',
                  ),
                },
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );
    return ApiClient(dio: dio);
  }

  group('AnnouncementRepository', () {
    test('fetches announcements and parses items correctly', () async {
      final client = buildClient();
      final repo = AnnouncementRepository(client);

      final page = await repo.fetchAnnouncements();

      expect(page.items.length, 3);
      final item1 = page.items[0];
      expect(item1.id, 'ann-1');
      expect(item1.titleEn, 'Eid Holiday Hours');
      expect(item1.titleAr, 'ساعات عمل العيد');
      expect(item1.audienceType, AudienceType.all);
      expect(item1.channels.inApp, true);
      expect(item1.channels.push, true);
      expect(item1.channels.email, false);
      expect(item1.status, AnnouncementStatus.scheduled);
      expect(item1.canCancel, true);

      final item2 = page.items[1];
      expect(item2.id, 'ann-2');
      expect(item2.audienceType, AudienceType.vendors);
      expect(item2.status, AnnouncementStatus.dispatched);
      expect(item2.dispatchStats?.sent, 150);
      expect(item2.dispatchStats?.delivered, 148);
      expect(item2.dispatchStats?.opened, 95);
      expect(item2.canCancel, false);

      final item3 = page.items[2];
      expect(item3.id, 'ann-3');
      expect(item3.status, AnnouncementStatus.cancelled);
      expect(item3.canCancel, false);

      expect(page.hasMore, true);
      expect(page.nextCursor, 'ann-3');
    });

    test('filters announcements by query via query parameters', () async {
      final client = buildClient();
      final repo = AnnouncementRepository(client);

      final page = await repo.fetchAnnouncements(
        filters: const AnnouncementFilters(query: 'commission'),
      );

      expect(page.items.length, 1);
      expect(page.items.first.id, 'ann-2');
    });

    test('filters announcements by status via query parameters', () async {
      final client = buildClient();
      final repo = AnnouncementRepository(client);

      final page = await repo.fetchAnnouncements(
        filters: const AnnouncementFilters(status: AnnouncementStatus.scheduled),
      );

      expect(page.items.length, 1);
      expect(page.items.first.id, 'ann-1');
    });

    test('filters announcements by audience type via query parameters', () async {
      final client = buildClient();
      final repo = AnnouncementRepository(client);

      final page = await repo.fetchAnnouncements(
        filters: const AnnouncementFilters(audienceType: AudienceType.vendors),
      );

      expect(page.items.length, 1);
      expect(page.items.first.id, 'ann-2');
    });

    test('creates announcement and sends correct payload', () async {
      RequestOptions? captured;
      final client = buildClient(onPostCreate: (opt) => captured = opt);
      final repo = AnnouncementRepository(client);

      final dto = CreateAnnouncementDto(
        titleEn: 'System Maintenance',
        titleAr: 'صيانة النظام',
        bodyEn: 'Platform downtime scheduled for 2 hours.',
        bodyAr: 'توقف مجدول للمنصة لمدة ساعتين.',
        audience: const {'userType': 'ALL'},
        channels: const {'inApp': true, 'push': false, 'email': true},
        critical: true,
        scheduledFor: DateTime.utc(2026, 9, 20, 2, 0),
      );

      final created = await repo.createAnnouncement(dto);

      expect(captured, isNotNull);
      expect(captured!.path, '/v1/admin/announcements');
      expect(captured!.data['titleEn'], 'System Maintenance');
      expect(captured!.data['critical'], true);
      expect(captured!.data['channels'], {'inApp': true, 'push': false, 'email': true});
      expect(captured!.data['scheduledFor'], '2026-09-20T02:00:00.000Z');
      expect(created.id, 'ann-new');
    });

    test('cancels announcement successfully', () async {
      RequestOptions? captured;
      final client = buildClient(onPostCancel: (opt) => captured = opt);
      final repo = AnnouncementRepository(client);

      final cancelled = await repo.cancelAnnouncement('ann-1');

      expect(captured, isNotNull);
      expect(captured!.path, '/v1/admin/announcements/ann-1/cancel');
      expect(cancelled.id, 'ann-1');
      expect(cancelled.status, AnnouncementStatus.cancelled);
    });
  });
}
