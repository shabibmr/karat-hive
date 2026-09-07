import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

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

  Map<String, dynamic> envelope(Object data) => {
        'data': data,
        'meta': {'serverTime': '2026-09-07T12:00:00.000Z'},
      };

  Map<String, dynamic> meUserJson({
    String userType = 'CUSTOMER',
    Map<String, dynamic>? customer,
    Map<String, dynamic>? vendor,
  }) =>
      {
        'userId': 'u-1',
        'id': 'u-1',
        'userType': userType,
        'accountState': 'ACTIVE',
        'mobileNumber': '+971500000001',
        'preferredLanguage': 'en',
        'email': 'aisha@example.com',
        'oauthBound': true,
        if (customer != null) 'customer': customer,
        if (vendor != null) 'vendor': vendor,
      };

  Map<String, dynamic> sessionJson({Map<String, dynamic>? user}) => {
        'accessToken': 'at',
        'refreshToken': 'rt',
        'accessExpiresAt': '2026-09-07T12:15:00.000Z',
        'refreshExpiresAt': '2026-10-07T12:00:00.000Z',
        'user': user ?? meUserJson(customer: _customerJson),
      };

  group('registerCustomer', () {
    test('POSTs /v1/auth/register/customer and maps SessionBundle', () async {
      status = 201;
      payload = envelope(sessionJson());

      final result = await api.registerCustomer(
        firebaseToken: 'google-id-token',
        displayName: 'Aisha',
        preferredLanguage: 'ar',
        defaultRegionId: 'reg-1',
        email: 'aisha@example.com',
        termsVersion: '1.0',
        privacyVersion: '1.0',
      );

      expect(lastRequest!.method, 'POST');
      expect(lastRequest!.path, '/v1/auth/register/customer');
      expect(lastBody, {
        'firebaseToken': 'google-id-token',
        'displayName': 'Aisha',
        'preferredLanguage': 'ar',
        'defaultRegionId': 'reg-1',
        'email': 'aisha@example.com',
        'termsVersion': '1.0',
        'privacyVersion': '1.0',
      });
      expect(result, isA<Ok<SessionBundle>>());
      final bundle = (result as Ok<SessionBundle>).value;
      expect(bundle.tokens.accessToken, 'at');
      expect(bundle.user.userType, 'CUSTOMER');
    });

    test('returns Failure on MOBILE_ALREADY_REGISTERED', () async {
      status = 409;
      payload = {
        'error': {
          'code': 'MOBILE_ALREADY_REGISTERED',
          'message': 'This mobile is already registered.',
        },
      };

      final result = await api.registerCustomer(
        challengeId: 'c-1',
        displayName: 'Aisha',
        preferredLanguage: 'en',
        termsVersion: '1.0',
        privacyVersion: '1.0',
      );

      expect(result, isA<Err<SessionBundle>>());
      final failure = (result as Err<SessionBundle>).failure;
      expect(failure, isA<ConflictFailure>());
      expect(failure.code, 'MOBILE_ALREADY_REGISTERED');
    });
  });

  group('GET/PATCH /v1/me', () {
    test('GET /v1/me maps Customer JSON through MeUser.fromJson', () async {
      payload = envelope(meUserJson(customer: _customerJson));

      final result = await api.me();

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/me');
      expect(result, isA<Ok<MeUser>>());
      final me = (result as Ok<MeUser>).value;
      expect(me.userType, 'CUSTOMER');
      expect(me.userId, 'u-1');
      expect(me.email, 'aisha@example.com');
      expect(me.customer, isNotNull);
      expect(me.customer!.displayName, 'Aisha');
      expect(me.customer!.canCreateRequest, isTrue);
      expect(me.oauthBound, isTrue);
    });

    test('PATCH /v1/me sends Customer fields and maps MeUser', () async {
      payload = envelope(meUserJson(customer: {
        ..._customerJson,
        'displayName': 'Aisha K',
      }));

      final result = await api.patchMe(
        displayName: 'Aisha K',
        email: 'new@example.com',
        preferredLanguage: 'ar',
        defaultRegionId: 'reg-2',
        photoMediaKey: 'media-1',
      );

      expect(lastRequest!.method, 'PATCH');
      expect(lastRequest!.path, '/v1/me');
      expect(lastBody, {
        'displayName': 'Aisha K',
        'email': 'new@example.com',
        'preferredLanguage': 'ar',
        'defaultRegionId': 'reg-2',
        'photoMediaKey': 'media-1',
      });
      expect(result, isA<Ok<MeUser>>());
      expect((result as Ok<MeUser>).value.preferredLanguage, 'en');
    });

    test('GET /v1/me still maps Vendor branch', () async {
      payload = envelope(meUserJson(
        userType: 'VENDOR',
        vendor: {
          'vendorProfileId': 'vp-1',
          'lifecycle': 'ACTIVE',
          'awaitingApproval': false,
          'tradingName': 'Al Noor',
          'legalBusinessName': 'Al Noor LLC',
          'categoryCount': 2,
          'regionCount': 1,
        },
      ));

      final result = await api.me();
      final me = (result as Ok<MeUser>).value;
      expect(me.userType, 'VENDOR');
      expect(me.vendor, isNotNull);
      expect(me.vendor!.tradingName, 'Al Noor');
    });
  });

  group('platform-config and gold-rates', () {
    test('GET /v1/platform-config maps PlatformConfig', () async {
      payload = envelope({
        'requestLifetimeHours': 48,
        'offerValidityHours': [12, 24, 48],
        'defaultOfferValidityHours': 24,
        'bullionMinimumAed': '500.00',
        'maxConcurrentLiveRequests': 10,
        'maxRequestImages': 5,
        'maxOfferImages': 3,
        'maxImageBytes': 5242880,
        'acceptedImageTypes': ['image/jpeg', 'image/png'],
        'karatList': ['24K', '22K'],
        'maxOfferRevisions': 3,
        'requestExpiryWarningHours': 6,
        'termsUrl': 'https://karathive.ae/legal/terms',
        'privacyUrl': 'https://karathive.ae/legal/privacy',
        'supportContactUrl': 'https://karathive.ae/support',
        'subscriptionContactUrl': 'https://karathive.ae/subscriptions',
      });

      final result = await api.platformConfig();

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/platform-config');
      expect(result, isA<Ok<PlatformConfig>>());
      final cfg = (result as Ok<PlatformConfig>).value;
      expect(cfg.maxConcurrentLiveRequests, 10);
      expect(cfg.requestLifetimeHours, 48);
      expect(cfg.termsUrl, 'https://karathive.ae/legal/terms');
    });

    test('GET /v1/gold-rates maps available/stale snapshot', () async {
      payload = envelope({
        'available': true,
        'stale': false,
        'source': 'FEED',
        'sourceTimestamp': '2026-09-07T08:00:00.000Z',
        'ingestedAt': '2026-09-07T08:00:05.000Z',
        'staleAfter': '2026-09-07T08:15:00.000Z',
        'rates': [
          {'karat': '24K', 'ratePerGramAed': '380.50'},
        ],
        'disclaimer': 'Indicative only — not a quotation or an offer.',
      });

      final result = await api.goldRates();

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/gold-rates');
      expect(result, isA<Ok<GoldRateSnapshot>>());
      final rates = (result as Ok<GoldRateSnapshot>).value;
      expect(rates.available, isTrue);
      expect(rates.stale, isFalse);
      expect(rates.rates.single.karat, Karat.k24);
      expect(rates.rates.single.ratePerGramAed, '380.50');
    });

    test('GET /v1/gold-rates maps unlicensed payload as unavailable', () async {
      payload = envelope({
        'available': false,
        'reason': 'DISPLAY_NOT_LICENSED',
      });

      final result = await api.goldRates();
      final rates = (result as Ok<GoldRateSnapshot>).value;
      expect(rates.available, isFalse);
      expect(rates.stale, isFalse);
      expect(rates.rates, isEmpty);
      expect(rates.reason, 'DISPLAY_NOT_LICENSED');
    });
  });

  group('GET/PATCH /v1/me/settings', () {
    test('GET /v1/me/settings maps UserSettings', () async {
      payload = envelope({
        'preferredLanguage': 'ar',
        'defaultRegionId': 'reg-1',
        'quietHours': {
          'start': '22:00',
          'end': '07:00',
          'timezone': 'Asia/Dubai',
        },
        'notifications': {
          'OFFERS': {'inApp': true, 'push': true, 'email': false},
        },
      });

      final result = await api.settings();

      expect(lastRequest!.method, 'GET');
      expect(lastRequest!.path, '/v1/me/settings');
      expect(result, isA<Ok<UserSettings>>());
      final s = (result as Ok<UserSettings>).value;
      expect(s.preferredLanguage, 'ar');
      expect(s.defaultRegionId, 'reg-1');
      expect(s.quietHours!.start, '22:00');
      expect(s.notifications['OFFERS']!.inApp, isTrue);
    });

    test('PATCH /v1/me/settings sends body and maps UserSettings', () async {
      payload = envelope({
        'preferredLanguage': 'en',
        'notifications': {
          'OFFERS': {'inApp': false, 'push': false, 'email': false},
        },
      });

      final result = await api.patchSettings(
        preferredLanguage: 'en',
        defaultRegionId: 'reg-9',
        quietHours: const QuietHours(start: '21:00', end: '06:00'),
        notifications: {
          'OFFERS': const NotificationChannelPref(inApp: false, push: false, email: false),
        },
      );

      expect(lastRequest!.method, 'PATCH');
      expect(lastRequest!.path, '/v1/me/settings');
      expect(lastBody, {
        'preferredLanguage': 'en',
        'defaultRegionId': 'reg-9',
        'quietHours': {
          'start': '21:00',
          'end': '06:00',
          'timezone': 'Asia/Dubai',
        },
        'notifications': {
          'OFFERS': {'inApp': false, 'push': false, 'email': false},
        },
      });
      expect(result, isA<Ok<UserSettings>>());
    });

    test('settings errors stay Failure', () async {
      status = 403;
      payload = {
        'error': {'code': 'FORBIDDEN', 'message': 'Not allowed.'},
      };

      final result = await api.patchSettings(preferredLanguage: 'en');
      expect(result, isA<Err<UserSettings>>());
      expect((result as Err<UserSettings>).failure, isA<ForbiddenFailure>());
    });
  });

  group('existing Vendor methods', () {
    test('registerVendor still POSTs /v1/auth/register/vendor', () async {
      status = 201;
      payload = envelope(sessionJson(
        user: meUserJson(
          userType: 'VENDOR',
          vendor: {
            'vendorProfileId': 'vp-1',
            'lifecycle': 'PENDING_VERIFICATION',
            'awaitingApproval': true,
            'tradingName': 'Al Noor',
            'legalBusinessName': 'Al Noor LLC',
            'categoryCount': 0,
            'regionCount': 0,
          },
        ),
      ));

      final result = await api.registerVendor({
        'firebaseToken': 'tok',
        'legalBusinessName': 'Al Noor LLC',
        'tradingName': 'Al Noor',
        'tradeLicenceNumber': 'TL-1',
        'licenceExpiryDate': '2027-01-01',
        'businessAddress': 'Dubai',
        'contactPersonName': 'Omar',
        'businessEmail': 'omar@example.com',
        'regionId': 'reg-1',
        'categoryIds': ['c-1'],
        'servedRegionIds': ['reg-1'],
        'termsVersion': '1.0',
        'privacyVersion': '1.0',
      });

      expect(lastRequest!.path, '/v1/auth/register/vendor');
      expect(result, isA<Ok<SessionBundle>>());
      expect((result as Ok<SessionBundle>).value.user.vendor, isNotNull);
    });
  });
}

const _customerJson = {
  'displayName': 'Aisha',
  'photoUrl': null,
  'defaultRegion': {
    'id': 'reg-1',
    'nameEn': 'Dubai',
    'nameAr': 'دبي',
  },
  'reviewCount': 0,
  'connectionCount': 0,
  'liveRequestCount': 1,
  'canCreateRequest': true,
};
