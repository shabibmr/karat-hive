import 'package:go_router/go_router.dart';

import 'presentation/connection_detail_screen.dart';
import 'presentation/connections_list_screen.dart';
import '../reviews/presentation/stubs.dart';

/// Customer Connections tab (CUS-S16 / CUS-S15 / CUS-S18).
final customerConnectionRoutes = [
  GoRoute(
    path: '/customer/connections',
    builder: (_, __) => const ConnectionsListScreen(),
    routes: [
      GoRoute(
        path: ':connectionId',
        builder: (context, state) => ConnectionDetailScreen(
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
