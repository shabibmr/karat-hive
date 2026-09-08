import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('MeUser.fromJson Customer branch (CM-S01)', () {
    test('reads customer, oauthBound, liveRequestCount, canCreateRequest, accountState', () {
      final me = MeUser.fromJson({
        'id': 'u-cust',
        'userId': 'u-cust',
        'userType': 'CUSTOMER',
        'accountState': 'ACTIVE',
        'mobileNumber': '+971501111111',
        'preferredLanguage': 'en',
        'oauthBound': true,
        'customer': {
          'displayName': 'Aisha',
          'reviewCount': 2,
          'connectionCount': 3,
          'liveRequestCount': 1,
          'canCreateRequest': true,
          'defaultRegion': {
            'id': 'reg-dxb',
            'nameEn': 'Dubai',
            'nameAr': 'دبي',
          },
        },
      });

      expect(me.userId, 'u-cust');
      expect(me.userType, 'CUSTOMER');
      expect(me.accountState, AccountState.active);
      expect(me.oauthBound, isTrue);
      expect(me.liveRequestCount, 1);
      expect(me.canCreateRequest, isTrue);
      expect(me.customer?.displayName, 'Aisha');
      expect(me.customer?.connectionCount, 3);
      expect(me.customer?.defaultRegion?.id, 'reg-dxb');
      expect(me.vendor, isNull);
    });

    test('falls back to root liveRequestCount when nested fields absent', () {
      final me = MeUser.fromJson({
        'userId': 'u-cust',
        'userType': 'CUSTOMER',
        'accountState': 'SUSPENDED',
        'mobileNumber': '+971501111111',
        'preferredLanguage': 'ar',
        'oauthBound': false,
        'liveRequestCount': 10,
        'canCreateRequest': false,
        'customer': {
          'displayName': 'Omar',
          'reviewCount': 0,
          'connectionCount': 0,
        },
      });
      expect(me.accountState, AccountState.suspended);
      expect(me.liveRequestCount, 10);
      expect(me.canCreateRequest, isFalse);
      expect(me.oauthBound, isFalse);
    });
  });

  group('MeUser.fromJson Vendor branch', () {
    test('VendorMe.vendor still parses Checkpoint-1 payload', () {
      final me = MeUser.fromJson({
        'userId': 'u-ven',
        'userType': 'VENDOR',
        'accountState': 'ACTIVE',
        'mobileNumber': '+971500000001',
        'preferredLanguage': 'en',
        'vendor': {
          'vendorProfileId': 'vp1',
          'lifecycle': 'PENDING_VERIFICATION',
          'awaitingApproval': true,
          'awaitingApprovalReason': 'PENDING_DOCUMENTS',
          'tradingName': 'Al Noor',
          'legalBusinessName': 'Al Noor LLC',
          'categoryCount': 1,
          'regionCount': 2,
          'verificationMessage': 'Upload a clearer licence.',
        },
      });
      expect(me.vendor, isNotNull);
      expect(me.vendor!.lifecycle, VendorLifecycle.pendingVerification);
      expect(me.vendor!.tradingName, 'Al Noor');
      expect(me.vendor!.regionCount, 2);
      expect(me.customer, isNull);
      expect(me.accountState, AccountState.active);
    });
  });

  group('UserRole', () {
    test('parses the backend userType discriminator', () {
      expect(UserRole.parse('CUSTOMER'), UserRole.customer);
      expect(UserRole.parse('VENDOR'), UserRole.vendor);
      expect(UserRole.parse('customer'), UserRole.customer);
      expect(UserRole.parse('ADMIN'), UserRole.unknown);
      expect(UserRole.parse(null), UserRole.unknown);
    });
  });

  group('MeUser', () {
    test('role getter derives from userType', () {
      const u = MeUser(
        userId: 'u1',
        userType: 'CUSTOMER',
        mobileNumber: '+971500000000',
        preferredLanguage: 'en',
      );
      expect(u.role, UserRole.customer);
    });

    test('fromJson parses the customer profile block', () {
      final u = MeUser.fromJson({
        'userId': 'u1',
        'userType': 'CUSTOMER',
        'mobileNumber': '+971500000000',
        'preferredLanguage': 'ar',
        'oauthBound': true,
        'customer': {
          'displayName': 'Layla',
          'photoUrl': 'https://x/y.png',
          'defaultRegion': {'id': 'r1', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
          'rating': {'average': 4.5, 'count': 8},
          'reviewCount': 8,
          'connectionCount': 3,
          'liveRequestCount': 2,
          'canCreateRequest': true,
        },
      });

      expect(u.role, UserRole.customer);
      expect(u.oauthBound, isTrue);
      expect(u.vendor, isNull);
      final c = u.customer!;
      expect(c.displayName, 'Layla');
      expect(c.defaultRegion!.nameEn, 'Deira');
      expect(c.rating!.average, 4.5);
      expect(c.liveRequestCount, 2);
      expect(c.canCreateRequest, isTrue);
    });

    test('customer block is absent for a vendor session', () {
      final u = MeUser.fromJson({
        'userId': 'u2',
        'userType': 'VENDOR',
        'mobileNumber': '+971500000001',
        'preferredLanguage': 'en',
        'vendor': {'vendorProfileId': 'vp1', 'lifecycle': 'ACTIVE'},
      });
      expect(u.role, UserRole.vendor);
      expect(u.customer, isNull);
      expect(u.vendor, isNotNull);
    });
  });
}
