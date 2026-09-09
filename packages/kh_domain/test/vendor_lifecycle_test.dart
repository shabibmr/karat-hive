import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('VendorLifecycle.parse', () {
    test('maps known wire values', () {
      expect(VendorLifecycle.parse('ACTIVE'), VendorLifecycle.active);
      expect(VendorLifecycle.parse('PENDING_VERIFICATION'),
          VendorLifecycle.pendingVerification);
      expect(VendorLifecycle.parse('REJECTED'), VendorLifecycle.rejected);
    });

    test('unknown value falls back to .unknown (NFR-027)', () {
      expect(VendorLifecycle.parse('SOMETHING_NEW'), VendorLifecycle.unknown);
      expect(VendorLifecycle.parse(null), VendorLifecycle.unknown);
    });

    test('canLogin excludes rejected/suspended/deactivated', () {
      expect(VendorLifecycle.active.canLogin, isTrue);
      expect(VendorLifecycle.verified.canLogin, isTrue);
      expect(VendorLifecycle.pendingVerification.canLogin, isTrue);
      expect(VendorLifecycle.rejected.canLogin, isFalse);
      expect(VendorLifecycle.suspended.canLogin, isFalse);
    });
  });

  test('AwaitingApprovalReason.parse', () {
    expect(AwaitingApprovalReason.parse('CATEGORIES_REQUIRED'),
        AwaitingApprovalReason.categoriesRequired);
    expect(AwaitingApprovalReason.parse('???'), AwaitingApprovalReason.unknown);
  });

  test('VendorMe.fromJson', () {
    final me = VendorMe.fromJson({
      'vendorProfileId': 'vp1',
      'lifecycle': 'PENDING_VERIFICATION',
      'awaitingApproval': true,
      'awaitingApprovalReason': 'PENDING_DOCUMENTS',
      'tradingName': 'Al Noor',
      'legalBusinessName': 'Al Noor LLC',
      'categoryCount': 1,
      'regionCount': 2,
      'verificationMessage': 'Upload a clearer licence.',
    });
    expect(me.lifecycle, VendorLifecycle.pendingVerification);
    expect(me.verificationMessage, 'Upload a clearer licence.');
    expect(me.regionCount, 2);
    expect(me.verifiedAt, isNull);
    expect(me.rating, isNull);
    expect(me.offersSubmittedCount, 0);
    expect(me.connectionCount, 0);
    expect(me.maskedPreview, isNull);
  });

  test('VendorMe.fromJson parses VEN-S15 read-only header fields', () {
    final me = VendorMe.fromJson({
      'vendorProfileId': 'vp1',
      'lifecycle': 'ACTIVE',
      'awaitingApproval': false,
      'tradingName': 'Al Noor',
      'legalBusinessName': 'Al Noor LLC',
      'categoryCount': 1,
      'regionCount': 1,
      'verifiedAt': '2026-01-15T10:00:00.000Z',
      'rating': {
        'average': 4.6,
        'count': 12,
        'distribution': {'5': 8, '4': 3, '3': 1, '2': 0, '1': 0},
        'limitedHistory': false,
      },
      'offersSubmittedCount': 40,
      'connectionCount': 9,
      'maskedPreview': {
        'label': 'Verified Jeweller · Deira',
        'region': 'Deira',
        'rating': {'average': 4.6, 'count': 12},
        'connectionCount': 9,
      },
    });
    expect(me.verifiedAt, DateTime.parse('2026-01-15T10:00:00.000Z'));
    expect(me.rating!.average, 4.6);
    expect(me.rating!.count, 12);
    expect(me.offersSubmittedCount, 40);
    expect(me.connectionCount, 9);
    expect(me.maskedPreview!.displayPseudonym, 'Verified Jeweller · Deira');
    expect(me.maskedPreview!.dealCount, 9);
  });

  test('VendorMe.fromJson falls back offersAcceptedCount to connectionCount', () {
    final me = VendorMe.fromJson({
      'vendorProfileId': 'vp1',
      'lifecycle': 'ACTIVE',
      'awaitingApproval': false,
      'tradingName': 'Al Noor',
      'legalBusinessName': 'Al Noor LLC',
      'categoryCount': 0,
      'regionCount': 0,
      'offersSubmittedCount': 3,
      'offersAcceptedCount': 2,
    });
    expect(me.connectionCount, 2);
  });

  test('VendorMe.fromJson parses VEN-S15 safe-edit fields', () {
    final me = VendorMe.fromJson({
      'vendorProfileId': 'vp1',
      'lifecycle': 'ACTIVE',
      'awaitingApproval': false,
      'tradingName': 'Al Noor',
      'legalBusinessName': 'Al Noor LLC',
      'categoryCount': 0,
      'regionCount': 0,
      'description': 'Bridal sets and bullion.',
      'contactPersonName': 'Sara',
      'businessEmail': 'sara@alnoor.example',
      'businessHours': {
        'mon': {'open': '09:30', 'close': '22:00', 'closed': false},
        'sun': {'open': '16:00', 'close': '21:30', 'closed': true},
      },
    });
    expect(me.description, 'Bridal sets and bullion.');
    expect(me.contactPersonName, 'Sara');
    expect(me.businessEmail, 'sara@alnoor.example');
    expect(me.businessHours['mon']!.open, '09:30');
    expect(me.businessHours['sun']!.closed, isTrue);
  });
}
