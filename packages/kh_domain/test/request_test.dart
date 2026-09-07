import 'dart:io';

import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('RequestType', () {
    test('maps inventory wires', () {
      expect(RequestType.parse('FIND_ORNAMENT'), RequestType.findOrnament);
      expect(RequestType.parse('SELL_OLD_GOLD'), RequestType.sellOldGold);
      expect(RequestType.parse('GOLD_COIN'), RequestType.goldCoin);
      expect(RequestType.parse('GOLD_BULLION'), RequestType.goldBullion);
    });

    test('unknown falls back (NFR-027)', () {
      expect(RequestType.parse('SOMETHING_NEW'), RequestType.unknown);
      expect(RequestType.parse(null), RequestType.unknown);
    });

    test('wire values round-trip', () {
      expect(RequestType.findOrnament.wire, 'FIND_ORNAMENT');
      expect(RequestType.sellOldGold.wire, 'SELL_OLD_GOLD');
      expect(RequestType.goldCoin.wire, 'GOLD_COIN');
      expect(RequestType.goldBullion.wire, 'GOLD_BULLION');
    });
  });

  group('Direction', () {
    test('maps BUY and SELL', () {
      expect(Direction.parse('BUY'), Direction.buy);
      expect(Direction.parse('SELL'), Direction.sell);
      expect(Direction.parse('???'), Direction.unknown);
    });
  });

  group('RequestState', () {
    test('maps inventory wires', () {
      expect(RequestState.parse('DRAFT'), RequestState.draft);
      expect(RequestState.parse('PUBLISHED'), RequestState.published);
      expect(RequestState.parse('OFFERS_RECEIVED'), RequestState.offersReceived);
      expect(RequestState.parse('ACCEPTED'), RequestState.accepted);
      expect(RequestState.parse('CLOSED'), RequestState.closed);
      expect(RequestState.parse('EXPIRED'), RequestState.expired);
      expect(RequestState.parse('CANCELLED'), RequestState.cancelled);
      expect(RequestState.parse('REMOVED'), RequestState.removed);
      expect(RequestState.parse('FUTURE'), RequestState.unknown);
    });
  });

  group('RequestForCustomer (owner presenter)', () {
    test('parses type, direction, state, reference, expiry, offerCount', () {
      final req = RequestForCustomer.fromJson({
        'id': 'req-1',
        'reference': 'KH-RQ-24A1',
        'requestType': 'FIND_ORNAMENT',
        'direction': 'BUY',
        'state': 'OFFERS_RECEIVED',
        'category': {'id': 'cat-1', 'nameEn': 'Rings', 'nameAr': 'خواتم'},
        'region': {'id': 'reg-1', 'nameEn': 'Dubai', 'nameAr': 'دبي'},
        'weightIsApproximate': true,
        'budgetIsFlexible': false,
        'offerCount': 3,
        'media': [],
        'createdAt': '2026-09-01T10:00:00.000Z',
        'updatedAt': '2026-09-01T12:00:00.000Z',
        'expiresAt': '2026-09-03T10:00:00.000Z',
        'publishedAt': '2026-09-01T10:00:00.000Z',
      });
      expect(req.id, 'req-1');
      expect(req.reference, 'KH-RQ-24A1');
      expect(req.requestType, RequestType.findOrnament);
      expect(req.direction, Direction.buy);
      expect(req.state, RequestState.offersReceived);
      expect(req.offerCount, 3);
      expect(req.expiresAt, DateTime.parse('2026-09-03T10:00:00.000Z'));
      expect(req.unreadOfferCount, isNull);
      expect(req.connectionId, isNull);
    });

    test('unreadOfferCount and connectionId are optional', () {
      final req = RequestForCustomer.fromJson({
        'id': 'req-2',
        'requestType': 'GOLD_BULLION',
        'direction': 'BUY',
        'state': 'ACCEPTED',
        'category': {'id': 'c', 'nameEn': 'Bullion', 'nameAr': 'سبائك'},
        'region': {'id': 'r', 'nameEn': 'Abu Dhabi', 'nameAr': 'أبوظبي'},
        'weightIsApproximate': false,
        'budgetIsFlexible': false,
        'offerCount': 1,
        'media': [],
        'createdAt': '2026-09-01T10:00:00.000Z',
        'updatedAt': '2026-09-01T12:00:00.000Z',
        'unreadOfferCount': 2,
        'connectionId': 'conn-9',
      });
      expect(req.unreadOfferCount, 2);
      expect(req.connectionId, 'conn-9');
    });

    test('owner type source has no Vendor identity fields', () {
      final src = File('lib/src/request.dart').readAsStringSync();
      final start = src.indexOf('class RequestForCustomer');
      final next = src.indexOf('\nclass ', start + 1);
      final body = src.substring(start, next == -1 ? src.length : next);
      for (final name in ['tradingName', 'mobileNumber', 'vendor']) {
        expect(
          body.contains(name),
          isFalse,
          reason: 'RequestForCustomer must not hold Vendor identity ($name)',
        );
      }
    });
  });
}
