import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

Map<String, dynamic> _customerOfferPayload({String state = 'ACCEPTED'}) => {
      'id': 'off-accept-1',
      'requestId': 'req-accept-1',
      'state': state,
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

Map<String, dynamic> _customerConnectionPayload() => {
      'id': 'conn-accept-1',
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
        'id': 'req-accept-1',
        'reference': 'KH-RQ-24A1',
        'requestType': 'FIND_ORNAMENT',
        'direction': 'BUY',
      },
      'acceptedOffer': {
        'id': 'off-accept-1',
        'offeredPrice': '12500.00',
        'submittedAt': '2026-09-01T11:00:00.000Z',
      },
    };

Map<String, dynamic> _acceptPayload() => {
      'offer': _customerOfferPayload(),
      'connection': _customerConnectionPayload(),
    };

void main() {
  test('AcceptOfferResult parses bare accept payload', () {
    final result = AcceptOfferResult.fromJson(_acceptPayload());
    expect(result.offer.id, 'off-accept-1');
    expect(result.offer.state, OfferState.accepted);
    expect(result.connection.id, 'conn-accept-1');
    expect(result.connection.vendor.displayName, 'Al Noor');
  });

  test('AcceptOfferResult peels double-enveloped { data: result }', () {
    final result = AcceptOfferResult.fromJson({
      'data': _acceptPayload(),
    });
    expect(result.offer.id, 'off-accept-1');
    expect(result.connection.id, 'conn-accept-1');
  });

  test('ConnectionForCustomer peels double-enveloped { data: connection }', () {
    final conn = ConnectionForCustomer.fromJson({
      'data': _customerConnectionPayload(),
    });
    expect(conn.id, 'conn-accept-1');
    expect(conn.state, ConnectionState.active);
    expect(conn.vendor.displayName, 'Al Noor');
  });
}
