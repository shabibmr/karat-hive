import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('UserRole', () {
    test('parses the backend userType discriminator', () {
      expect(UserRole.parse('CUSTOMER'), UserRole.customer);
      expect(UserRole.parse('VENDOR'), UserRole.vendor);
      expect(UserRole.parse('customer'), UserRole.customer);
      expect(UserRole.parse('ADMIN'), isNull);
      expect(UserRole.parse(null), isNull);
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
