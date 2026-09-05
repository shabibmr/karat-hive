import 'package:kh_domain/kh_domain.dart';

import 'session/session_controller.dart';

/// Usability mirror of the server rules — never a security boundary
/// (Architecture-Frontend §7.3, CP1-B02a).
abstract final class AppGuards {
  static const splash = '/splash';
  static const login = '/vendor/login';
  static const register = '/vendor/register';
  static const awaiting = '/awaiting';
  static const kyc = '/vendor/onboarding/kyc';
  static const categories = '/vendor/categories-regions';
  static const home = '/vendor/home';

  static const unauthRoutes = {login, register};
  static const awaitingRoutes = {awaiting, kyc, categories};

  /// Guard chain: not bootstrapped → splash; not authed → login;
  /// pending/rejected → awaiting; verified (cats/regions CTA) → awaiting;
  /// active → home.
  static String? redirect(SessionState session, String location) {
    switch (session) {
      case SessionLoading():
        return location == splash ? null : splash;
      case SignedOut():
        return unauthRoutes.contains(location) ? null : login;
      case SignedIn(:final vendorLifecycle):
        if (location == splash) return homeFor(vendorLifecycle);
        return _signedInRedirect(vendorLifecycle, location);
    }
  }

  static String homeFor(VendorLifecycle lifecycle) =>
      lifecycle == VendorLifecycle.active ? home : awaiting;

  static String? _signedInRedirect(VendorLifecycle lifecycle, String location) {
    switch (lifecycle) {
      case VendorLifecycle.active:
        return awaitingRoutes.contains(location) || unauthRoutes.contains(location)
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
