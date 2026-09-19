import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'back_button_dispatcher.dart';
import 'guards.dart';
import 'session/session_controller.dart';
import 'shells/awaiting_approval_shell.dart';
import 'shells/customer_shell.dart';
import 'shells/splash_screen.dart';
import 'shells/unauth_shell.dart';
import 'shells/vendor_shell.dart';
import '../features/abuse/routes.dart';
import '../features/auth/routes.dart';
import '../features/connections/routes.dart';
import '../features/connections_customer/routes.dart';
import '../features/guest/routes.dart';
import '../features/notifications/routes.dart';
import '../features/offers_customer/routes.dart';
import '../features/offers_vendor/routes.dart';
import '../features/onboarding/routes.dart';
import '../features/profile_settings/routes.dart';
import '../features/request_create/controller/request_create_controller.dart';
import '../features/request_create/routes.dart';
import '../features/request_feed/routes.dart';
import '../features/request_manage/routes.dart';
import '../features/reviews/routes.dart';
import '../features/subscription/routes.dart';

class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
}

final backButtonDispatcherProvider = Provider<AppBackButtonDispatcher>((ref) {
  return AppBackButtonDispatcher(ref.watch(routerProvider));
});

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _SessionListenable(ref);
  return GoRouter(
    initialLocation: AppGuards.splash,
    refreshListenable: listenable,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;
      // Guest Publish → login → return to review for auto-publish (`adr/0011`).
      if (session is SignedIn &&
          session.isCustomer &&
          !session.isCustomerBlocked) {
        final create = ref.read(requestCreateControllerProvider);
        if (create.awaitingLoginToPublish &&
            location != RequestCreatePaths.review &&
            !AppGuards.isGuestCompose(location)) {
          return RequestCreatePaths.review;
        }
      }
      return AppGuards.redirect(session, location);
    },
    routes: [
      GoRoute(
        path: AppGuards.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => UnauthShell(child: child),
        routes: [
          ...guestRoutes,
          ...authRoutes,
          // Create compose is guest-reachable (`adr/0011`); also used signed-in.
          ...requestCreateRoutes,
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AwaitingApprovalShell(child: child),
        routes: onboardingRoutes,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CustomerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              customerHomeRoute(),
              ...offersCustomerRoutes,
              ...abuseRoutes,
            ],
          ),
          StatefulShellBranch(
            routes: requestManageRoutes,
          ),
          StatefulShellBranch(
            routes: customerConnectionRoutes,
          ),
          StatefulShellBranch(
            routes: notificationsRoutes,
          ),
          StatefulShellBranch(
            routes: profileSettingsRoutes,
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            VendorShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              vendorHomeRoute(routes: [subscriptionNestedRoute]),
              ...subscriptionRoutes,
              ...vendorNotificationsRoutes,
              ...vendorAbuseRoutes,
              ...vendorReviewsRoutes,
            ],
          ),
          StatefulShellBranch(
            routes: requestFeedRoutes,
          ),
          StatefulShellBranch(
            routes: offersVendorTabRoutes,
          ),
          StatefulShellBranch(
            routes: connectionsTabRoutes,
          ),
          StatefulShellBranch(
            routes: vendorProfileSettingsRoutes,
          ),
        ],
      ),
    ],
  );
});
