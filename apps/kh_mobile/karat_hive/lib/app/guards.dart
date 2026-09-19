import 'package:kh_domain/kh_domain.dart';

import 'session/session_controller.dart';

/// Usability mirror of the server rules — never a security boundary
/// (Architecture-Frontend §7.3, CP1-B02a).
///
/// Guest-first (`adr/0011`): SignedOut → [customerGuest]. Create compose
/// (`/customer/requests/create*`) is allowed without a token. Private Customer
/// tabs require login ([customerOnboarding]).
abstract final class AppGuards {
  static const splash = '/splash';
  static const login = '/vendor/login';
  static const register = '/vendor/register';
  static const awaiting = '/awaiting';
  static const kyc = '/vendor/onboarding/kyc';
  static const categories = '/vendor/categories-regions';
  static const home = '/vendor/home';
  static const vendorNotifications = '/vendor/notifications';
  static const vendorProfile = '/vendor/profile';
  static const vendorProfileCategories = '/vendor/profile/categories-regions';
  static const vendorProfileDocuments = '/vendor/profile/documents';

  static const customerGuest = '/customer/guest';
  static const customerOnboarding = '/customer/onboarding';
  static const customerRegister = '/customer/register';
  static const authComplete = '/auth/complete';
  static const customerHome = '/customer/home';
  static const customerRequests = '/customer/requests';
  static const customerConnections = '/customer/connections';
  static const customerAlerts = '/customer/alerts';
  static const customerProfile = '/customer/profile';
  static const customerBlocked = '/customer/blocked';

  /// Create-wizard prefix (CUS-S03…S09). Guest may compose; publish gates login.
  static const customerCreatePrefix = '/customer/requests/create';

  static const unauthRoutes = {
    login,
    customerGuest,
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

  /// Guest compose paths reachable without a session (`adr/0011`).
  static bool isGuestCompose(String location) =>
      location == customerCreatePrefix ||
      location.startsWith('$customerCreatePrefix/');

  static bool isSignedOutAllowed(String location) =>
      unauthRoutes.contains(location) || isGuestCompose(location);

  /// Guard chain: not bootstrapped → splash; not authed → Guest Landing;
  /// unbound Google → Customer signup (Guest/Publish) or Vendor register;
  /// Customer → customer shell; pending/rejected Vendor → awaiting;
  /// active Vendor → vendor home.
  static String? redirect(SessionState session, String location) {
    switch (session) {
      case SessionLoading():
        return location == splash ? null : splash;
      case SignedOut():
        if (isSignedOutAllowed(location)) return null;
        // Private Customer areas → Login (CUS-S01); Vendor register requires
        // Google sign-in first (ADR-0010) → Vendor Login; everything else → Guest.
        if (isCustomerLocation(location)) return customerOnboarding;
        if (location == register) return login;
        return customerGuest;
      case UnboundGoogle():
        // Guest compose / Customer Login imply Customer (`adr/0011`, GL-17).
        // No role chooser on this path. Vendor Login unbound → vendor register.
        if (completerRoutes.contains(location)) return null;
        if (location == login) return register;
        return customerRegister;
      case AuthBlocked():
        return location == customerBlocked ? null : customerBlocked;
      case final SignedIn signedIn:
        if (location == splash) return homeFor(signedIn);
        if (signedIn.isCustomer) return _customerRedirect(signedIn, location);
        if (signedIn.isVendor) {
          return _signedInRedirect(
            signedIn.user.vendor?.lifecycle ?? VendorLifecycle.unknown,
            location,
          );
        }
        return customerGuest;
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
    return customerGuest;
  }

  static String? _customerRedirect(SignedIn session, String location) {
    if (session.isCustomerBlocked) {
      return location == customerBlocked ? null : customerBlocked;
    }
    // Guest landing / login / register → home. Create compose stays allowed.
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
        return awaitingRoutes.contains(location) ||
                unauthRoutes.contains(location) ||
                location == register
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
