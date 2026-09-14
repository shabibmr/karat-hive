import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:kh_domain/kh_domain.dart';

SignedIn _signedIn(VendorLifecycle lifecycle) => SignedIn(
      MeUser(
        userId: 'u1',
        userType: 'VENDOR',
        mobileNumber: '+971500000001',
        preferredLanguage: 'en',
        vendor: VendorMe(
          vendorProfileId: 'vp1',
          lifecycle: lifecycle,
          awaitingApproval: lifecycle != VendorLifecycle.active,
          tradingName: 'Al Noor',
          legalBusinessName: 'Al Noor LLC',
          categoryCount: 1,
          regionCount: 1,
        ),
      ),
    );

SignedIn _customer() => const SignedIn(
      MeUser(
        userId: 'c1',
        userType: 'CUSTOMER',
        mobileNumber: '+971500000009',
        preferredLanguage: 'en',
        customer: CustomerMe(
          displayName: 'Layla',
          reviewCount: 0,
          connectionCount: 0,
        ),
      ),
    );

void main() {
  group('AppGuards.redirect', () {
    test('SessionLoading always lands on splash', () {
      expect(
        AppGuards.redirect(const SessionLoading(), AppGuards.home),
        AppGuards.splash,
      );
      expect(
        AppGuards.redirect(const SessionLoading(), AppGuards.splash),
        isNull,
      );
    });

    test('SignedOut lands on Guest Landing by default (adr/0011)', () {
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.splash),
        AppGuards.customerGuest,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.home),
        AppGuards.customerGuest,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.login),
        isNull,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.register),
        isNull,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerGuest),
        isNull,
      );
    });

    test('SignedOut may compose create paths without a token', () {
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerCreatePrefix),
        isNull,
      );
      expect(
        AppGuards.redirect(
          const SignedOut(),
          '${AppGuards.customerCreatePrefix}/ornament',
        ),
        isNull,
      );
      expect(
        AppGuards.redirect(
          const SignedOut(),
          '${AppGuards.customerCreatePrefix}/review',
        ),
        isNull,
      );
    });

    test('SignedOut private Customer tabs require login', () {
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerHome),
        AppGuards.customerOnboarding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerRequests),
        AppGuards.customerOnboarding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerConnections),
        AppGuards.customerOnboarding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerAlerts),
        AppGuards.customerOnboarding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerProfile),
        AppGuards.customerOnboarding,
      );
    });

    test('CUS-S01 login is reachable pre-auth; signed-in Customer leaves it', () {
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerOnboarding),
        isNull,
      );
      expect(
        AppGuards.redirect(const SessionLoading(), AppGuards.customerOnboarding),
        AppGuards.splash,
      );
      expect(
        AppGuards.redirect(_customer(), AppGuards.customerOnboarding),
        AppGuards.customerHome,
      );
      expect(
        AppGuards.redirect(_customer(), AppGuards.customerGuest),
        AppGuards.customerHome,
      );
    });

    test('pendingVerification / rejected stay on awaiting or KYC', () {
      final pending = _signedIn(VendorLifecycle.pendingVerification);
      expect(AppGuards.redirect(pending, AppGuards.home), AppGuards.awaiting);
      expect(AppGuards.redirect(pending, AppGuards.awaiting), isNull);
      expect(AppGuards.redirect(pending, AppGuards.kyc), isNull);
      expect(AppGuards.redirect(pending, AppGuards.categories), AppGuards.awaiting);

      final rejected = _signedIn(VendorLifecycle.rejected);
      expect(AppGuards.redirect(rejected, AppGuards.home), AppGuards.awaiting);
      expect(AppGuards.redirect(rejected, AppGuards.kyc), isNull);
    });

    test('verified may use awaiting routes including categories', () {
      final verified = _signedIn(VendorLifecycle.verified);
      expect(AppGuards.redirect(verified, AppGuards.home), AppGuards.awaiting);
      expect(AppGuards.redirect(verified, AppGuards.awaiting), isNull);
      expect(AppGuards.redirect(verified, AppGuards.categories), isNull);
    });

    test('active is sent to the vendor shell', () {
      final active = _signedIn(VendorLifecycle.active);
      expect(AppGuards.redirect(active, AppGuards.splash), AppGuards.home);
      expect(AppGuards.redirect(active, AppGuards.home), isNull);
      expect(AppGuards.redirect(active, AppGuards.awaiting), AppGuards.home);
      expect(AppGuards.redirect(active, AppGuards.login), AppGuards.home);
    });

    test('the role gate routes a Customer session to the Customer shell', () {
      final c = _customer();
      expect(AppGuards.redirect(c, AppGuards.splash), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.home), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.login), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.awaiting), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.customerHome), isNull);
      expect(AppGuards.redirect(c, AppGuards.customerAlerts), isNull);
      expect(AppGuards.redirect(c, AppGuards.customerProfile), isNull);
      expect(AppGuards.redirect(c, '/customer/requests/abc-123'), isNull);
      // Signed-in Customer may still compose.
      expect(AppGuards.redirect(c, AppGuards.customerCreatePrefix), isNull);
    });

    test('an ACTIVE Vendor is redirected off Customer routes', () {
      final active = _signedIn(VendorLifecycle.active);
      expect(AppGuards.redirect(active, AppGuards.customerHome), AppGuards.home);
      expect(AppGuards.redirect(active, '/customer/requests/abc'), AppGuards.home);
      expect(AppGuards.redirect(active, AppGuards.customerGuest), AppGuards.home);
    });

    test('suspended / unknown are not treated as a Vendor session', () {
      expect(
        AppGuards.redirect(_signedIn(VendorLifecycle.suspended), AppGuards.home),
        AppGuards.login,
      );
      expect(
        AppGuards.redirect(_signedIn(VendorLifecycle.unknown), AppGuards.awaiting),
        AppGuards.login,
      );
    });
  });
}
