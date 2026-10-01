import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

/// Shape of `presentOfferForVendor` (backend offer.presenter.ts) for a freshly
/// submitted Offer with one OFFER_IMAGE. Absent optional fields are omitted,
/// as JSON.stringify drops `undefined`.
Map<String, dynamic> _payload({required bool withMedia}) => {
      'id': 'af46fd95-2a1d-42d6-9f0d-52795f797b67',
      'requestId': '06c380cd-8500-49e9-b0a5-af8e8b92c05a',
      'state': 'PENDING',
      'submittedAt': '2026-10-01T16:39:00.018Z',
      'expiresAt': '2026-10-02T16:39:00.018Z',
      'revisionCount': 0,
      'terms': {
        'offeredPrice': '5200',
        'weightGrams': '15',
        'purityKarat': '22K',
      },
      'media': withMedia
          ? [
              {
                'id': 'm-1',
                'key': '482f9cd1-6eef-4b0a-b7fc-779eb0e27cf9',
                'state': 'READY',
                'purpose': 'OFFER_IMAGE',
                'contentType': 'image/jpeg',
                'byteSize': 123456,
                'displayOrder': 0,
                'displayUrl': '/v1/media/482f9cd1-6eef-4b0a-b7fc-779eb0e27cf9',
                'thumbnailUrl': '/v1/media/482f9cd1-6eef-4b0a-b7fc-779eb0e27cf9',
              },
            ]
          : <Object>[],
      'requestSummary': {
        'id': '06c380cd-8500-49e9-b0a5-af8e8b92c05a',
        'reference': 'KH-RQ-0001',
        'requestType': 'FIND_ORNAMENT',
        'direction': 'BUY',
        'region': {
          'id': 'reg-1',
          'nameEn': 'Dubai',
          'nameAr': 'دبي',
          'isActive': true,
          'displayOrder': 1,
        },
        'customerLabel': 'Customer · Dubai',
        'purityKarat': '22K',
        'weightGrams': '15',
        'expiresAt': '2026-10-03T10:00:00.000Z',
      },
    };

void main() {
  for (final withMedia in [false, true]) {
    test('[repro] OfferForVendor.fromJson parses submit response '
        '(media: $withMedia)', () {
      final offer = OfferForVendor.fromJson(_payload(withMedia: withMedia));
      expect(offer.id, 'af46fd95-2a1d-42d6-9f0d-52795f797b67');
    });
  }

  test('parses double-enveloped { data: offer } from older API deploys', () {
    final offer = OfferForVendor.fromJson({
      'data': _payload(withMedia: false),
    });
    expect(offer.id, 'af46fd95-2a1d-42d6-9f0d-52795f797b67');
    expect(offer.requestId, '06c380cd-8500-49e9-b0a5-af8e8b92c05a');
    expect(offer.state, OfferState.pending);
  });
}
