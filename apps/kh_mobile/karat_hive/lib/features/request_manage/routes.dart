import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import '../offers_customer/presentation/customer_offers_list_screen.dart';
import '../offers_customer/presentation/offer_comparison_screen.dart';
import 'presentation/customer_home_screen.dart';
import 'presentation/my_requests_screen.dart';
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
    // My Requests tab — open/live list (not Home dashboard).
    builder: (_, __) => const MyRequestsScreen(),
    routes: [
      GoRoute(
        path: ':requestId',
        builder: (context, state) => OwnerRequestDetailScreen(
          requestId: state.pathParameters['requestId']!,
        ),
        routes: [
          GoRoute(
            path: 'offers',
            builder: (context, state) => CustomerOffersListScreen(
              requestId: state.pathParameters['requestId']!,
            ),
          ),
          GoRoute(
            path: 'compare',
            builder: (context, state) {
              final ids = (state.uri.queryParameters['ids'] ?? '')
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(growable: false);
              return OfferComparisonScreen(
                requestId: state.pathParameters['requestId']!,
                offerIds: ids,
              );
            },
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
