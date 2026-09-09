import 'package:go_router/go_router.dart';

import 'presentation/leave_review_screen.dart';
import 'presentation/my_reviews_screen.dart';

/// CUS-S18 is nested under customer connections (`:connectionId/review`).
final reviewsRoutes = <RouteBase>[];

/// Nested under `/vendor/connections/:connectionId` (VEN-S19).
/// Leave-review UI lands in CP5-B03.3; Close → navigate in CP5-B03.4.
final vendorLeaveReviewRoute = GoRoute(
  path: 'review',
  builder: (context, state) => VendorLeaveReviewScreen(
    connectionId: state.pathParameters['connectionId']!,
  ),
);

/// VEN-S20 — path `/vendor/reviews`. List UI lands in CP5-B04.
final vendorReviewsRoutes = [
  GoRoute(
    path: '/vendor/reviews',
    builder: (_, __) => const MyReviewsScreen(),
  ),
];
