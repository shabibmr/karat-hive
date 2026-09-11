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
import '../features/abuse/routes.dart';
import '../features/auth/routes.dart';
import '../features/connections/routes.dart';
import '../features/connections_customer/routes.dart';
import '../features/notifications/routes.dart';
import '../features/offers_customer/routes.dart';
import '../features/offers_vendor/routes.dart';
import '../features/onboarding/routes.dart';
import '../features/profile_settings/routes.dart';
import '../features/request_create/controller/request_create_controller.dart';
import '../features/request_create/pending_publish_intent.dart';
import '../features/request_create/routes.dart';
import '../features/request_feed/routes.dart';
import '../features/request_manage/routes.dart';
import '../features/reviews/routes.dart';
import '../features/subscription/routes.dart';

class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, next) {
      // Reset draft + clear intent before notify so redirect stays pure (GL-16/61).
      clearPendingPublishIfVendor(
        next,
        ref.read(pendingPublishIntentProvider),
        () => ref.read(pendingPublishIntentProvider.notifier).clearPending(),
        resetCreate: () =>
            ref.read(requestCreateControllerProvider.notifier).resetFlow(),
      );
      notifyListeners();
    });
    ref.listen(pendingPublishIntentProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _SessionListenable(ref);
  return GoRouter(
    initialLocation: AppGuards.splash,
    refreshListenable: listenable,
    redirect: (context, state) => AppGuards.redirect(
      ref.read(sessionProvider),
      state.matchedLocation,
      pendingPublish: ref.read(pendingPublishIntentProvider),
    ),
    routes: [
      GoRoute(path: AppGuards.splash, builder: (_, __) => const SplashScreen()),
      ShellRoute(
        builder: (context, state, child) => UnauthShell(child: child),
        routes: authRoutes,
      ),
      ShellRoute(
        builder: (context, state, child) => AwaitingApprovalShell(child: child),
        routes: onboardingRoutes,
      ),
      // Create flow is top-level so Guest (SignedOut) can compose without Customer shell nav.
      ...requestCreateRoutes,
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
          StatefulShellBranch(routes: requestManageRoutes),
          StatefulShellBranch(routes: customerConnectionRoutes),
          StatefulShellBranch(routes: notificationsRoutes),
          StatefulShellBranch(routes: profileSettingsRoutes),
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
          StatefulShellBranch(routes: requestFeedRoutes),
          StatefulShellBranch(routes: offersVendorTabRoutes),
          StatefulShellBranch(routes: connectionsTabRoutes),
          StatefulShellBranch(routes: vendorProfileSettingsRoutes),
        ],
      ),
    ],
  );
});
