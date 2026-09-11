import 'package:kh_domain/kh_domain.dart';

import '../features/request_create/routes.dart';
import 'session/session_controller.dart';

/// Usability mirror of the server rules — never a security boundary
/// (Architecture-Frontend §7.3, CP1-B02a).
abstract final class AppGuards {
  static const splash = '/splash';
  static const guestLanding = '/guest';
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
    guestLanding,
    login,
    register,
    customerOnboarding,
    customerRegister,
    authComplete,
  };

  static const awaitingRoutes = {awaiting, kyc, categories};

  static const completerRoutes = {authComplete, customerRegister, register};

  /// Exact Guest compose paths (GL-08).
  static const guestCreateRoutes = {
    RequestCreatePaths.type,
    RequestCreatePaths.ornament,
    RequestCreatePaths.sellGold,
    RequestCreatePaths.coins,
    RequestCreatePaths.bullion,
    RequestCreatePaths.images,
    RequestCreatePaths.review,
  };

  /// GL-15 steal doors only — other unauth (e.g. authComplete) → Dashboard is accepted.
  static const pendingPublishStealDoors = {
    splash,
    customerOnboarding,
    customerRegister,
  };

  static bool isGuestCreateLocation(String location) =>
      guestCreateRoutes.contains(location);

  static bool isCustomerLocation(String location) =>
      location == authComplete || location.startsWith('/customer');

  static bool isVendorLocation(String location) =>
      location == awaiting || location.startsWith('/vendor');

  /// Guard chain: not bootstrapped → splash; SignedOut → Guest (+ create);
  /// unbound Google → Customer signup (Vendor register still allowed);
  /// Customer → customer shell (pending-publish exception);
  /// pending/rejected Vendor → awaiting; active Vendor → vendor home.
  ///
  /// Pending clear for Vendor is owned by the router session listener (GL-16),
  /// not this redirect — keep redirect free of side effects.
  static String? redirect(
    SessionState session,
    String location, {
    bool pendingPublish = false,
  }) {
    switch (session) {
      case SessionLoading():
        return location == splash ? null : splash;
      case SignedOut():
        if (unauthRoutes.contains(location) ||
            isGuestCreateLocation(location)) {
          return null;
        }
        return guestLanding;
      case UnboundGoogle():
        if (location == customerRegister || location == register) return null;
        return customerRegister;
      case AuthBlocked():
        return location == customerBlocked ? null : customerBlocked;
      case SignedIn(:final user, :final isCustomer, :final isVendor):
        if (isCustomer) {
          return _customerRedirect(
            session,
            location,
            pendingPublish: pendingPublish,
          );
        }
        if (isVendor) {
          if (location == splash) return homeFor(session);
          return _signedInRedirect(
            user.vendor?.lifecycle ?? VendorLifecycle.unknown,
            location,
          );
        }
        // Unknown / Admin (F23): Guest Landing, not onboarding.
        return guestLanding;
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
    return guestLanding;
  }

  static String? _customerRedirect(
    SignedIn session,
    String location, {
    required bool pendingPublish,
  }) {
    if (session.isCustomerBlocked) {
      return location == customerBlocked ? null : customerBlocked;
    }
    if (pendingPublish) {
      if (isGuestCreateLocation(location)) return null;
      if (pendingPublishStealDoors.contains(location)) {
        return RequestCreatePaths.review;
      }
    }
    if (location == splash) return homeFor(session);
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
                unauthRoutes.contains(location)
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
