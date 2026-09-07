import 'dart:io';

import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('OfferState', () {
    test('maps inventory wires', () {
      expect(OfferState.parse('PENDING'), OfferState.pending);
      expect(OfferState.parse('ACCEPTED'), OfferState.accepted);
      expect(OfferState.parse('REJECTED'), OfferState.rejected);
      expect(OfferState.parse('EXPIRED'), OfferState.expired);
      expect(OfferState.parse('WITHDRAWN'), OfferState.withdrawn);
      expect(OfferState.parse('WITHDRAWN_BY_SYSTEM'), OfferState.withdrawnBySystem);
      expect(OfferState.parse('NEW'), OfferState.unknown);
    });
  });

  group('OfferForCustomer', () {
    test('parses terms, validity, and MaskedParty vendor', () {
      final offer = OfferForCustomer.fromJson({
        'id': 'off-1',
        'requestId': 'req-1',
        'state': 'PENDING',
        'terms': {
          'offeredPrice': '12500.00',
          'makingCharges': '200.00',
          'validityHours': 24,
          'vendorNote': 'Hallmarked 22K',
        },
        'vendor': {
          'label': 'Vendor · Deira',
          'region': {'id': 'r1', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
          'connectionCount': 8,
          'rating': {'average': '4.5', 'count': 8, 'limitedHistory': false},
        },
        'submittedAt': '2026-09-01T11:00:00.000Z',
        'expiresAt': '2026-09-02T11:00:00.000Z',
        'revisionCount': 0,
      });
      expect(offer.id, 'off-1');
      expect(offer.state, OfferState.pending);
      expect(offer.terms.offeredPrice, '12500.00');
      expect(offer.terms.validityHours, 24);
      expect(offer.vendor, isA<MaskedParty>());
      expect(offer.vendor.pseudonym, 'Vendor · Deira');
      expect(offer.vendor.role, PartyRole.vendor);
      expect(offer.viewedByCustomerAt, isNull);
    });

    test('source cannot hold Vendor trading name', () {
      final src = File('lib/src/offer.dart').readAsStringSync();
      expect(src.contains('tradingName'), isFalse);
      final start = src.indexOf('class OfferForCustomer');
      final next = src.indexOf('\nclass ', start + 1);
      final body = src.substring(start, next == -1 ? src.length : next);
      expect(body.contains('RevealedParty'), isFalse);
    });
  });

  group('TalkPayload', () {
    test('parses inventory waUrl and backend phone alias', () {
      final talk = TalkPayload.fromJson({
        'waUrl': 'https://wa.me/971501234567?text=Hello',
        'mobileNumber': '+971501234567',
        'prefilledMessage': 'Hello',
        'available': true,
      });
      expect(talk.waUrl, startsWith('https://wa.me/'));
      expect(talk.mobileNumber, '+971501234567');
      expect(talk.available, isTrue);

      final backend = TalkPayload.fromJson({
        'waUrl': 'https://wa.me/971509999999?text=x',
        'phone': '+971509999999',
        'available': false,
      });
      expect(backend.mobileNumber, '+971509999999');
      expect(backend.available, isFalse);
    });
  });

  group('Connection', () {
    test('holds RevealedParty Vendor and TalkPayload', () {
      final conn = ConnectionForCustomer.fromJson({
        'id': 'conn-1',
        'state': 'ACTIVE',
        'identityRevealedAt': '2026-09-01T12:00:00.000Z',
        'createdAt': '2026-09-01T12:00:00.000Z',
        'vendor': {
          'tradingName': 'Al Noor',
          'legalBusinessName': 'Al Noor LLC',
          'mobileNumber': '+971501234567',
          'region': {'id': 'r1', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
        },
        'talk': {
          'waUrl': 'https://wa.me/971501234567?text=hi',
          'mobileNumber': '+971501234567',
          'prefilledMessage': 'hi',
          'available': true,
        },
        'request': {
          'id': 'req-1',
          'reference': 'KH-RQ-24A1',
          'requestType': 'FIND_ORNAMENT',
          'direction': 'BUY',
        },
        'acceptedOffer': {
          'id': 'off-1',
          'offeredPrice': '12500.00',
          'submittedAt': '2026-09-01T11:00:00.000Z',
        },
      });
      expect(conn.state, ConnectionState.active);
      expect(conn.vendor, isA<RevealedParty>());
      expect(conn.vendor.displayName, 'Al Noor');
      expect(conn.vendor.business?.tradingName, 'Al Noor');
      expect(conn.talk.waUrl, contains('wa.me'));
    });

    test('revealed Vendor fields live on Connection, not Offer', () {
      final connSrc = File('lib/src/connection.dart').readAsStringSync();
      expect(connSrc.contains('RevealedParty'), isTrue);
      final offerSrc = File('lib/src/offer.dart').readAsStringSync();
      expect(offerSrc.contains('RevealedParty'), isFalse);
    });
  });
}
