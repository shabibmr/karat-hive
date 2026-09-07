import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';

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
}
