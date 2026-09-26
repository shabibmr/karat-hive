import 'package:dio/dio.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  late Dio dio;
  late KhApi api;
  late RequestOptions? lastRequest;
  late Object? lastBody;
  late int status;
  late Object? payload;

  setUp(() {
    lastRequest = null;
    lastBody = null;
    status = 200;
    payload = <String, dynamic>{};
    dio = Dio(BaseOptions(baseUrl: 'http://kh.test'));
    final client = KhApiClient(
      baseUrl: 'http://kh.test',
      tokenStorage: TokenStorage(),
      serverClock: ServerClock(),
      dio: dio,
      tokenGetter: () async => 'test-token',
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequest = options;
          lastBody = options.data;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: status,
              data: payload,
            ),
          );
        },
      ),
    );
    api = KhApi(client);
  });

  Map<String, dynamic> customerConnectionJson({
    String id = 'conn-c1',
    String state = 'ACTIVE',
    String? closedAt,
    String? closedBy,
    String mobile = '+971501234567',
    String waUrl = 'https://wa.me/971501234567?text=Karat%20Hive%20Request',
    String callUrl = 'tel:+971501234567',
    bool talkAvailable = true,
  }) =>
      {
        'id': id,
        'state': state,
        'offerId': 'off-1',
        'requestId': 'req-1',
        'identityRevealedAt': '2026-09-08T10:00:00.000Z',
        if (closedAt != null) 'closedAt': closedAt,
        if (closedBy != null) 'closedBy': closedBy,
        'vendor': {
          'id': 'v-1',
          'legalBusinessName': 'Al Romaizan Gold LLC',
          'tradingName': 'Al Romaizan',
          'tradeLicenceNumber': 'TL-12345',
          'phone': mobile,
          'connectionCount': 15,
          'rating': {'average': '4.9', 'count': 22, 'limitedHistory': false},
          'region': {'id': 'r-dxb', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
        },
        'talk': {
          'available': talkAvailable,
          'waUrl': waUrl,
          'mobileNumber': mobile,
          'callUrl': callUrl,
          'prefilledMessage': 'Karat Hive Request',
        },
        'request': {
          'id': 'req-1',
          'reference': 'KH-RQ-2026-001',
          'requestType': 'FIND_ORNAMENT',
          'direction': 'BUY',
          'region': {'id': 'r-dxb', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
        },
        'acceptedOffer': {
          'id': 'off-1',
          'terms': {
            'offeredPrice': '8500.00',
            'makingCharges': '150.00',
            'validityHours': 24,
            'vendorNote': 'Includes certificate',
          },
          'submittedAt': '2026-09-08T09:00:00.000Z',
        },
      };

  Map<String, dynamic> reviewJson({
    String id = 'rev-1',
    String connectionId = 'conn-c1',
    String authorType = 'CUSTOMER',
    int rating = 5,
    String? comment = 'Prompt delivery and authentic gold.',
    String state = 'PENDING_MODERATION',
    Map<String, dynamic>? vendorResponse,
  }) =>
      {
        'id': id,
        'connectionId': connectionId,
        'authorType': authorType,
        'authorDisplayName': 'Fatima',
        'rating': rating,
        if (comment != null) 'comment': comment,
        'state': state,
        if (vendorResponse != null) 'vendorResponse': vendorResponse,
        'editableUntil': '2026-09-22T10:00:00.000Z',
        'createdAt': '2026-09-08T12:00:00.000Z',
        'publishedAt': '2026-09-09T08:00:00.000Z',
      };

  Map<String, dynamic> notificationJson({
    String id = 'ntf-1',
    String type = 'offer.accepted',
    String title = 'Offer Accepted',
    String body = 'Your offer on KH-RQ-2026-001 was accepted.',
    String deepLink = '/customer/connections/conn-c1',
    bool isCritical = false,
    String? readAt,
  }) =>
      {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'deepLink': deepLink,
        'isCritical': isCritical,
        'readAt': readAt,
        'createdAt': '2026-09-08T10:05:00.000Z',
      };

  Map<String, dynamic> abuseReportJson({
    String id = 'rpt-1',
    String state = 'OPEN',
    bool acknowledged = true,
  }) =>
      {
        'id': id,
        'state': state,
        'acknowledged': acknowledged,
      };

  group('CM-S09: Customer Connections (CUS-S15, CUS-S16)', () {
    test('listMyConnections and connections.listMineForCustomer hit GET /v1/me/connections', () async {
      payload = {
        'data': [customerConnectionJson()],
        'meta': {'nextCursor': 'c-next', 'hasMore': true},
      };

      final res = await api.listMyConnections(state: 'ACTIVE', limit: 10, cursor: 'c-prev');

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/me/connections');
      expect(lastRequest!.queryParameters, {
        'state': 'ACTIVE',
        'limit': '10',
        'cursor': 'c-prev',
      });

      expect(res.isOk, isTrue);
      final paged = (res as Ok<PagedResult<ConnectionForCustomer>>).value;
      expect(paged.items.length, 1);
      expect(paged.nextCursor, 'c-next');
      expect(paged.hasMore, isTrue);

      final conn = paged.items.first;
      expect(conn.id, 'conn-c1');
      expect(conn.state, ConnectionState.active);
      expect(conn.vendor.displayName, 'Al Romaizan');
      expect(conn.vendor.business?.legalBusinessName, 'Al Romaizan Gold LLC');
      expect(conn.vendor.mobile.e164, '+971501234567');
      expect(conn.vendor.business?.tradingName, 'Al Romaizan');
      expect(conn.talk.waUrl, 'https://wa.me/971501234567?text=Karat%20Hive%20Request');
      expect(conn.talk.phoneNumber.e164, '+971501234567');
      expect(conn.talk.phoneNumber.waMeDigits, '971501234567');
      expect(conn.talk.canOpenWhatsApp, isTrue);
      expect(conn.talk.canCall, isTrue);
    });

    test('getConnection and connections.getById hit GET /v1/connections/{id}', () async {
      payload = {'data': customerConnectionJson(id: 'conn-detail')};

      final res = await api.getConnection('conn-detail');

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/connections/conn-detail');
      expect(res.isOk, isTrue);
      final conn = (res as Ok<ConnectionForCustomer>).value;
      expect(conn.id, 'conn-detail');
      expect(conn.request?.reference, 'KH-RQ-2026-001');
      expect(conn.acceptedOffer?.terms.offeredPrice, '8500.00');
    });

    test('closeConnection and connections.closeForCustomer POST to /close with reason', () async {
      payload = {
        'data': customerConnectionJson(
          id: 'conn-detail',
          state: 'CLOSED',
          closedAt: '2026-09-08T15:00:00.000Z',
          closedBy: 'CUSTOMER',
          talkAvailable: false,
        ),
      };

      final res = await api.closeConnection('conn-detail', reason: 'Deal completed at store');

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/connections/conn-detail/close');
      expect(lastBody, {'reason': 'Deal completed at store'});

      expect(res.isOk, isTrue);
      final conn = (res as Ok<ConnectionForCustomer>).value;
      expect(conn.state, ConnectionState.closed);
      expect(conn.closedBy, ClosedBy.customer);
      expect(conn.talk.available, isFalse);
      expect(conn.talk.canOpenWhatsApp, isFalse);
    });

    test('recordContactEvent POSTs channel to /v1/connections/{id}/contact-events', () async {
      payload = {'data': {'id': 'evt-1', 'channel': 'WHATSAPP'}};

      final res = await api.recordContactEvent('conn-detail', channel: 'WHATSAPP');

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/connections/conn-detail/contact-events');
      expect(lastBody, {'channel': 'WHATSAPP'});
      expect(res.isOk, isTrue);
    });

    test('Talk URL is server data and phoneNumber is normalised (BR-006 / Architecture §10.3)', () {
      final conn = ConnectionForCustomer.fromJson(customerConnectionJson(
        mobile: '00971 50 999 8888',
        waUrl: 'https://wa.me/971509998888?text=Hello',
        talkAvailable: true,
      ));

      // waUrl is data directly from payload, not synthesised in widget
      expect(conn.talk.waUrl, 'https://wa.me/971509998888?text=Hello');
      expect(conn.talk.canOpenWhatsApp, isTrue);

      // phoneNumber value object normalises to international wa.me digits
      expect(conn.talk.phoneNumber.e164, '+971509998888');
      expect(conn.talk.phoneNumber.waMeDigits, '971509998888');

      // When waUrl is blank or invalid, widget cannot open WhatsApp
      final noWa = ConnectionForCustomer.fromJson(customerConnectionJson(
        waUrl: '',
        talkAvailable: true,
      ));
      expect(noWa.talk.canOpenWhatsApp, isFalse);
    });
  });

  group('CM-S09: Reviews (CUS-S18)', () {
    test('createReview and reviews.create POST to /v1/connections/{id}/reviews', () async {
      status = 201;
      payload = {'data': reviewJson()};

      final res = await api.createReview(
        'conn-c1',
        rating: 5,
        comment: 'Prompt delivery and authentic gold.',
      );

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/connections/conn-c1/reviews');
      expect(lastBody, {
        'rating': 5,
        'comment': 'Prompt delivery and authentic gold.',
      });

      expect(res.isOk, isTrue);
      final review = (res as Ok<Review>).value;
      expect(review.id, 'rev-1');
      expect(review.rating, 5);
      expect(review.authorType, PartyRole.customer);
      expect(review.state, ReviewState.pendingModeration);
    });

    test('listMyReviews and reviews.list hit GET /v1/me/reviews', () async {
      payload = {
        'data': [reviewJson()],
        'meta': {'nextCursor': null, 'hasMore': false},
      };

      final res = await api.listMyReviews(role: 'AUTHOR', limit: 15, cursor: 'c-rev');

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/me/reviews');
      expect(lastRequest!.queryParameters, {
        'role': 'AUTHOR',
        'limit': '15',
        'cursor': 'c-rev',
      });

      expect(res.isOk, isTrue);
      final paged = (res as Ok<PagedResult<Review>>).value;
      expect(paged.items.length, 1);
      expect(paged.items.first.authorDisplayName, 'Fatima');
    });

    test('updateReview and reviews.patch PATCH to /v1/reviews/{id}', () async {
      payload = {'data': reviewJson(rating: 4, comment: 'Updated review')};

      final res = await api.updateReview('rev-1', rating: 4, comment: 'Updated review');

      expect(lastRequest!.method, 'PATCH');
      expect(lastRequest!.path, '/v1/reviews/rev-1');
      expect(lastBody, {'rating': 4, 'comment': 'Updated review'});
      expect(res.isOk, isTrue);
      expect((res as Ok<Review>).value.rating, 4);
    });

    test('withdrawReview and reviews.withdraw POST to /v1/reviews/{id}/withdraw', () async {
      payload = {'data': reviewJson(state: 'WITHDRAWN')};

      final res = await api.withdrawReview('rev-1');

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/reviews/rev-1/withdraw');
      expect(res.isOk, isTrue);
      expect((res as Ok<Review>).value.state, ReviewState.withdrawn);
    });

    test('respondToReview and reviews.respond POST to /v1/reviews/{id}/response', () async {
      payload = {
        'data': reviewJson(vendorResponse: {
          'text': 'Thank you for choosing us!',
          'state': 'PENDING_MODERATION',
        }),
      };

      final res = await api.respondToReview('rev-1', 'Thank you for choosing us!');

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/reviews/rev-1/response');
      expect(lastBody, {'response': 'Thank you for choosing us!'});
      expect(res.isOk, isTrue);
      expect((res as Ok<Review>).value.vendorResponse?.text, 'Thank you for choosing us!');
    });

    test('flagReview and reviews.flag POST to /v1/reviews/{id}/flag', () async {
      payload = {'data': {'flagged': true}};

      final res = await api.flagReview('rev-1');

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/reviews/rev-1/flag');
      expect(res.isOk, isTrue);
    });
  });

  group('CM-S09: Notifications (CUS-S19)', () {
    test('listNotifications and notifications.list hit GET /v1/notifications', () async {
      payload = {
        'data': [notificationJson()],
        'meta': {'nextCursor': 'n-next', 'hasMore': true},
      };

      final res = await api.listNotifications(unread: true, limit: 10, cursor: 'n-prev');

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/notifications');
      expect(lastRequest!.queryParameters, {
        'unread': 'true',
        'limit': '10',
        'cursor': 'n-prev',
      });

      expect(res.isOk, isTrue);
      final paged = (res as Ok<PagedResult<AppNotification>>).value;
      expect(paged.items.length, 1);
      expect(paged.items.first.title, 'Offer Accepted');
      expect(paged.items.first.deepLink, '/customer/connections/conn-c1');
    });

    test('unreadNotificationCount and notifications.unreadCount hit GET /v1/notifications/unread-count', () async {
      payload = {'count': 4};

      final res = await api.unreadNotificationCount();

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/notifications/unread-count');
      expect(res.isOk, isTrue);
      expect((res as Ok<int>).value, 4);
    });

    test('markNotificationRead and notifications.markRead POST to /read', () async {
      payload = {'data': notificationJson(readAt: '2026-09-08T11:00:00.000Z')};

      final res = await api.markNotificationRead('ntf-1');

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/notifications/ntf-1/read');
      expect(res.isOk, isTrue);
      expect((res as Ok<AppNotification>).value.readAt, isNotNull);
    });

    test('markAllNotificationsRead and notifications.markAllRead POST to /read-all', () async {
      payload = {'success': true};

      final res = await api.markAllNotificationsRead();

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/notifications/read-all');
      expect(res.isOk, isTrue);
    });
  });

  group('CM-S09: Abuse Reports (CUS-S22)', () {
    test('reportAbuse and abuse.submit POST to /v1/abuse-reports with typed entity', () async {
      status = 201;
      payload = {'data': abuseReportJson()};

      final res = await api.reportAbuse(
        entityType: AbuseEntityType.connection,
        entityId: 'conn-c1',
        category: 'OFF_PLATFORM_SOLICITATION',
        description: 'Vendor requested direct cash outside app.',
      );

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/abuse-reports');
      expect(lastBody, {
        'entityType': 'CONNECTION',
        'entityId': 'conn-c1',
        'category': 'OFF_PLATFORM_SOLICITATION',
        'description': 'Vendor requested direct cash outside app.',
      });

      expect(res.isOk, isTrue);
      final report = (res as Ok<AbuseReport>).value;
      expect(report.id, 'rpt-1');
      expect(report.state, AbuseReportState.open);
      expect(report.acknowledged, isTrue);
    });

    test('reportAbuse accepts string wire entity for compatibility', () async {
      status = 201;
      payload = {'data': abuseReportJson(id: 'rpt-2')};

      final res = await api.reportAbuse(
        entityType: 'OFFER',
        entityId: 'off-1',
        category: 'MISLEADING_TERMS',
        description: 'Price mismatch with note.',
      );

      expect(lastRequest!.path, '/v1/abuse-reports');
      expect(lastBody, {
        'entityType': 'OFFER',
        'entityId': 'off-1',
        'category': 'MISLEADING_TERMS',
        'description': 'Price mismatch with note.',
      });
      expect(res.isOk, isTrue);
      expect((res as Ok<AbuseReport>).value.id, 'rpt-2');
    });
  });
}

