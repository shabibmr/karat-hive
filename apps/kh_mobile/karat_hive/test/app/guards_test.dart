import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/app/shells/customer_shell.dart';
import 'package:karat_hive/features/request_create/pending_publish_intent.dart';
import 'package:karat_hive/features/request_create/routes.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

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

SignedIn _unknownRole() => const SignedIn(
  MeUser(
    userId: 'a1',
    userType: 'ADMIN',
    mobileNumber: '+971500000099',
    preferredLanguage: 'en',
  ),
);

const _createPaths = [
  RequestCreatePaths.type,
  RequestCreatePaths.ornament,
  RequestCreatePaths.sellGold,
  RequestCreatePaths.coins,
  RequestCreatePaths.bullion,
  RequestCreatePaths.images,
  RequestCreatePaths.review,
];

void main() {
  group('AppGuards.isGuestCreateLocation', () {
    test('true for the seven create paths', () {
      for (final path in _createPaths) {
        expect(AppGuards.isGuestCreateLocation(path), isTrue, reason: path);
      }
      expect(AppGuards.guestCreateRoutes.length, 7);
    });

    test('false for private Customer tabs and unrelated paths', () {
      expect(AppGuards.isGuestCreateLocation(AppGuards.customerHome), isFalse);
      expect(
        AppGuards.isGuestCreateLocation(AppGuards.customerRequests),
        isFalse,
      );
      expect(
        AppGuards.isGuestCreateLocation('/customer/requests/abc-123'),
        isFalse,
      );
      expect(
        AppGuards.isGuestCreateLocation('/customer/requests/create/extra'),
        isFalse,
      );
      expect(AppGuards.isGuestCreateLocation(AppGuards.guestLanding), isFalse);
    });
  });

  group('PendingPublishIntent', () {
    test('defaults false; setPending then clearPending', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(pendingPublishIntentProvider), isFalse);
      container.read(pendingPublishIntentProvider.notifier).setPending();
      expect(container.read(pendingPublishIntentProvider), isTrue);
      container.read(pendingPublishIntentProvider.notifier).clearPending();
      expect(container.read(pendingPublishIntentProvider), isFalse);
    });

    test('clearPendingPublishIfVendor clears only for Vendor + pending', () {
      var cleared = false;
      clearPendingPublishIfVendor(
        _signedIn(VendorLifecycle.active),
        true,
        () => cleared = true,
      );
      expect(cleared, isTrue);

      cleared = false;
      clearPendingPublishIfVendor(_customer(), true, () => cleared = true);
      expect(cleared, isFalse);

      cleared = false;
      clearPendingPublishIfVendor(
        _signedIn(VendorLifecycle.active),
        false,
        () => cleared = true,
      );
      expect(cleared, isFalse);
    });
  });

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

    test('AuthBlocked stays on blocked', () {
      const blocked = AuthBlocked(ForbiddenFailure(code: 'ACCOUNT_SUSPENDED'));
      expect(
        AppGuards.redirect(blocked, AppGuards.home),
        AppGuards.customerBlocked,
      );
      expect(
        AppGuards.redirect(blocked, AppGuards.guestLanding),
        AppGuards.customerBlocked,
      );
      expect(AppGuards.redirect(blocked, AppGuards.customerBlocked), isNull);
    });

    test('AuthBlocked never redirects to guest landing (GL-69)', () {
      const blocked = AuthBlocked(ForbiddenFailure(code: 'ACCOUNT_SUSPENDED'));
      final locations = <String>{
        '/',
        AppGuards.splash,
        AppGuards.guestLanding,
        AppGuards.customerOnboarding,
        AppGuards.customerRegister,
        AppGuards.customerHome,
        AppGuards.login,
        AppGuards.register,
        AppGuards.home,
        ..._createPaths,
      };
      for (final location in locations) {
        final redirect = AppGuards.redirect(blocked, location);
        expect(
          redirect,
          isNot(AppGuards.guestLanding),
          reason: 'from $location',
        );
        if (location == AppGuards.customerBlocked) {
          expect(redirect, isNull, reason: location);
        } else {
          expect(redirect, AppGuards.customerBlocked, reason: location);
        }
      }
    });

    test('SignedOut defaults to guest landing, not CUS-S01 (GL-70)', () {
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.home),
        AppGuards.guestLanding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.splash),
        AppGuards.guestLanding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), '/'),
        AppGuards.guestLanding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), '/unknown'),
        AppGuards.guestLanding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.guestLanding),
        isNull,
      );
      expect(AppGuards.redirect(const SignedOut(), AppGuards.login), isNull);
      expect(AppGuards.redirect(const SignedOut(), AppGuards.register), isNull);
      // Onboarding remains a Login door, not the SignedOut default.
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerOnboarding),
        isNull,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.home),
        isNot(AppGuards.customerOnboarding),
      );
    });

    test('SignedOut may stay on all seven create paths', () {
      for (final path in _createPaths) {
        expect(
          AppGuards.redirect(const SignedOut(), path),
          isNull,
          reason: path,
        );
      }
    });

    test('SignedOut private Customer tabs go to guest landing', () {
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerHome),
        AppGuards.guestLanding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerRequests),
        AppGuards.guestLanding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerConnections),
        AppGuards.guestLanding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerAlerts),
        AppGuards.guestLanding,
      );
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerProfile),
        AppGuards.guestLanding,
      );
    });

    test('CUS-S01 onboarding is reachable pre-auth and gated otherwise', () {
      expect(
        AppGuards.redirect(const SignedOut(), AppGuards.customerOnboarding),
        isNull,
      );
      expect(
        AppGuards.redirect(
          const SessionLoading(),
          AppGuards.customerOnboarding,
        ),
        AppGuards.splash,
      );
      expect(
        AppGuards.redirect(_customer(), AppGuards.customerOnboarding),
        AppGuards.customerHome,
      );
    });

    test(
      'UnboundGoogle defaults to customerRegister; may stay on register',
      () {
        expect(
          AppGuards.redirect(const UnboundGoogle(), '/'),
          AppGuards.customerRegister,
        );
        expect(
          AppGuards.redirect(const UnboundGoogle(), AppGuards.splash),
          AppGuards.customerRegister,
        );
        expect(
          AppGuards.redirect(const UnboundGoogle(), AppGuards.authComplete),
          AppGuards.customerRegister,
        );
        expect(
          AppGuards.redirect(const UnboundGoogle(), AppGuards.customerRegister),
          isNull,
        );
        expect(
          AppGuards.redirect(const UnboundGoogle(), AppGuards.register),
          isNull,
        );
      },
    );

    test('Customer with pending publish stays on create', () {
      final c = _customer();
      for (final path in _createPaths) {
        expect(
          AppGuards.redirect(c, path, pendingPublish: true),
          isNull,
          reason: path,
        );
      }
    });

    test(
      'Customer with pending publish is steered back from GL-15 steal doors',
      () {
        final c = _customer();
        expect(
          AppGuards.redirect(c, AppGuards.splash, pendingPublish: true),
          RequestCreatePaths.review,
        );
        expect(
          AppGuards.redirect(
            c,
            AppGuards.customerOnboarding,
            pendingPublish: true,
          ),
          RequestCreatePaths.review,
        );
        expect(
          AppGuards.redirect(
            c,
            AppGuards.customerRegister,
            pendingPublish: true,
          ),
          RequestCreatePaths.review,
        );
      },
    );

    test(
      'Customer pending on authComplete / guestLanding goes to Dashboard',
      () {
        // Only splash / onboarding / customerRegister are GL-15 steal doors.
        final c = _customer();
        expect(
          AppGuards.redirect(c, AppGuards.authComplete, pendingPublish: true),
          AppGuards.customerHome,
        );
        expect(
          AppGuards.redirect(c, AppGuards.guestLanding, pendingPublish: true),
          AppGuards.customerHome,
        );
      },
    );

    test('Vendor with pending publish still vendor-destines', () {
      // clearPending is router/session-listener owned; redirect stays pure.
      final active = _signedIn(VendorLifecycle.active);
      expect(
        AppGuards.redirect(
          active,
          RequestCreatePaths.review,
          pendingPublish: true,
        ),
        AppGuards.home,
      );

      final pending = _signedIn(VendorLifecycle.pendingVerification);
      expect(
        AppGuards.redirect(
          pending,
          RequestCreatePaths.ornament,
          pendingPublish: true,
        ),
        AppGuards.awaiting,
      );
    });

    test('pendingVerification / rejected stay on awaiting or KYC', () {
      final pending = _signedIn(VendorLifecycle.pendingVerification);
      expect(AppGuards.redirect(pending, AppGuards.home), AppGuards.awaiting);
      expect(AppGuards.redirect(pending, AppGuards.awaiting), isNull);
      expect(AppGuards.redirect(pending, AppGuards.kyc), isNull);
      expect(
        AppGuards.redirect(pending, AppGuards.categories),
        AppGuards.awaiting,
      );

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

    test('SignedIn Customer without intent restores to Dashboard', () {
      final c = _customer();
      expect(AppGuards.redirect(c, AppGuards.splash), AppGuards.customerHome);
      expect(
        AppGuards.redirect(c, AppGuards.guestLanding),
        AppGuards.customerHome,
      );
      expect(AppGuards.redirect(c, AppGuards.home), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.login), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.awaiting), AppGuards.customerHome);
      expect(AppGuards.redirect(c, AppGuards.customerHome), isNull);
      expect(AppGuards.redirect(c, AppGuards.customerAlerts), isNull);
      expect(AppGuards.redirect(c, AppGuards.customerProfile), isNull);
      expect(AppGuards.redirect(c, '/customer/requests/abc-123'), isNull);
      expect(
        AppGuards.redirect(c, AppGuards.splash),
        isNot(AppGuards.guestLanding),
      );
    });

    test('Unknown / Admin SignedIn goes to guest landing (F23)', () {
      final admin = _unknownRole();
      expect(
        AppGuards.redirect(admin, AppGuards.splash),
        AppGuards.guestLanding,
      );
      expect(AppGuards.redirect(admin, AppGuards.home), AppGuards.guestLanding);
      expect(AppGuards.homeFor(admin), AppGuards.guestLanding);
    });

    test('an ACTIVE Vendor is redirected off Customer routes', () {
      final active = _signedIn(VendorLifecycle.active);
      expect(
        AppGuards.redirect(active, AppGuards.customerHome),
        AppGuards.home,
      );
      expect(
        AppGuards.redirect(active, '/customer/requests/abc'),
        AppGuards.home,
      );
    });

    test('suspended / unknown are not treated as a Vendor session', () {
      expect(
        AppGuards.redirect(
          _signedIn(VendorLifecycle.suspended),
          AppGuards.home,
        ),
        AppGuards.login,
      );
      expect(
        AppGuards.redirect(
          _signedIn(VendorLifecycle.unknown),
          AppGuards.awaiting,
        ),
        AppGuards.login,
      );
    });
  });

  group('create routes outside CustomerShell', () {
    testWidgets('SignedOut create path does not mount customer-shell', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: RequestCreatePaths.ornament,
        redirect: (context, state) =>
            AppGuards.redirect(const SignedOut(), state.matchedLocation),
        routes: [
          GoRoute(
            path: RequestCreatePaths.ornament,
            builder: (_, __) =>
                const Text('create-stub', key: Key('create-stub')),
          ),
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                CustomerShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppGuards.customerHome,
                    builder: (_, __) => const Text('home'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          supportedLocales: KhStrings.supportedLocales,
          localizationsDelegates: KhStrings.delegates,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('create-stub')), findsOneWidget);
      expect(find.byKey(const Key('customer-shell')), findsNothing);
    });
  });
}
