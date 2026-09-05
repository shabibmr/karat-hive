import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_domain/kh_domain.dart';

import 'session/session_controller.dart';
import 'shells/splash_screen.dart';
import '../features/auth/presentation/vendor_login_screen.dart';
import '../features/auth/presentation/vendor_register_screen.dart';
import '../features/dashboard/presentation/vendor_dashboard_screen.dart';
import '../features/onboarding/presentation/awaiting_approval_screen.dart';
import '../features/onboarding/presentation/categories_regions_screen.dart';
import '../features/onboarding/presentation/kyc_upload_screen.dart';

class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _SessionListenable(ref);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) => _redirect(ref, state.matchedLocation),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/vendor/login', builder: (_, __) => const VendorLoginScreen()),
      GoRoute(path: '/vendor/register', builder: (_, __) => const VendorRegisterScreen()),
      GoRoute(path: '/awaiting', builder: (_, __) => const AwaitingApprovalScreen()),
      GoRoute(
        path: '/vendor/onboarding/kyc',
        builder: (_, __) => const KycUploadScreen(),
      ),
      GoRoute(
        path: '/vendor/categories-regions',
        builder: (_, __) => const CategoriesRegionsScreen(),
      ),
      GoRoute(path: '/vendor/home', builder: (_, __) => const VendorDashboardScreen()),
    ],
  );
});

/// Usability mirror of the server rules — never a security boundary
/// (Architecture-Frontend §7.3).
String? _redirect(Ref ref, String location) {
  final session = ref.read(sessionProvider);
  const onboardingRoutes = {
    '/awaiting',
    '/vendor/onboarding/kyc',
    '/vendor/categories-regions',
  };

  switch (session) {
    case SessionLoading():
      return location == '/splash' ? null : '/splash';
    case SignedOut():
      const authRoutes = {'/vendor/login', '/vendor/register'};
      return authRoutes.contains(location) ? null : '/vendor/login';
    case SignedIn(:final vendorLifecycle):
      if (location == '/splash') return _home(vendorLifecycle);
      switch (vendorLifecycle) {
        case VendorLifecycle.active:
          return onboardingRoutes.contains(location) ||
                  location == '/vendor/login' ||
                  location == '/vendor/register'
              ? '/vendor/home'
              : null;
        case VendorLifecycle.verified:
          return onboardingRoutes.contains(location) ? null : '/awaiting';
        case VendorLifecycle.pendingVerification:
        case VendorLifecycle.registered:
        case VendorLifecycle.rejected:
          return (location == '/awaiting' || location == '/vendor/onboarding/kyc')
              ? null
              : '/awaiting';
        default:
          return '/vendor/login';
      }
  }
}

String _home(VendorLifecycle lifecycle) =>
    lifecycle == VendorLifecycle.active ? '/vendor/home' : '/awaiting';
