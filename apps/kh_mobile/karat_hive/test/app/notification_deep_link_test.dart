import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/notification_deep_link.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:kh_domain/kh_domain.dart';

import '../helpers/fake_session.dart';

void main() {
  const requestId = '11111111-1111-1111-1111-111111111111';
  const offerId = '22222222-2222-2222-2222-222222222222';
  const connectionId = '33333333-3333-3333-3333-333333333333';

  SignedIn activeVendor() => SignedIn(
        testVendorUser(vendor: testVendorMe(lifecycle: VendorLifecycle.active)),
      );

  group('NotificationDeepLink.resolve — Vendor (VEN-S17 / Async-Contract §7.2)', () {
    test('maps the five Vendor deep-link targets', () {
      expect(
        NotificationDeepLink.resolve('/requests/$requestId', isVendor: true),
        '/vendor/requests/$requestId',
      );
      expect(
        NotificationDeepLink.resolve('/offers/$offerId', isVendor: true),
        '/vendor/offers/$offerId',
      );
      expect(
        NotificationDeepLink.resolve(
          '/connections/$connectionId',
          isVendor: true,
        ),
        '/vendor/connections/$connectionId',
      );
      expect(
        NotificationDeepLink.resolve('/me/vendor', isVendor: true),
        AppGuards.vendorProfile,
      );
      expect(
        NotificationDeepLink.resolve('/me/vendor/documents', isVendor: true),
        AppGuards.vendorProfileDocuments,
      );
    });

    test('rejects non-UUID identifiers', () {
      expect(
        NotificationDeepLink.resolve('/requests/req-1', isVendor: true),
        isNull,
      );
      expect(
        NotificationDeepLink.resolve('/offers/not-a-uuid', isVendor: true),
        isNull,
      );
    });

    test('rejects unknown, empty, and absolute URLs', () {
      expect(NotificationDeepLink.resolve('', isVendor: true), isNull);
      expect(NotificationDeepLink.resolve('   ', isVendor: true), isNull);
      expect(
        NotificationDeepLink.resolve('/announcements/x', isVendor: true),
        isNull,
      );
      expect(
        NotificationDeepLink.resolve(
          'https://karathive.ae/requests/$requestId',
          isVendor: true,
        ),
        isNull,
      );
    });

    test('trims trailing slash', () {
      expect(
        NotificationDeepLink.resolve('/me/vendor/', isVendor: true),
        AppGuards.vendorProfile,
      );
    });
  });

  group('NotificationDeepLink.resolve — Customer', () {
    test('maps request / offer / connection targets', () {
      expect(
        NotificationDeepLink.resolve('/requests/$requestId', isVendor: false),
        '/customer/requests/$requestId',
      );
      expect(
        NotificationDeepLink.resolve(
          '/requests/$requestId/offers',
          isVendor: false,
        ),
        '/customer/requests/$requestId/offers',
      );
      expect(
        NotificationDeepLink.resolve('/offers/$offerId', isVendor: false),
        '/customer/offers/$offerId',
      );
      expect(
        NotificationDeepLink.resolve(
          '/connections/$connectionId',
          isVendor: false,
        ),
        '/customer/connections/$connectionId',
      );
    });

    test('never opens Vendor-only /me/vendor paths', () {
      expect(
        NotificationDeepLink.resolve('/me/vendor', isVendor: false),
        isNull,
      );
      expect(
        NotificationDeepLink.resolve('/me/vendor/documents', isVendor: false),
        isNull,
      );
    });
  });

  group('AppGuards + resolved locations', () {
    test('active Vendor is not redirected off resolved §7.2 targets', () {
      final session = activeVendor();
      final targets = [
        NotificationDeepLink.resolve('/requests/$requestId', isVendor: true)!,
        NotificationDeepLink.resolve('/offers/$offerId', isVendor: true)!,
        NotificationDeepLink.resolve(
          '/connections/$connectionId',
          isVendor: true,
        )!,
        NotificationDeepLink.resolve('/me/vendor', isVendor: true)!,
        NotificationDeepLink.resolve('/me/vendor/documents', isVendor: true)!,
      ];
      for (final location in targets) {
        expect(
          AppGuards.redirect(session, location),
          isNull,
          reason: 'guard must allow $location',
        );
      }
    });
  });
}
