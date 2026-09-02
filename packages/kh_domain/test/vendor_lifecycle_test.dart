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
  });
}
