import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import '../offers_customer/presentation/stubs.dart';
import 'presentation/customer_home_screen.dart';
import 'presentation/owner_request_detail_screen.dart';
import 'presentation/request_history_screen.dart';

GoRoute customerHomeRoute({List<RouteBase> routes = const []}) => GoRoute(
      path: AppGuards.customerHome,
      builder: (_, __) => const CustomerHomeScreen(),
      routes: routes,
    );

final requestManageRoutes = [
  GoRoute(
    path: AppGuards.customerRequests,
    builder: (_, __) => const CustomerHomeScreen(),
    routes: [
      GoRoute(
        path: ':requestId',
        builder: (context, state) => OwnerRequestDetailScreen(
          requestId: state.pathParameters['requestId']!,
        ),
        routes: [
          GoRoute(
            path: 'offers',
            builder: (context, state) => OffersListScreen(
              requestId: state.pathParameters['requestId']!,
            ),
            routes: [
              GoRoute(
                path: 'compare',
                builder: (context, state) => OfferComparisonScreen(
                  requestId: state.pathParameters['requestId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/customer/history',
    builder: (_, __) => const RequestHistoryScreen(),
  ),
];
