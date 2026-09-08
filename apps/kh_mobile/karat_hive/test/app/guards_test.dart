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

    test('SignedOut is confined to the unauth shell', () {
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.home),
        AppGuards.login,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.login),
        isNull,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.register),
        isNull,
      );
    });

    test('CUS-S01 onboarding is reachable pre-auth and gated otherwise', () {
      // Unauthenticated: CUS-S01 loads directly (it is the pre-auth screen).
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerOnboarding),
        isNull,
      );
      // Still bootstrapping: everything waits on splash.
      expect(
        AppGuards.redirect(const SessionLoading(), AppGuards.customerOnboarding),
        AppGuards.splash,
      );
      // A completed Customer visiting /welcome is sent into the shell.
      expect(
        AppGuards.redirect(_customer(), AppGuards.customerOnboarding),
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
      // From splash, or from any vendor / unauth route, land on customer home.
      expect(AppGuards.redirect(c, AppGuards.splash), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.home), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.login), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.awaiting), AppGuards.customerHome);
      // Customer routes are allowed as-is, including the parametric detail route.
      expect(AppGuards.redirect(c, AppGuards.customerHome), isNull);
      expect(AppGuards.redirect(c, AppGuards.customerNotifications), isNull);
      expect(AppGuards.redirect(c, AppGuards.customerProfile), isNull);
      expect(AppGuards.redirect(c, '/requests/abc-123'), isNull);
    });

    test('an ACTIVE Vendor is redirected off Customer routes', () {
      final active = _signedIn(VendorLifecycle.active);
      expect(AppGuards.redirect(active, AppGuards.customerHome), AppGuards.home);
      expect(AppGuards.redirect(active, '/requests/abc'), AppGuards.home);
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
