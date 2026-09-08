import 'package:kh_domain/kh_domain.dart';

import 'session/session_controller.dart';

/// Usability mirror of the server rules — never a security boundary
/// (Architecture-Frontend §7.3, CP1-B02a). The role gate (`SH-SHELL-04`,
/// §7.2) dispatches on the authenticated role before any shell-specific rule.
abstract final class AppGuards {
  static const splash = '/splash';

  // --- Vendor / unauth shells ---
  static const login = '/vendor/login';
  static const register = '/vendor/register';
  static const customerOnboarding = '/welcome'; // CUS-S01 — pre-auth
  static const awaiting = '/awaiting';
  static const kyc = '/vendor/onboarding/kyc';
  static const categories = '/vendor/categories-regions';
  static const home = '/vendor/home';

  // --- Customer shell (SH-SHELL-01/02/03) ---
  static const customerHome = '/home'; // CUS-S02
  static const customerRequestDetail = '/requests/:id'; // CUS-S10
  static const customerNotifications = '/notifications'; // CUS-S19
  static const customerProfile = '/profile'; // CUS-S20

  static const unauthRoutes = {login, register, customerOnboarding};
  static const awaitingRoutes = {awaiting, kyc, categories};
  static const customerTabRoutes = {
    customerHome,
    customerNotifications,
    customerProfile,
  };

  /// A concrete location that belongs to the Customer shell. Request-detail is
  /// parametric (`/requests/<id>`), so it is matched by prefix.
  static bool isCustomerLocation(String location) =>
      customerTabRoutes.contains(location) ||
      location.startsWith('/requests/');

  /// Guard chain: not bootstrapped → splash; not authed → login; then dispatch
  /// on role. A session whose role has no shell (e.g. `ADMIN`) is bounced to
  /// login rather than accommodated.
  static String? redirect(SessionState session, String location) {
    switch (session) {
      case SessionLoading():
        return location == splash ? null : splash;
      case SignedOut():
        return unauthRoutes.contains(location) ? null : login;
      case SignedIn(:final role, :final vendorLifecycle):
        switch (role) {
          case UserRole.customer:
            return _customerRedirect(location);
          case UserRole.vendor:
            if (location == splash) return homeFor(vendorLifecycle);
            return _vendorRedirect(vendorLifecycle, location);
          case null:
            return login;
        }
    }
  }

  static String homeFor(VendorLifecycle lifecycle) =>
      lifecycle == VendorLifecycle.active ? home : awaiting;

  static String? _customerRedirect(String location) {
    if (isCustomerLocation(location)) return null;
    // splash, or any vendor/unauth route reached by a Customer session.
    return customerHome;
  }

  static String? _vendorRedirect(VendorLifecycle lifecycle, String location) {
    switch (lifecycle) {
      case VendorLifecycle.active:
        return awaitingRoutes.contains(location) ||
                unauthRoutes.contains(location) ||
                isCustomerLocation(location)
            ? home
            : null;
      case VendorLifecycle.verified:
        return awaitingRoutes.contains(location) ? null : awaiting;
      case VendorLifecycle.pendingVerification:
      case VendorLifecycle.registered:
      case VendorLifecycle.rejected:
        return (location == awaiting || location == kyc) ? null : awaiting;
      default:
        return login;
    }
  }
}
