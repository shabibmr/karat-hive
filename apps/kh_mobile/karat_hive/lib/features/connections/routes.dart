import 'package:go_router/go_router.dart';

import '../reviews/routes.dart';
import 'presentation/connection_detail_screen.dart';
import 'presentation/connections_screen.dart';

/// Connections tab root + detail (VEN-S12 / VEN-S13 / VEN-S19).
final connectionsTabRoutes = [
  GoRoute(
    path: '/vendor/connections',
    builder: (_, __) => const ConnectionsScreen(),
    routes: [
      GoRoute(
        path: ':connectionId',
        builder: (context, state) {
          final id = state.pathParameters['connectionId']!;
          return ConnectionDetailScreen(connectionId: id);
        },
        routes: [vendorLeaveReviewRoute],
      ),
    ],
  ),
];
