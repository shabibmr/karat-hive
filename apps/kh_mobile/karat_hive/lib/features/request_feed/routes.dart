import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import 'presentation/request_detail_screen.dart';
import 'presentation/request_feed_screen.dart';
import 'presentation/vendor_dashboard_screen.dart';

/// Home tab root. Nested children (e.g. subscriptions) are attached by the app router.
GoRoute vendorHomeRoute({List<RouteBase> routes = const []}) => GoRoute(
      path: AppGuards.home,
      builder: (_, __) => const VendorDashboardScreen(),
      routes: routes,
    );

final requestFeedRoutes = [
  GoRoute(
    path: '/vendor/requests',
    builder: (_, __) => const RequestFeedScreen(),
    routes: [
      GoRoute(
        path: ':id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RequestDetailScreen(requestId: id);
        },
      ),
    ],
  ),
];
