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

  static const customerOnboarding = '/customer/onboarding';
  static const customerRegister = '/customer/register';
  static const authComplete = '/auth/complete';
  static const customerHome = '/customer/home';
  static const customerRequests = '/customer/requests';
  static const customerConnections = '/customer/connections';
  static const customerAlerts = '/customer/alerts';
  static const customerProfile = '/customer/profile';
  static const customerBlocked = '/customer/blocked';

  static const unauthRoutes = {
    login,
    register,
    customerOnboarding,
    customerRegister,
    authComplete,
  };

  static const awaitingRoutes = {awaiting, kyc, categories};

  static const completerRoutes = {authComplete, customerRegister, register};

  static bool isCustomerLocation(String location) =>
      location == authComplete || location.startsWith('/customer');

  static bool isVendorLocation(String location) =>
      location == awaiting || location.startsWith('/vendor');

  /// Guard chain: not bootstrapped → splash; not authed → CUS-S01;
  /// unbound Google → completer; Customer → customer shell;
  /// pending/rejected Vendor → awaiting; active Vendor → vendor home.
  static String? redirect(SessionState session, String location) {
    switch (session) {
      case SessionLoading():
        return location == splash ? null : splash;
      case SignedOut():
        if (unauthRoutes.contains(location)) return null;
        return isVendorLocation(location) ? login : customerOnboarding;
      case UnboundGoogle():
        return completerRoutes.contains(location) ? null : authComplete;
      case AuthBlocked():
        return location == customerBlocked ? null : customerBlocked;
      case SignedIn(:final user, :final isCustomer, :final isVendor):
        if (location == splash) return homeFor(session);
        if (isCustomer) return _customerRedirect(session, location);
        if (isVendor) {
          return _signedInRedirect(user.vendor?.lifecycle ?? VendorLifecycle.unknown, location);
        }
        return customerOnboarding;
    }
  }

  static String homeFor(SignedIn session) {
    if (session.isCustomer) {
      return session.isCustomerBlocked ? customerBlocked : customerHome;
    }
    if (session.isVendor) {
      final lifecycle = session.vendorLifecycle;
      return lifecycle == VendorLifecycle.active ? home : awaiting;
    }
    return customerOnboarding;
  }

  static String? _customerRedirect(SignedIn session, String location) {
    if (session.isCustomerBlocked) {
      return location == customerBlocked ? null : customerBlocked;
    }
    if (unauthRoutes.contains(location) || isVendorLocation(location)) {
      return customerHome;
    }
    if (location == customerBlocked) return customerHome;
    return null;
  }

  static String? _signedInRedirect(VendorLifecycle lifecycle, String location) {
    if (isCustomerLocation(location)) {
      return homeForLifecycle(lifecycle);
    }
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

  static String homeForLifecycle(VendorLifecycle lifecycle) =>
      lifecycle == VendorLifecycle.active ? home : awaiting;
}
