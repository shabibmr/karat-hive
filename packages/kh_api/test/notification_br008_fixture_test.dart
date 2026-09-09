import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

/// BR-008 / AD-ASYNC-03 competitor-blindness keys (mirrors backend
/// `COMPETITOR_KEYS` in `identity-keys.ts`). Must stay absent from Vendor
/// notification wire fixtures — not null, not empty, not present.
const competitorKeys = <String>{
  'competitorPrice',
  'competitorPrices',
  'competingPrices',
  'winningPrice',
  'winningVendor',
  'winningVendorId',
  'winningVendorName',
  'competitorId',
  'competitorName',
  'competitorVendor',
  'competingVendor',
  'competingVendors',
  'competitorTerms',
  'competingTerms',
  'competitorOffers',
  'competingOffers',
};

/// Canonical loser fixture (`offer.rejected` / copyKey `offer.accepted.loser`).
/// Source: Async-Contract §7.2 + `notification.copy.ts` — no price, no identity.
Map<String, dynamic> loserNotificationFixture({
  String id = 'ntf-loser-1',
  String requestId = '11111111-1111-1111-1111-111111111111',
}) =>
    {
      'id': id,
      'type': 'offer.rejected',
      'title': 'The Customer selected another Vendor',
      'body': 'The Customer accepted a different Offer on this Request.',
      'deepLink': '/requests/$requestId',
      'isCritical': false,
      'createdAt': '2026-09-08T10:00:00.000Z',
    };

/// Canonical winner fixture (`offer.accepted` / copyKey `offer.accepted.winner`).
Map<String, dynamic> acceptedNotificationFixture({
  String id = 'ntf-win-1',
  String connectionId = '33333333-3333-3333-3333-333333333333',
}) =>
    {
      'id': id,
      'type': 'offer.accepted',
      'title': 'Your Offer was accepted',
      'body': 'The Customer accepted your Offer. You are now connected.',
      'deepLink': '/connections/$connectionId',
      'isCritical': true,
      'createdAt': '2026-09-08T10:00:00.000Z',
    };

String? findCompetitorKey(Object? value) {
  if (value is List) {
    for (final item in value) {
      final hit = findCompetitorKey(item);
      if (hit != null) return hit;
    }
    return null;
  }
  if (value is Map) {
    for (final entry in value.entries) {
      final key = entry.key.toString();
      if (competitorKeys.contains(key)) return key;
      final nested = findCompetitorKey(entry.value);
      if (nested != null) return nested;
    }
  }
  return null;
}

/// Price / winner identity must not appear in localised copy or deep links.
final _leakyCopy = RegExp(
  r'AED|winningPrice|competitorPrice|ven-win|offer-win|offeredPrice',
  caseSensitive: false,
);

void expectNoCompetitorCopy(Map<String, dynamic> fixture) {
  for (final field in ['title', 'body', 'deepLink']) {
    final text = fixture[field]?.toString() ?? '';
    expect(
      text,
      isNot(matches(_leakyCopy)),
      reason: '$field must not leak competitor price/identity (BR-008)',
    );
  }
}

class _MockHttpAdapter implements HttpClientAdapter {
  _MockHttpAdapter(this.handler);
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

ResponseBody _jsonBody(Object data, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class _MemoryTokenStorage implements TokenStorage {
  SessionTokens? _tokens;
  @override
  Future<SessionTokens?> read() async => _tokens;
  @override
  Future<void> save(SessionTokens tokens) async => _tokens = tokens;
  @override
  Future<void> clear() async => _tokens = null;
}

void main() {
  group('BR-008 notification fixtures (CP5-B07.1)', () {
    test('loser fixture has no competitor price key or leaky copy', () {
      final fixture = loserNotificationFixture();
      expect(findCompetitorKey(fixture), isNull);
      expectNoCompetitorCopy(fixture);
      expect(fixture['deepLink'], startsWith('/requests/'));
      expect(fixture.containsKey('acceptedOfferId'), isFalse);
      expect(fixture.containsKey('offeredPrice'), isFalse);
    });

    test('accepted (winner) fixture has no competitor price key or leaky copy',
        () {
      final fixture = acceptedNotificationFixture();
      expect(findCompetitorKey(fixture), isNull);
      expectNoCompetitorCopy(fixture);
      expect(fixture['deepLink'], startsWith('/connections/'));
      expect(fixture.containsKey('rejectedOfferIds'), isFalse);
      expect(fixture.containsKey('winningPrice'), isFalse);
    });

    test('NotificationDto parses loser/accepted without inventing price fields',
        () {
      final loser = NotificationDto.fromJson(loserNotificationFixture());
      expect(loser.type, 'offer.rejected');
      expect(loser.body, isNot(contains('AED')));
      expect(loser.title.toLowerCase(), isNot(contains('price')));

      final winner =
          NotificationDto.fromJson(acceptedNotificationFixture());
      expect(winner.type, 'offer.accepted');
      expect(winner.body, isNot(contains('AED')));
      expect(winner.title.toLowerCase(), isNot(contains('price')));
    });

    test('NotificationsClient.list maps loser+accepted page without competitor keys',
        () async {
      final loser = loserNotificationFixture();
      final accepted = acceptedNotificationFixture();
      final envelope = {
        'data': [loser, accepted],
        'meta': {'nextCursor': null, 'hasMore': false},
      };
      expect(findCompetitorKey(envelope), isNull);

      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((opts) async {
        expect(opts.path, '/v1/notifications');
        return _jsonBody(envelope);
      });
      final api = KhApi(
        KhApiClient(
          baseUrl: 'https://api.test',
          tokenStorage: _MemoryTokenStorage(),
          serverClock: ServerClock(),
          dio: dio,
        ),
      );

      final result = await api.notifications.list();
      expect(result, isA<Ok<PagedResult<AppNotification>>>());
      final page = (result as Ok<PagedResult<AppNotification>>).value;
      expect(page.items, hasLength(2));
      expect(page.items[0].type, 'offer.rejected');
      expect(page.items[1].type, 'offer.accepted');
      for (final item in page.items) {
        expect(item.body, isNot(matches(_leakyCopy)));
        expect(item.title, isNot(matches(_leakyCopy)));
      }
    });
  });
}
