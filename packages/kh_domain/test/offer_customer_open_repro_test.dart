import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

Map<String, dynamic> _customerOfferPayload() => {
      'id': 'off-open-1',
      'requestId': 'req-open-1',
      'state': 'PENDING',
      'submittedAt': '2026-09-01T11:00:00.000Z',
      'expiresAt': '2026-09-02T11:00:00.000Z',
      'revisionCount': 0,
      'terms': {
        'offeredPrice': '12500',
        'weightGrams': '10',
        'purityKarat': 'K22',
      },
      'vendor': {
        'label': 'Vendor · Abu Dhabi',
        'region': {'id': 'r1', 'nameEn': 'Abu Dhabi', 'nameAr': 'أبوظبي'},
        'connectionCount': 2,
        'rating': {
          'average': '4.5',
          'count': 8,
          'distribution': <String, dynamic>{},
          'limitedHistory': false,
        },
      },
    };

Map<String, dynamic> _liveVendorRatingPayload() => {
      'vendor': {
        'label': 'Vendor · Abu Dhabi',
        'region': {
          'id': 'r1',
          'nameEn': 'Abu Dhabi',
          'nameAr': 'أبوظبي',
          'isActive': true,
          'displayOrder': 1,
        },
        'connectionCount': 2,
        'rating': {
          'average': '4.5',
          'count': 8,
          'distribution': <String, dynamic>{},
          'limitedHistory': false,
        },
      },
      'reviews': [
        {
          'id': 'rv1',
          'rating': 5,
          'comment': 'Fair price',
          'publishedAt': '2026-01-01T00:00:00.000Z',
          'reviewerLabel': 'Customer A.',
        },
      ],
    };

void main() {
  test('OfferForCustomer parses double-enveloped get response', () {
    final offer = OfferForCustomer.fromJson({
      'data': _customerOfferPayload(),
    });
    expect(offer.id, 'off-open-1');
    expect(offer.requestId, 'req-open-1');
    expect(offer.state, OfferState.pending);
    expect(offer.vendor.displayPseudonym, contains('Abu Dhabi'));
  });

  test('VendorRatingDetail parses live vendor+reviews shape', () {
    final detail = VendorRatingDetail.fromJson(_liveVendorRatingPayload());
    expect(detail.summary.average, 4.5);
    expect(detail.summary.count, 8);
    expect(detail.excerpts, hasLength(1));
    expect(detail.excerpts.first.abbreviatedName, 'Customer A.');
    expect(detail.excerpts.first.rating, 5);
  });

  test('VendorRatingDetail peels double-enveloped rating response', () {
    final detail = VendorRatingDetail.fromJson({
      'data': _liveVendorRatingPayload(),
    });
    expect(detail.summary.average, 4.5);
    expect(detail.excerpts.first.abbreviatedName, 'Customer A.');
  });
}
