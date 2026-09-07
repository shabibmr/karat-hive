import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/features/requests/model/request_list_item.dart';

/// A raw `Request` list row exactly as origin/main `GET /v1/admin/requests`
/// returns it (Prisma row + shallow includes, string decimals).
Map<String, dynamic> _rawListRow({int offerCount = 0}) => {
      'id': 'req-1',
      'reference': 'KH-REQ-1001',
      'customerProfileId': 'cust-prof-1',
      'requestType': 'FIND_ORNAMENT',
      'direction': 'BUY',
      'state': 'PUBLISHED',
      'categoryId': 'cat-1',
      'regionId': 'reg-1',
      'notes': 'Looking for a 22K bangle set',
      'weightGrams': '45.50',
      'weightIsApproximate': true,
      'purityKarat': '22K',
      'ornamentType': 'BANGLE',
      'budgetMin': '9000.00',
      'budgetMax': '12000.00',
      'budgetIsFlexible': false,
      'indicativeValue': '10500.00',
      'publishedAt': '2026-09-01T08:00:00.000Z',
      'expiresAt': '2026-09-03T08:00:00.000Z',
      'offerCount': offerCount,
      'acceptedOfferId': null,
      'cancellationReason': null,
      'createdAt': '2026-09-01T07:55:00.000Z',
      'updatedAt': '2026-09-01T07:55:00.000Z',
      'customerProfile': {
        'id': 'cust-prof-1',
        'userId': 'user-1',
        'displayName': 'Aisha Rahman',
        'photoMediaId': null,
        'defaultRegionId': 'reg-1',
        'aggregateRating': '4.5',
        'reviewCount': 12,
        'connectionCount': 3,
        'user': {
          'mobileNumber': '+971501234567',
          'email': 'aisha@example.com',
        },
      },
      'category': {'id': 'cat-1', 'nameEn': 'Bangles', 'nameAr': 'اساور'},
      'region': {'id': 'reg-1', 'nameEn': 'Dubai', 'nameAr': 'دبي'},
    };

