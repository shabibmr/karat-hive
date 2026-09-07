import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import '../reviews/presentation/stubs.dart';
import 'presentation/stubs.dart';

final connectionsRoutes = [
  GoRoute(
    path: AppGuards.customerConnections,
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
