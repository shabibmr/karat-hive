import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'guards.dart';
import 'session/session_controller.dart';
import 'shells/awaiting_approval_shell.dart';
import 'shells/customer_shell.dart';
import 'shells/splash_screen.dart';
import 'shells/unauth_shell.dart';
import 'shells/vendor_shell.dart';
import '../features/auth/presentation/customer_onboarding_screen.dart';
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
    initialLocation: AppGuards.splash,
    refreshListenable: listenable,
    redirect: (context, state) =>
        AppGuards.redirect(ref.read(sessionProvider), state.matchedLocation),
    routes: [
      GoRoute(
        path: AppGuards.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => UnauthShell(child: child),
        routes: [
          GoRoute(
            path: AppGuards.login,
            builder: (_, __) => const VendorLoginScreen(),
          ),
          GoRoute(
            path: AppGuards.register,
            builder: (_, __) => const VendorRegisterScreen(),
          ),
          // CUS-S01 — Customer onboarding (CFE-09 / CFE-10). Pre-auth: an
          // unauthenticated session reaches it directly.
          GoRoute(
            path: AppGuards.customerOnboarding,
            builder: (_, __) => const CustomerOnboardingScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AwaitingApprovalShell(child: child),
        routes: [
          GoRoute(
            path: AppGuards.awaiting,
            builder: (_, __) => const AwaitingApprovalScreen(),
          ),
          GoRoute(
            path: AppGuards.kyc,
            builder: (_, __) => const KycUploadScreen(),
          ),
          GoRoute(
            path: AppGuards.categories,
            builder: (_, __) => const CategoriesRegionsScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => VendorShell(child: child),
        routes: [
          GoRoute(
            path: AppGuards.home,
            builder: (_, __) => const VendorDashboardScreen(),
          ),
        ],
      ),
      // Customer shell (SH-SHELL-01/02/03). Placeholder bodies — real screens
      // are built on top of this foundation.
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: AppGuards.customerHome,
            builder: (_, __) =>
                const CustomerScreenPlaceholder('CUS-S02'),
          ),
          GoRoute(
            path: AppGuards.customerNotifications,
            builder: (_, __) =>
                const CustomerScreenPlaceholder('CUS-S19'),
          ),
          GoRoute(
            path: AppGuards.customerProfile,
            builder: (_, __) =>
                const CustomerScreenPlaceholder('CUS-S20'),
          ),
          GoRoute(
            path: AppGuards.customerRequestDetail,
            builder: (_, state) => CustomerScreenPlaceholder(
              'CUS-S10 · ${state.pathParameters['id']}',
            ),
          ),
        ],
      ),
    ],
  );
});