/// A raw `Request` detail row as origin/main `GET /v1/admin/requests/:id`
/// returns it (deeper includes: media/offers/connections).
Map<String, dynamic> _rawDetailRow() => {
      ..._rawListRow(),
      'state': 'REMOVED',
      'cancellationReason':
          '[PROHIBITED_ITEM] Listing violates trading policy section 4.2',
      'customerProfile': {
        'id': 'cust-prof-1',
        'userId': 'user-1',
        'displayName': 'Aisha Rahman',
        'user': {
          'mobileNumber': '+971501234567',
          'email': 'aisha@example.com',
          'accountState': 'ACTIVE',
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
      },
      'media': [
        {
          'requestId': 'req-1',
          'mediaId': 'med-1',
          'displayOrder': 0,
          'media': {
            'id': 'med-1',
            'key': 'uploads/med-1.jpg',
            'contentType': 'image/jpeg',
            'byteSize': 204800,
            'thumbnailKey': 'uploads/med-1-thumb.jpg',
          },
        },
      ],
      'offers': [
        {
          'id': 'off-1',
          'vendorProfileId': 'vend-1',
          'price': '11000.00',
          'state': 'PENDING',
          'createdAt': '2026-09-02T09:00:00.000Z',
          'vendorProfile': {
            'legalBusinessName': 'Gold Souk LLC',
            'user': {'mobileNumber': '+971559999999'},
          },
        },
      ],
      'connections': [
        {
          'id': 'conn-1',
          'offerId': 'off-1',
          'requestId': 'req-1',
          'customerProfileId': 'cust-prof-1',
          'vendorProfileId': 'vend-1',
          'state': 'ACTIVE',
          'identityRevealedAt': '2026-09-02T10:00:00.000Z',
          'closedAt': null,
          'closedBy': null,
          'createdAt': '2026-09-02T10:00:00.000Z',
          'updatedAt': '2026-09-02T10:00:00.000Z',
        },
      ],
    };

void main() {
  group('RequestListItem.fromApiResponse (raw main row)', () {
    test('reads customer name/phone from customerProfile + nested user', () {
      final item = RequestListItem.fromApiResponse(_rawListRow());

      expect(item.customerName, 'Aisha Rahman');
      expect(item.customerPhone, '+971501234567');
      expect(item.categoryName, 'Bangles');
      expect(item.regionName, 'Dubai');
    });

    test('parses string decimals', () {
      final item = RequestListItem.fromApiResponse(_rawListRow());

      expect(item.indicativeValue, 10500.0);
      expect(item.budgetMin, 9000.0);
      expect(item.budgetMax, 12000.0);
      expect(item.weightGrams, 45.5);
    });

    test('maps enums and offer count', () {
      final item = RequestListItem.fromApiResponse(_rawListRow(offerCount: 4));

      expect(item.requestType, RequestType.findOrnament);
      expect(item.direction, Direction.buy);
      expect(item.state, RequestState.published);
      expect(item.offerCount, 4);
    });
  });

  group('RequestDetail.fromApiResponse (raw main row)', () {
    test('unmasks customer from displayName + nested user', () {
      final detail = RequestDetail.fromApiResponse(_rawDetailRow());

      expect(detail.customer.fullName, 'Aisha Rahman');
      expect(detail.customer.mobileNumber, '+971501234567');
      expect(detail.customer.email, 'aisha@example.com');
      expect(detail.customer.accountState, 'ACTIVE');
    });

    test('builds media URLs from storage keys', () {
      final media = RequestDetail.fromApiResponse(_rawDetailRow()).media.single;

      expect(media.url, '/v1/media/uploads/med-1.jpg');
      expect(media.thumbnailUrl, '/v1/media/uploads/med-1-thumb.jpg');
      expect(media.mimeType, 'image/jpeg');
      expect(media.sizeBytes, 204800);
    });

    test('parses "[CODE] text" cancellationReason into removal fields', () {
      final detail = RequestDetail.fromApiResponse(_rawDetailRow());

      expect(detail.removalReasonCode, 'PROHIBITED_ITEM');
      expect(detail.removalReasonText,
          'Listing violates trading policy section 4.2');
      expect(detail.removalPolicyClause, isNull);
      expect(detail.isRemoved, isTrue);
    });

    test('maps the shallow connection row', () {
      final connection =
          RequestDetail.fromApiResponse(_rawDetailRow()).connection!;

      expect(connection.id, 'conn-1');
      expect(connection.state, 'ACTIVE');
      expect(connection.vendorId, 'vend-1');
      expect(connection.customerId, 'cust-prof-1');
      expect(connection.identityRevealedAt, isNotNull);
      expect(connection.closedAt, isNull);
    });

    test('parses offers and leaves backend-absent sections empty', () {
      final detail = RequestDetail.fromApiResponse(_rawDetailRow());

      expect(detail.offers.single.priceAED, 11000.0);
      expect(detail.offers.single.state, OfferState.pending);
      expect(detail.matchedVendors, isEmpty);
      expect(detail.timeline, isEmpty);
      expect(detail.internalNotes, isEmpty);
    });
  });

  group('RequestInternalNoteItem.fromApiResponse (raw AdminNote row)', () {
    test('reads author.displayName', () {
      final note = RequestInternalNoteItem.fromApiResponse({
        'id': 'note-1',
        'entityType': 'requests',
        'entityId': 'req-1',
        'text': 'Flagged by trust team',
        'authorAdminId': 'adm-1',
        'createdAt': '2026-09-02T11:00:00.000Z',
        'author': {'displayName': 'Sara Admin'},
      });

      expect(note.authorName, 'Sara Admin');
      expect(note.text, 'Flagged by trust team');
    });
  });
}
