import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class MockHttpAdapter implements HttpClientAdapter {
  MockHttpAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object data, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class MemoryTokenStorage implements TokenStorage {
  SessionTokens? _tokens;
  @override
  Future<SessionTokens?> read() async => _tokens;
  @override
  Future<void> save(SessionTokens tokens) async => _tokens = tokens;
  @override
  Future<void> clear() async => _tokens = null;
}

extension ResultUnwrap<T> on Result<T> {
  T unwrap() => (this as Ok<T>).value;
}

void main() {
  late MemoryTokenStorage tokens;
  late ServerClock clock;

  setUp(() {
    tokens = MemoryTokenStorage();
    clock = ServerClock();
  });

  KhApiClient createClient(
      Future<ResponseBody> Function(RequestOptions options) handler) {
    final dio = Dio();
    dio.httpClientAdapter = MockHttpAdapter(handler);
    return KhApiClient(
      baseUrl: 'https://api.test',
      tokenStorage: tokens,
      serverClock: clock,
      dio: dio,
    );
  }

  group('MatchesClient', () {
    test('getMatches parses paginated response with cursor', () async {
      final client = createClient((opts) async {
        expect(opts.path, '/v1/matches');
        expect(opts.queryParameters['limit'], '20');
        expect(opts.queryParameters['sort'], 'NEWEST');
        return jsonBody({
          'data': [
            {
              'id': 'req-1',
              'reference': 'REQ-2026-0001',
              'requestType': 'FIND_ORNAMENT',
              'direction': 'BUY',
              'state': 'PUBLISHED',
              'categoryId': 'cat-ring',
              'category': {'nameEn': 'Rings'},
              'regionId': 'reg-dxb',
              'region': {'nameEn': 'Dubai'},
              'weightGrams': 12.5,
              'purityKarat': '22',
              'budgetMin': 3000.0,
              'budgetMax': 4500.0,
              'notes': 'Bridal ring required',
              'publishedAt': '2026-09-07T00:00:00.000Z',
              'expiresAt': '2026-09-09T00:00:00.000Z',
              'offerCount': 2,
              'customer': {
                'role': 'CUSTOMER',
                'region': {'nameEn': 'Dubai'},
                'rating': {'score': 4.8, 'count': 12},
                'dealCount': 7,
              },
            },
          ],
          'meta': {
            'nextCursor': 'cursor-page-2',
            'hasMore': true,
          },
        });
      });

      final khApi = KhApi(client);
      final res = await khApi.matches.getMatches(sort: 'NEWEST');

      expect(res.isOk, isTrue);
      final paged = res.unwrap();
      expect(paged.items.length, 1);
      expect(paged.nextCursor, 'cursor-page-2');
      expect(paged.hasMore, isTrue);

      final req = paged.items.first;
      expect(req.id, 'req-1');
      expect(req.reference, 'REQ-2026-0001');
      expect(req.requestType, 'FIND_ORNAMENT');
      expect(req.direction, 'BUY');
      expect(req.state, 'PUBLISHED');
      expect(req.categoryId, 'cat-ring');
      expect(req.categoryName, 'Rings');
      expect(req.regionId, 'reg-dxb');
      expect(req.regionName, 'Dubai');
      expect(req.weightGrams, 12.5);
      expect(req.purityKarat, '22');
      expect(req.budgetMin, 3000.0);
      expect(req.budgetMax, 4500.0);
      expect(req.notes, 'Bridal ring required');
      expect(req.offerCount, 2);
      expect(req.customer.isMasked, isTrue);
      expect(req.customer.dealCount, 7);
      // Domain freezed VendorRequestItem.fromJson (no parallel DTO layer).
      expect(req.runtimeType.toString(), contains('VendorRequestItem'));
    });

    test('markViewed calls POST /v1/matches/:id/viewed', () async {
      var called = false;
      final client = createClient((opts) async {
        expect(opts.method, 'POST');
        expect(opts.path, '/v1/matches/req-99/viewed');
        called = true;
        return jsonBody({}, status: 204);
      });

      final khApi = KhApi(client);
      final res = await khApi.matches.markViewed('req-99');
      expect(res.isOk, isTrue);
      expect(called, isTrue);
    });
  });

  group('RequestsClient', () {
    test('getRequest fetches single request item', () async {
      final client = createClient((opts) async {
        expect(opts.path, '/v1/requests/req-detail-1');
        return jsonBody({
          'data': {
            'id': 'req-detail-1',
            'requestType': 'CUSTOM_DESIGN',
            'direction': 'BUY',
            'state': 'PUBLISHED',
            'categoryId': 'cat-necklace',
            'regionId': 'reg-dxb',
            'weightGrams': 35.0,
            'purityKarat': '18',
            'customer': {
              'role': 'CUSTOMER',
              'rating': {'score': 5.0, 'count': 3},
            },
            'media': [
              {
                'id': 'm-1',
                'key': 'req-images/1.jpg',
                'contentType': 'image/jpeg',
                'displayOrder': 0,
              },
            ],
          },
        });
      });

      final khApi = KhApi(client);
      final res = await khApi.requests.getRequest('req-detail-1');
      expect(res.isOk, isTrue);
      final item = res.unwrap();
      expect(item.id, 'req-detail-1');
      expect(item.requestType, 'CUSTOM_DESIGN');
      expect(item.media.length, 1);
      expect(item.media.first.key, 'req-images/1.jpg');
    });
  });

  group('FilterPresetsClient', () {
    test('CRUD operations', () async {
      final client = createClient((opts) async {
        if (opts.method == 'GET' && opts.path == '/v1/filter-presets') {
          return jsonBody({
            'data': [
              {
                'id': 'pre-1',
                'name': 'Dubai 22K',
                'filters': {'regionId': 'reg-dxb', 'purityKarat': '22'},
                'createdAt': '2026-09-07T01:00:00.000Z',
              }
            ]
          });
        }
        if (opts.method == 'POST' && opts.path == '/v1/filter-presets') {
          return jsonBody({
            'data': {
              'id': 'pre-2',
              'name': 'Gold Bars',
              'filters': {'requestType': 'BULLION'},
              'createdAt': '2026-09-07T02:00:00.000Z',
            }
          });
        }
        if (opts.method == 'PATCH' && opts.path == '/v1/filter-presets/pre-2') {
          return jsonBody({
            'data': {
              'id': 'pre-2',
              'name': 'Gold Bars High Value',
              'filters': {'requestType': 'BULLION', 'minBudget': 10000},
              'createdAt': '2026-09-07T02:00:00.000Z',
            }
          });
        }
        if (opts.method == 'DELETE' && opts.path == '/v1/filter-presets/pre-2') {
          return jsonBody({}, status: 204);
        }
        throw Exception('Unexpected call: ${opts.method} ${opts.path}');
      });

      final khApi = KhApi(client);
      final listRes = await khApi.filterPresets.list();
      expect(listRes.isOk, isTrue);
      final listed = listRes.unwrap();
      expect(listed.length, 1);
      expect(listed.first.id, 'pre-1');
      expect(listed.first.name, 'Dubai 22K');
      expect(listed.first.filters, {
        'regionId': 'reg-dxb',
        'purityKarat': '22',
      });
      expect(listed.first.createdAt.toUtc().toIso8601String(),
          '2026-09-07T01:00:00.000Z');

      final createRes = await khApi.filterPresets.create(
        name: 'Gold Bars',
        filters: {'requestType': 'BULLION'},
      );
      expect(createRes.isOk, isTrue);
      expect(createRes.unwrap().id, 'pre-2');
      expect(createRes.unwrap().filters['requestType'], 'BULLION');

      final updateRes =
          await khApi.filterPresets.update('pre-2', name: 'Gold Bars High Value');
      expect(updateRes.isOk, isTrue);
      expect(updateRes.unwrap().name, 'Gold Bars High Value');
      expect(updateRes.unwrap().filters['minBudget'], 10000);

      final deleteRes = await khApi.filterPresets.delete('pre-2');
      expect(deleteRes.isOk, isTrue);
    });
  });

  group('SubscriptionsClient & PlatformConfigClient', () {
    test('getSubscriptions maps via VendorSubscriptionItem.fromJson', () async {
      final client = createClient((opts) async {
        expect(opts.path, '/v1/me/subscriptions');
        return jsonBody({
          'data': [
            {
              'requestType': 'FIND_ORNAMENT',
              'state': 'ACTIVE',
              'priceAed': '499.00',
              'canOffer': true,
            },
            {
              'requestType': 'CUSTOM_DESIGN',
              'state': 'EXPIRED',
              'priceAed': '299.00',
              'canOffer': false,
            },
          ]
        });
      });

      final khApi = KhApi(client);
      final res = await khApi.subscriptions.getSubscriptions();
      expect(res.isOk, isTrue);
      final subs = res.unwrap();
      expect(subs.length, 2);
      expect(subs[0].requestType, 'FIND_ORNAMENT');
      expect(subs[0].priceAed, '499.00');
      expect(subs[0].canOffer, isTrue);
      expect(subs[1].state, 'EXPIRED');
      expect(subs[1].canOffer, isFalse);
    });

    test('platformConfig maps via PlatformConfig.fromJson incl. legal flatten',
        () async {
      final client = createClient((opts) async {
        expect(opts.path, '/v1/platform-config');
        return jsonBody({
          'requestLifetimeHours': 48,
          'offerValidityHours': [12, 24, 48],
          'defaultOfferValidityHours': 24,
          'bullionMinimumAed': '5000',
          'maxConcurrentLiveRequests': 3,
          'maxOfferRevisions': 3,
          'requestExpiryWarningHours': 6,
          'karatList': ['18', '21', '22', '24'],
          'supportContactUrl': 'https://karathive.ae/support',
          'subscriptionContactUrl': 'https://karathive.ae/subscriptions',
          'legal': {
            'termsUrl': 'https://karathive.ae/terms',
            'privacyUrl': 'https://karathive.ae/privacy',
          },
        });
      });

      final khApi = KhApi(client);
      final res = await khApi.platformConfig.getConfig();
      expect(res.isOk, isTrue);
      final cfg = res.unwrap();
      expect(cfg.requestLifetimeHours, 48);
      expect(cfg.offerValidityHours, [12, 24, 48]);
      expect(cfg.defaultOfferValidityHours, 24);
      expect(cfg.bullionMinimumAed, '5000');
      expect(cfg.karatList, ['18', '21', '22', '24']);
      expect(cfg.subscriptionContactUrl, 'https://karathive.ae/subscriptions');
      expect(cfg.termsUrl, 'https://karathive.ae/terms');
      expect(cfg.privacyUrl, 'https://karathive.ae/privacy');
    });
  });

  group('PerformanceClient', () {
    Map<String, dynamic> performanceBody() => {
          'offersSubmitted': 12,
          'acceptanceRate': '0.25',
          'averageResponseMinutes': 45,
          'byOutcome': [
            {'state': 'PENDING', 'count': 3},
            {'state': 'ACCEPTED', 'count': 3},
            {'state': 'REJECTED', 'count': 2},
            {'state': 'EXPIRED', 'count': 2},
            {'state': 'WITHDRAWN', 'count': 1},
            {'state': 'WITHDRAWN_BY_SYSTEM', 'count': 1},
          ],
          'ratingTrend': [
            for (var i = 1; i <= 6; i++)
              {
                'period': '2026-0$i',
                'average': i == 6 ? 4.5 : 0,
                'count': i == 6 ? 2 : 0,
              },
          ],
        };

    test('getPerformance parses aggregates, ratingTrend, filters', () async {
      Map<String, dynamic>? query;
      final client = createClient((opts) async {
        expect(opts.method, 'GET');
        expect(opts.path, '/v1/me/vendor/performance');
        query = Map<String, dynamic>.from(opts.queryParameters);
        return jsonBody({'data': performanceBody()});
      });

      final res = await KhApi(client).performance.getPerformance(
        from: DateTime.utc(2026, 1, 1),
        to: DateTime.utc(2026, 6, 30, 23, 59, 59),
        requestType: 'FIND_ORNAMENT',
        categoryId: '11111111-1111-1111-1111-111111111111',
        regionId: '22222222-2222-2222-2222-222222222222',
      );
      expect(res.isOk, isTrue);
      final perf = res.unwrap();
      expect(perf.offersSubmitted, 12);
      expect(perf.acceptanceRate, '0.25');
      expect(perf.averageResponseMinutes, 45);
      expect(perf.byOutcome.length, 6);
      expect(perf.byOutcome.first.state, 'PENDING');
      expect(perf.ratingTrend.length, 6);
      expect(perf.ratingTrend.last.period, '2026-06');
      expect(perf.ratingTrend.last.average, 4.5);
      expect(perf.ratingTrend.last.count, 2);
      expect(query!['from'], '2026-01-01T00:00:00.000Z');
      expect(query!['to'], '2026-06-30T23:59:59.000Z');
      expect(query!['requestType'], 'FIND_ORNAMENT');
      expect(query!['categoryId'], '11111111-1111-1111-1111-111111111111');
      expect(query!['regionId'], '22222222-2222-2222-2222-222222222222');
    });

    test('getPerformance tolerates nested data envelope', () async {
      final client = createClient((opts) async {
        return jsonBody({
          'data': {'data': performanceBody()},
        });
      });

      final perf =
          (await KhApi(client).performance.getPerformance()).unwrap();
      expect(perf.offersSubmitted, 12);
      expect(perf.ratingTrend.length, 6);
    });

    test('exportPerformance returns signed downloadUrl + expiresAt', () async {
      Map<String, dynamic>? query;
      final client = createClient((opts) async {
        expect(opts.method, 'GET');
        expect(opts.path, '/v1/me/vendor/performance/export');
        query = Map<String, dynamic>.from(opts.queryParameters);
        return jsonBody({
          'data': {
            'downloadUrl':
                'local://export/vendor/vp-1/performance/abc.csv',
            'expiresAt': '2026-09-08T12:15:00.000Z',
          },
        });
      });

      final res = await KhApi(client).performance.exportPerformance(
        requestType: 'GOLD_COIN',
      );
      expect(res.isOk, isTrue);
      final exp = res.unwrap();
      expect(exp.downloadUrl,
          'local://export/vendor/vp-1/performance/abc.csv');
      expect(exp.expiresAt.toUtc().toIso8601String(),
          '2026-09-08T12:15:00.000Z');
      expect(query!['requestType'], 'GOLD_COIN');
      expect(query!.containsKey('from'), isFalse);
    });
  });

  group('AuthClient sessions + password', () {
    test('listSessions parses SessionFamilyView items', () async {
      final client = createClient((opts) async {
        expect(opts.method, 'GET');
        expect(opts.path, '/v1/auth/sessions');
        return jsonBody({
          'data': [
            {
              'id': '11111111-1111-1111-1111-111111111111',
              'deviceLabel': 'KaratHive/1.0 (iPhone)',
              'lastIp': '203.0.113.10',
              'lastUsedAt': '2026-09-08T10:00:00.000Z',
              'createdAt': '2026-09-01T08:00:00.000Z',
            },
            {
              'id': '22222222-2222-2222-2222-222222222222',
              'deviceLabel': null,
              'lastIp': null,
              'lastUsedAt': '2026-09-07T12:00:00.000Z',
              'createdAt': '2026-09-07T12:00:00.000Z',
            },
          ],
        });
      });

      final res = await KhApi(client).auth.listSessions();
      expect(res.isOk, isTrue);
      final sessions = res.unwrap();
      expect(sessions.length, 2);
      expect(sessions.first.id, '11111111-1111-1111-1111-111111111111');
      expect(sessions.first.deviceLabel, 'KaratHive/1.0 (iPhone)');
      expect(sessions.first.lastIp, '203.0.113.10');
      expect(sessions.first.lastUsedAt.toUtc().toIso8601String(),
          '2026-09-08T10:00:00.000Z');
      expect(sessions.first.createdAt.toUtc().toIso8601String(),
          '2026-09-01T08:00:00.000Z');
      expect(sessions[1].deviceLabel, isNull);
      expect(sessions[1].lastIp, isNull);
    });

    test('revokeSession DELETE /v1/auth/sessions/{id}', () async {
      final client = createClient((opts) async {
        expect(opts.method, 'DELETE');
        expect(opts.path,
            '/v1/auth/sessions/11111111-1111-1111-1111-111111111111');
        return jsonBody({}, status: 204);
      });

      final res = await KhApi(client)
          .auth
          .revokeSession('11111111-1111-1111-1111-111111111111');
      expect(res.isOk, isTrue);
    });

    test('setPassword POST /v1/auth/password with optional currentPassword',
        () async {
      Map<String, dynamic>? body;
      final client = createClient((opts) async {
        expect(opts.method, 'POST');
        expect(opts.path, '/v1/auth/password');
        body = Map<String, dynamic>.from(opts.data as Map);
        return jsonBody({}, status: 204);
      });

      final setRes = await KhApi(client).auth.setPassword(
        newPassword: 'CorrectHorseBattery1!',
      );
      expect(setRes.isOk, isTrue);
      expect(body, {'newPassword': 'CorrectHorseBattery1!'});

      final changeRes = await KhApi(client).auth.setPassword(
        currentPassword: 'old-secret',
        newPassword: 'CorrectHorseBattery2!',
      );
      expect(changeRes.isOk, isTrue);
      expect(body, {
        'currentPassword': 'old-secret',
        'newPassword': 'CorrectHorseBattery2!',
      });
    });

    test('setPassword surfaces PASSWORD_POLICY as ValidationFailure', () async {
      final client = createClient((opts) async {
        expect(opts.path, '/v1/auth/password');
        return jsonBody({
          'error': {
            'code': 'PASSWORD_POLICY',
            'message': 'Password does not meet policy',
          },
        }, status: 400);
      });

      final res = await KhApi(client).auth.setPassword(newPassword: 'short');
      expect(res.isOk, isFalse);
      final err = (res as Err).failure;
      expect(err, isA<ValidationFailure>());
      expect((err as ValidationFailure).code, 'PASSWORD_POLICY');
    });
  });

  group('KhApi aggregate', () {
    test('exposes CP2-B01 clients as properties', () {
      final client = createClient((_) async => jsonBody({}));
      final khApi = KhApi(client);
      expect(khApi.matches, isA<MatchesClient>());
      expect(khApi.requests, isA<RequestsClient>());
      expect(khApi.filterPresets, isA<FilterPresetsClient>());
      expect(khApi.subscriptions, isA<SubscriptionsClient>());
      expect(khApi.platformConfig, isA<PlatformConfigClient>());
      expect(khApi.connections, isA<ConnectionsClient>());
      expect(khApi.auth, isA<AuthClient>());
      expect(khApi.performance, isA<PerformanceClient>());
      expect(khApi.dashboardClient, isA<DashboardClient>());
    });
  });

  group('ConnectionsClient', () {
    Map<String, dynamic> vendorConnectionJson() => {
          'id': 'conn-1',
          'offerId': 'off-1',
          'requestId': 'req-1',
          'state': 'ACTIVE',
          'identityRevealedAt': '2026-09-01T12:00:00.000Z',
          'customer': {
            'id': 'cp-1',
            'displayName': 'Fatima Al Zahra',
            'phone': '+971501234567',
            'connectionCount': 2,
          },
          'talk': {
            'available': true,
            'waUrl': 'https://wa.me/971501234567?text=Hello',
            'phone': '+971501234567',
            'callUrl': 'tel:+971501234567',
          },
          'request': {
            'id': 'req-1',
            'reference': 'KH-RQ-24A1',
            'requestType': 'FIND_ORNAMENT',
            'direction': 'BUY',
          },
          'offer': {
            'id': 'off-1',
            'offeredPrice': '12500.00',
            'validityHours': 24,
          },
        };

    test('listMine parses vendor connections and talk.waUrl', () async {
      final client = createClient((opts) async {
        expect(opts.path, '/v1/me/connections');
        expect(opts.queryParameters['limit'], '20');
        return jsonBody({
          'data': [vendorConnectionJson()],
          'meta': {'nextCursor': 'c2'},
        });
      });

      final khApi = KhApi(client);
      final res = await khApi.connections.listMine();
      expect(res.isOk, isTrue);
      final page = res.unwrap();
      expect(page.items, hasLength(1));
      expect(page.items.first.customer.displayName, 'Fatima Al Zahra');
      expect(page.items.first.talk.waUrl, startsWith('https://wa.me/'));
      expect(page.nextCursor, 'c2');
    });

    test('get / close / contact-events hit inventory paths', () async {
      String? lastPath;
      String? lastMethod;
      Object? lastBody;
      final client = createClient((opts) async {
        lastPath = opts.path;
        lastMethod = opts.method;
        lastBody = opts.data;
        if (opts.path.endsWith('/contact-events')) {
          return jsonBody({'data': {'success': true}}, status: 201);
        }
        return jsonBody({'data': vendorConnectionJson()});
      });

      final khApi = KhApi(client);
      final got = await khApi.connections.get('conn-1');
      expect(got.isOk, isTrue);
      expect(lastMethod, 'GET');
      expect(lastPath, '/v1/connections/conn-1');

      final closed = await khApi.connections.close('conn-1');
      expect(closed.isOk, isTrue);
      expect(lastMethod, 'POST');
      expect(lastPath, '/v1/connections/conn-1/close');

      final event = await khApi.connections.recordContactEvent(
        connectionId: 'conn-1',
        channel: 'WHATSAPP',
      );
      expect(event.isOk, isTrue);
      expect(lastMethod, 'POST');
      expect(lastPath, '/v1/connections/conn-1/contact-events');
      expect(lastBody, {'channel': 'WHATSAPP'});
    });
  });

  group('ReviewsClient', () {
    Map<String, dynamic> reviewJson({
      String id = 'rev-1',
      String state = 'PUBLISHED',
      Map<String, dynamic>? vendorResponse,
    }) =>
        {
          'id': id,
          'connectionId': 'conn-1',
          'authorType': 'CUSTOMER',
          'authorDisplayName': 'Fatima',
          'rating': 5,
          'comment': 'Great service',
          'state': state,
          if (vendorResponse != null) 'vendorResponse': vendorResponse,
          'editableUntil': '2026-09-21T00:00:00.000Z',
          'createdAt': '2026-09-07T00:00:00.000Z',
          'publishedAt': '2026-09-08T00:00:00.000Z',
        };

    test('list hits GET /v1/me/reviews and parses page', () async {
      final client = createClient((opts) async {
        expect(opts.method, 'GET');
        expect(opts.path, '/v1/me/reviews');
        expect(opts.queryParameters['role'], 'SUBJECT');
        expect(opts.queryParameters['limit'], '20');
        return jsonBody({
          'data': [reviewJson()],
          'meta': {'nextCursor': 'c2'},
        });
      });

      final page = (await KhApi(client).reviews.list(role: 'SUBJECT')).unwrap();
      expect(page.items, hasLength(1));
      expect(page.items.first.id, 'rev-1');
      expect(page.items.first.rating, 5);
      expect(page.items.first.authorDisplayName, 'Fatima');
      expect(page.nextCursor, 'c2');
    });

    test('respond posts body.response and returns Review', () async {
      Object? lastBody;
      final client = createClient((opts) async {
        expect(opts.method, 'POST');
        expect(opts.path, '/v1/reviews/rev-1/response');
        lastBody = opts.data;
        return jsonBody({
          'data': reviewJson(vendorResponse: {
            'text': 'Thank you',
            'state': 'PENDING_MODERATION',
          }),
        });
      });

      final review =
          (await KhApi(client).reviews.respond('rev-1', response: 'Thank you'))
              .unwrap();
      expect(lastBody, {'response': 'Thank you'});
      expect(review.vendorResponse?.text, 'Thank you');
      expect(review.vendorResponse?.state, ReviewState.pendingModeration);
    });

    test('flag hits POST /v1/reviews/{id}/flag', () async {
      final client = createClient((opts) async {
        expect(opts.method, 'POST');
        expect(opts.path, '/v1/reviews/rev-1/flag');
        return jsonBody({
          'data': {'flagged': true},
        });
      });

      final res = await KhApi(client).reviews.flag('rev-1');
      expect(res.isOk, isTrue);
    });
  });

  group('VendorClient.patchProfile', () {
    test('PATCHes /v1/me/vendor with safe fields only when legal omitted', () async {
      Object? lastBody;
      final client = createClient((opts) async {
        expect(opts.method, 'PATCH');
        expect(opts.path, '/v1/me/vendor');
        lastBody = opts.data;
        return jsonBody({
          'data': {
            'vendorProfileId': 'vp1',
            'lifecycle': 'ACTIVE',
            'awaitingApproval': false,
            'tradingName': 'Al Noor Gold',
            'legalBusinessName': 'Al Noor LLC',
            'tradeLicenceNumber': 'TL-1',
            'licenceExpiryDate': '2027-01-01',
            'businessAddress': 'Deira',
            'contactPersonName': 'Sara',
            'businessEmail': 'sara@example.com',
            'description': 'Showroom',
            'categoryCount': 1,
            'regionCount': 1,
            'categoryIds': <String>[],
            'regionIds': <String>[],
            'awayMode': false,
          },
        });
      });

      final me = (await KhApi(client).patchVendorProfile(
        tradingName: 'Al Noor Gold',
        description: 'Showroom',
        contactPersonName: 'Sara',
        businessEmail: 'sara@example.com',
      ))
          .unwrap();

      expect(lastBody, {
        'tradingName': 'Al Noor Gold',
        'description': 'Showroom',
        'contactPersonName': 'Sara',
        'businessEmail': 'sara@example.com',
      });
      expect(me.tradingName, 'Al Noor Gold');
      expect(me.description, 'Showroom');
      expect(me.contactPersonName, 'Sara');
      expect(me.businessEmail, 'sara@example.com');
    });
  });
}
