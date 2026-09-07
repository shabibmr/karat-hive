import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'guards.dart';
import 'session/session_controller.dart';
import 'shells/awaiting_approval_shell.dart';
import 'shells/splash_screen.dart';
import 'shells/unauth_shell.dart';
import 'shells/vendor_shell.dart';
import '../features/auth/routes.dart';
import '../features/connections/routes.dart';
import '../features/offers_vendor/routes.dart';
import '../features/onboarding/routes.dart';
import '../features/request_feed/routes.dart';
import '../features/subscription/routes.dart';

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
        routes: authRoutes,
      ),
      ShellRoute(
        builder: (context, state, child) => AwaitingApprovalShell(child: child),
        routes: onboardingRoutes,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            VendorShell(navigationShell: navigationShell),
        branches: [
          // Branch 0 — Home (+ subscriptions deep link)
          StatefulShellBranch(
            routes: [
              vendorHomeRoute(routes: [subscriptionNestedRoute]),
              ...subscriptionRoutes,
            ],
          ),
          // Branch 1 — Requests feed + detail
          StatefulShellBranch(
            routes: requestFeedRoutes,
          ),
          // Branch 2 — Offers (CP-3)
          StatefulShellBranch(
            routes: offersVendorTabRoutes,
          ),
          // Branch 3 — Connections (CP-4)
          StatefulShellBranch(
            routes: connectionsTabRoutes,
          ),
          // Branch 4 — Profile (CP-6)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vendor/profile',
                builder: (_, __) => const VendorComingSoonPage(
                  message: 'Vendor profile & settings open in Check-Point 6.',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
