import 'package:go_router/go_router.dart';

import 'presentation/stubs.dart';

final reviewsRoutes = [
  GoRoute(
    path: '/customer/connections/:connectionId/review',
    builder: (context, state) => LeaveReviewScreen(
      connectionId: state.pathParameters['connectionId']!,
    ),
  ),
];
