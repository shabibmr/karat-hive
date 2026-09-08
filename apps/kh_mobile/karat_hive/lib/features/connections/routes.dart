import 'package:go_router/go_router.dart';

import 'presentation/connections_list_screen.dart';
import 'presentation/connections_screen.dart';
import 'presentation/customer_connection_detail_screen.dart';
import 'presentation/vendor_connection_detail_screen.dart';
import '../reviews/presentation/stubs.dart';

/// Vendor Connections tab root + detail (VEN-S12 / VEN-S13).
final connectionsTabRoutes = [
  GoRoute(
    path: '/vendor/connections',
    builder: (_, __) => const ConnectionsScreen(),
    routes: [
      GoRoute(
        path: ':connectionId',
        builder: (context, state) {
          final id = state.pathParameters['connectionId']!;
          return VendorConnectionDetailScreen(connectionId: id);
        },
      ),
    ],
  ),
];

/// Customer Connections tab (CUS-S15 / CUS-S16 / CUS-S18).
final customerConnectionRoutes = [
  GoRoute(
    path: '/customer/connections',
    builder: (_, __) => const ConnectionsListScreen(),
    routes: [
      GoRoute(
        path: ':connectionId',
        builder: (context, state) => CustomerConnectionDetailScreen(
          connectionId: state.pathParameters['connectionId']!,
        ),
        routes: [
          GoRoute(
            path: 'review',
            builder: (context, state) => LeaveReviewScreen(
              connectionId: state.pathParameters['connectionId']!,
            ),
          ),
        ],
      ),
    ],
  ),
];

/// Alias for customer shell mounting
final connectionsRoutes = customerConnectionRoutes;
