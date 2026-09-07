import 'package:go_router/go_router.dart';

import 'presentation/customer_home_screen.dart';
import 'presentation/owner_request_detail_screen.dart';
import 'presentation/request_history_screen.dart';

/// Paths for Track G to assemble. This file is not mounted from router.dart here.
final requestManageRoutes = <RouteBase>[
  GoRoute(
    path: '/customer',
    builder: (_, __) => const CustomerHomeScreen(),
  ),
  GoRoute(
    path: '/customer/history',
    builder: (_, __) => const RequestHistoryScreen(),
  ),
  GoRoute(
    path: '/customer/requests/:requestId',
    builder: (context, state) => OwnerRequestDetailScreen(
      requestId: state.pathParameters['requestId']!,
    ),
  ),
];
