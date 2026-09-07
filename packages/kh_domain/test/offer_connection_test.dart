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

  group('OfferForVendor', () {
    test('parses own terms, request summary, and awardedElsewhere', () {
      final offer = OfferForVendor.fromJson({
        'id': 'off-v1',
        'requestId': 'req-1',
        'state': 'PENDING',
        'terms': {
          'offeredPrice': '9800.00',
          'validityHours': 12,
          'makingCharges': '150.00',
        },
        'media': [
          {'id': 'm1', 'key': 'k1', 'displayOrder': 0},
        ],
        'submittedAt': '2026-09-01T11:00:00.000Z',
        'expiresAt': '2026-09-01T23:00:00.000Z',
        'revisionCount': 1,
        'requestSummary': {
          'id': 'req-1',
          'reference': 'KH-RQ-24A1',
          'requestType': 'FIND_ORNAMENT',
          'direction': 'BUY',
          'customerLabel': 'Customer · Deira',
          'category': {'id': 'c1', 'nameEn': 'Bangles'},
          'region': {'id': 'r1', 'nameEn': 'Deira'},
          'budgetMax': '10000.00',
        },
        'awardedElsewhere': false,
      });
      expect(offer.id, 'off-v1');
      expect(offer.state, OfferState.pending);
      expect(offer.terms.offeredPrice, '9800.00');
      expect(offer.terms.media, hasLength(1));
      expect(offer.revisionsRemaining, 2);
      expect(offer.canRevise, isTrue);
      expect(offer.requestSummary?.customerLabel, 'Customer · Deira');
      expect(offer.requestSummary?.categoryName, 'Bangles');
      expect(offer.awardedElsewhere, isFalse);
    });

    test('has no Customer identity fields and no RevealedParty', () {
      final src = File('lib/src/offer.dart').readAsStringSync();
      final start = src.indexOf('class OfferForVendor');
      final next = src.indexOf('\nclass ', start + 1);
      final body = src.substring(start, next == -1 ? src.length : next);
      expect(body.contains('RevealedParty'), isFalse);
      expect(body.contains('mobileNumber'), isFalse);
      expect(body.contains('tradingName'), isFalse);
      expect(body.contains('displayName'), isFalse);
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
        'callUrl': 'tel:+971509999999',
        'available': false,
      });
      expect(backend.mobileNumber, '+971509999999');
      expect(backend.available, isFalse);
      expect(backend.callUrl, 'tel:+971509999999');
      expect(backend.canOpenWhatsApp, isFalse);
      expect(backend.canCall, isFalse);
    });

    test('does not treat a raw phone as a wa.me URL', () {
      final talk = TalkPayload.fromJson({
        'waUrl': '',
        'phone': '+971501234567',
        'available': true,
      });
      expect(talk.canOpenWhatsApp, isFalse);
      expect(talk.mobileNumber, '+971501234567');
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

  group('ConnectionForVendor', () {
    test('parses revealed Customer, talk.waUrl, and accepted terms', () {
      final conn = ConnectionForVendor.fromJson({
        'id': 'conn-v1',
        'offerId': 'off-1',
        'requestId': 'req-1',
        'state': 'ACTIVE',
        'identityRevealedAt': '2026-09-01T12:00:00.000Z',
        'customer': {
          'id': 'cp-1',
          'displayName': 'Fatima Al Zahra',
          'phone': '+971501234567',
          'connectionCount': 3,
          'rating': {'average': '4.8', 'count': 3},
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
          'category': {'id': 'c1', 'nameEn': 'Bangles', 'nameAr': 'أساور'},
          'region': {'id': 'r1', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
        },
        'offer': {
          'id': 'off-1',
          'offeredPrice': '12500.00',
          'makingCharges': '200.00',
          'validityHours': 24,
        },
      });
      expect(conn.state, ConnectionState.active);
      expect(conn.customer, isA<RevealedParty>());
      expect(conn.customer.displayName, 'Fatima Al Zahra');
      expect(conn.customer.mobile.e164, '+971501234567');
      expect(conn.talk.canOpenWhatsApp, isTrue);
      expect(conn.talk.waUrl, startsWith('https://wa.me/'));
      expect(conn.request?.reference, 'KH-RQ-24A1');
      expect(conn.request?.region?.nameEn, 'Deira');
      expect(conn.acceptedOffer?.terms.offeredPrice, '12500.00');
    });

    test('has no competing Vendor identity or competitor price fields', () {
      final src = File('lib/src/connection.dart').readAsStringSync();
      final start = src.indexOf('class ConnectionForVendor');
      expect(start, greaterThan(0));
      final body = src.substring(start);
      expect(body.contains('competing'), isFalse);
      expect(body.contains('competitor'), isFalse);
      expect(body.contains('winningVendor'), isFalse);
      expect(body.contains('otherOffers'), isFalse);
      expect(body.contains('vendor:'), isFalse);
      expect(body.contains('RevealedParty customer'), isTrue);
    });

    test('masks nothing: identity is scoped to this Connection only', () {
      final conn = ConnectionForVendor.fromJson({
        'id': 'conn-closed',
        'state': 'CLOSED',
        'identityRevealedAt': '2026-09-01T12:00:00.000Z',
        'closedAt': '2026-09-03T12:00:00.000Z',
        'closedBy': 'VENDOR',
        'customer': {
          'displayName': 'Fatima Al Zahra',
          'phone': '+971501234567',
        },
        'talk': {
          'available': false,
          'waUrl': 'https://wa.me/971501234567?text=x',
          'phone': '+971501234567',
          'callUrl': 'tel:+971501234567',
        },
      });
      expect(conn.state, ConnectionState.closed);
      expect(conn.talk.canOpenWhatsApp, isFalse);
      expect(conn.customer.displayName, isNotEmpty);
      expect(conn.closedBy, ClosedBy.vendor);
    });
  });
}
