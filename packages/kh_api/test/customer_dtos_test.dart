import 'package:flutter_test/flutter_test.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';

void main() {
  group('CustomerRequestDto', () {
    test('mirrors request.presenter.ts RequestForCustomer', () {
      final dto = CustomerRequestDto.fromJson({
        'id': 'req-1',
        'reference': 'KH-RQ-0001',
        'requestType': 'FIND_ORNAMENT',
        'direction': 'BUY',
        'state': 'ACCEPTED',
        'category': {'id': 'c1', 'nameEn': 'Rings', 'nameAr': 'خواتم', 'isActive': true, 'displayOrder': 1},
        'region': {'id': 'r1', 'nameEn': 'Deira', 'nameAr': 'ديرة', 'isActive': true, 'displayOrder': 1},
        'weightIsApproximate': true,
        'budgetIsFlexible': false,
        'offerCount': 3,
        'unreadOfferCount': 2,
        'acceptedOfferId': 'off-9',
        'connectionId': 'con-9',
        'media': [
          {'id': 'm1', 'key': 'k1', 'displayOrder': 0, 'state': 'READY', 'purpose': 'REQUEST_IMAGE'}
        ],
        'createdAt': '2026-09-01T10:00:00.000Z',
        'updatedAt': '2026-09-01T11:00:00.000Z',
      });

      expect(dto.reference, 'KH-RQ-0001');
      expect(dto.state, 'ACCEPTED');
      expect(dto.category.nameEn, 'Rings');
      expect(dto.offerCount, 3);
      expect(dto.unreadOfferCount, 2);
      expect(dto.connectionId, 'con-9');
      expect(dto.media.single.key, 'k1');
    });
  });

  group('CustomerOfferDto (masking)', () {
    test('the masked vendor carries no identity fields, only a label', () {
      final dto = CustomerOfferDto.fromJson({
        'id': 'off-1',
        'requestId': 'req-1',
        'state': 'PENDING',
        'submittedAt': '2026-09-01T10:00:00.000Z',
        'expiresAt': '2026-09-02T10:00:00.000Z',
        'revisionCount': 0,
        'terms': {'offeredPrice': '5400.00', 'validityHours': 24},
        'vendor': {
          'label': 'Vendor · Deira',
          'connectionCount': 12,
          'rating': {'average': '4.6', 'count': 20, 'limitedHistory': false},
        },
      });

      expect(dto.isUnread, isTrue);
      expect(dto.terms.offeredPrice, '5400.00');
      expect(dto.vendor.label, 'Vendor · Deira');
      expect(dto.vendor.rating!.average, '4.6');
      // MaskedVendorDto has no `displayName` / `phone` member to read at all.
    });
  });

  group('CustomerConnectionDto (revealed)', () {
    test('the connection vendor is the revealed type with identity present', () {
      final dto = CustomerConnectionDto.fromJson({
        'id': 'con-1',
        'offerId': 'off-1',
        'requestId': 'req-1',
        'state': 'ACTIVE',
        'identityRevealedAt': '2026-09-01T12:00:00.000Z',
        'vendor': {
          'id': 'vp1',
          'legalBusinessName': 'Al Noor Jewellery LLC',
          'tradingName': 'Al Noor',
          'tradeLicenceNumber': 'CN-1234567',
          'phone': '+971501234567',
          'connectionCount': 12,
        },
        'offer': {'id': 'off-1', 'offeredPrice': '5400.00', 'validityHours': 24},
        'request': {
          'id': 'req-1',
          'requestType': 'FIND_ORNAMENT',
          'direction': 'BUY',
          'category': {'id': 'c1', 'nameEn': 'Rings', 'nameAr': 'خواتم', 'isActive': true, 'displayOrder': 1},
          'region': {'id': 'r1', 'nameEn': 'Deira', 'nameAr': 'ديرة', 'isActive': true, 'displayOrder': 1},
        },
        'talk': {
          'available': true,
          'waUrl': 'https://wa.me/971501234567?text=Hello',
          'phone': '+971501234567',
          'callUrl': 'tel:+971501234567',
        },
      });

      expect(dto.vendor.legalBusinessName, 'Al Noor Jewellery LLC');
      expect(dto.vendor.phone, '+971501234567');
      expect(dto.talk.available, isTrue);
      expect(dto.talk.waUrl, startsWith('https://wa.me/'));
    });
  });

  group('Paged', () {
    test('builds from a KhListPayload', () {
      final page = Paged.from(
        const KhListPayload(items: [
          {'id': 'n1', 'type': 'OFFER_RECEIVED', 'title': 't', 'body': 'b', 'deepLink': '/x', 'isCritical': false, 'createdAt': '2026-09-01T10:00:00.000Z'}
        ], nextCursor: 'cur-2'),
        NotificationDto.fromJson,
      );
      expect(page.items.single.type, 'OFFER_RECEIVED');
      expect(page.items.single.isUnread, isTrue);
      expect(page.nextCursor, 'cur-2');
    });
  });

  group('GoldRateSnapshotDto', () {
    test('branches on flags, not timestamps (CBG-02)', () {
      final unlicensed = GoldRateSnapshotDto.fromJson(
          {'available': false, 'reason': 'DISPLAY_NOT_LICENSED'});
      expect(unlicensed.available, isFalse);
      expect(unlicensed.reason, 'DISPLAY_NOT_LICENSED');
      expect(unlicensed.rates, isEmpty);
    });
  });
}
