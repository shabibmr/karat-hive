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

  Map<String, dynamic> maskedVendorJson({
    String label = 'Vendor · Deira',
    int connectionCount = 8,
  }) =>
      {
        'label': label,
        'region': {'id': 'r-dxb', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
        'connectionCount': connectionCount,
        'rating': {'average': '4.5', 'count': 8, 'limitedHistory': false},
      };

  Map<String, dynamic> customerOfferJson({
    String id = 'off-1',
    String requestId = 'req-1',
    String state = 'PENDING',
    String price = '12500.00',
    String? viewedByCustomerAt,
    bool includeViewedKey = false,
  }) =>
      {
        'id': id,
        'requestId': requestId,
        'state': state,
        'terms': {
          'offeredPrice': price,
          'makingCharges': '200.00',
          'validityHours': 24,
          'vendorNote': 'Hallmarked 22K',
        },
        'vendor': maskedVendorJson(),
        'submittedAt': '2026-09-01T11:00:00.000Z',
        'expiresAt': '2026-09-02T11:00:00.000Z',
        'revisionCount': 0,
        if (includeViewedKey || viewedByCustomerAt != null)
          'viewedByCustomerAt': viewedByCustomerAt,
      };

  Map<String, dynamic> customerConnectionJson({
    String id = 'conn-1',
  }) =>
      {
        'id': id,
        'state': 'ACTIVE',
        'offerId': 'off-1',
        'requestId': 'req-1',
        'identityRevealedAt': '2026-09-08T10:00:00.000Z',
        'vendor': {
          'id': 'v-1',
          'legalBusinessName': 'Al Romaizan Gold LLC',
          'tradingName': 'Al Romaizan',
          'tradeLicenceNumber': 'TL-12345',
          'phone': '+971501234567',
          'connectionCount': 15,
          'rating': {'average': '4.9', 'count': 22, 'limitedHistory': false},
          'region': {'id': 'r-dxb', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
        },
        'talk': {
          'available': true,
          'waUrl': 'https://wa.me/971501234567?text=Karat%20Hive%20Request',
          'mobileNumber': '+971501234567',
          'callUrl': 'tel:+971501234567',
          'prefilledMessage': 'Karat Hive Request',
        },
        'request': {
          'id': 'req-1',
          'reference': 'KH-RQ-2026-001',
          'requestType': 'FIND_ORNAMENT',
          'direction': 'BUY',
          'category': {'id': 'c-bangles', 'nameEn': 'Bangles', 'nameAr': 'أساور'},
          'region': {'id': 'r-dxb', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
        },
        'acceptedOffer': {
          'id': 'off-1',
          'terms': {
            'offeredPrice': '12500.00',
            'makingCharges': '200.00',
            'validityHours': 24,
          },
          'submittedAt': '2026-09-01T11:00:00.000Z',
        },
      };

  group('CM-S08: Customer Offers (CUS-S11..S14)', () {
    test('offersForRequest maps list to OfferForCustomer (masked vendor)', () async {
      payload = {
        'data': [customerOfferJson()],
        'meta': {'nextCursor': 'c-next', 'hasMore': true},
      };

      final res = await api.offersForRequest(
        'req-1',
        sort: 'PRICE_ASC',
        minRating: '4',
        priceMin: '1000',
        priceMax: '20000',
        limit: 10,
        cursor: 'c-prev',
      );

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/requests/req-1/offers');
      expect(lastRequest!.queryParameters, {
        'limit': '10',
        'cursor': 'c-prev',
        'sort': 'PRICE_ASC',
        'minRating': '4',
        'priceMin': '1000',
        'priceMax': '20000',
      });

      expect(res.isOk, isTrue);
      final paged = (res as Ok<PagedResult<OfferForCustomer>>).value;
      expect(paged.items, hasLength(1));
      expect(paged.nextCursor, 'c-next');
      expect(paged.hasMore, isTrue);

      final offer = paged.items.first;
      expect(offer.id, 'off-1');
      expect(offer.state, OfferState.pending);
      expect(offer.terms.offeredPrice, '12500.00');
      expect(offer.vendor, isA<MaskedParty>());
      expect(offer.vendor.role, PartyRole.vendor);
      expect(offer.vendor.pseudonym, 'Vendor · Deira');
      expect(offer.viewedByCustomerAtPresent, isFalse);
    });

    test('offers.listForRequest matches facade offersForRequest', () async {
      payload = {
        'data': [customerOfferJson(id: 'off-2')],
        'meta': {'hasMore': false},
      };

      final viaClient = await api.offers.listForRequest('req-1');
      expect(viaClient.isOk, isTrue);
      expect(
        (viaClient as Ok<PagedResult<OfferForCustomer>>).value.items.single.id,
        'off-2',
      );
    });

    test('getCustomerOffer maps GET /v1/offers/{id}', () async {
      payload = {
        'data': customerOfferJson(
          viewedByCustomerAt: '2026-09-01T12:00:00.000Z',
          includeViewedKey: true,
        ),
      };

      final res = await api.getCustomerOffer('off-1');

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/offers/off-1');
      expect(res.isOk, isTrue);
      final offer = (res as Ok<OfferForCustomer>).value;
      expect(offer.viewedByCustomerAtPresent, isTrue);
      expect(offer.viewedByCustomerAt?.toUtc().toIso8601String(),
          '2026-09-01T12:00:00.000Z');
    });

    test('offerVendorRating maps VendorRatingDetail without identity', () async {
      payload = {
        'data': {
          'summary': {
            'average': '4.7',
            'count': 12,
            'limitedHistory': false,
            'distribution': {'5': 8, '4': 3, '3': 1},
          },
          'excerpts': [
            {
              'abbreviatedName': 'F***a',
              'rating': 5,
              'comment': 'Fair price',
            },
          ],
        },
      };

      final res = await api.offerVendorRating('off-1');

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/offers/off-1/vendor-rating');
      expect(res.isOk, isTrue);
      final detail = (res as Ok<VendorRatingDetail>).value;
      expect(detail.summary.average, 4.7);
      expect(detail.summary.count, 12);
      expect(detail.excerpts, hasLength(1));
      expect(detail.excerpts.first.abbreviatedName, 'F***a');
    });

    test('acceptOffer sends REVEAL_AND_CONNECT and returns AcceptOfferResult',
        () async {
      payload = {
        'data': {
          'offer': customerOfferJson(state: 'ACCEPTED'),
          'connection': customerConnectionJson(),
        },
      };

      final res = await api.acceptOffer('off-1');

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/offers/off-1/accept');
      expect(lastBody, {'confirmation': 'REVEAL_AND_CONNECT'});

      expect(res.isOk, isTrue);
      final accepted = (res as Ok<AcceptOfferResult>).value;
      expect(accepted.offer.state, OfferState.accepted);
      expect(accepted.connection.id, 'conn-1');
      expect(accepted.connection.vendor.displayName, 'Al Romaizan');
      expect(accepted.connection.talk.waUrl, startsWith('https://wa.me/'));
    });

    test('offers.accept body is identical to facade acceptOffer', () async {
      payload = {
        'data': {
          'offer': customerOfferJson(state: 'ACCEPTED'),
          'connection': customerConnectionJson(id: 'conn-2'),
        },
      };

      final res = await api.offers.accept('off-9');
      expect(lastBody, {'confirmation': 'REVEAL_AND_CONNECT'});
      expect(res.isOk, isTrue);
      expect(
        (res as Ok<AcceptOfferResult>).value.connection.id,
        'conn-2',
      );
    });

    test('declineOffer returns OfferForCustomer REJECTED', () async {
      payload = {
        'data': customerOfferJson(state: 'REJECTED'),
      };

      final res = await api.declineOffer(
        'off-1',
        reason: 'PRICE_TOO_HIGH',
        note: 'Over budget',
      );

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/offers/off-1/decline');
      expect(lastBody, {
        'reason': 'PRICE_TOO_HIGH',
        'note': 'Over budget',
      });

      expect(res.isOk, isTrue);
      final offer = (res as Ok<OfferForCustomer>).value;
      expect(offer.state, OfferState.rejected);
      expect(offer.vendor, isA<MaskedParty>());
    });

    test('masked offer fixture has no identity keys on vendor', () {
      final offer = OfferForCustomer.fromJson(customerOfferJson());
      expect(offer.vendor, isA<MaskedParty>());
      // MaskedParty has no name/mobile getters — only pseudonym / region / rating.
      expect(offer.vendor.pseudonym, isNot(contains('Romaizan')));
      final vendorMap = maskedVendorJson();
      expect(vendorMap.containsKey('phone'), isFalse);
      expect(vendorMap.containsKey('tradingName'), isFalse);
      expect(vendorMap.containsKey('legalBusinessName'), isFalse);
      expect(vendorMap.containsKey('displayName'), isFalse);
    });
  });
}
