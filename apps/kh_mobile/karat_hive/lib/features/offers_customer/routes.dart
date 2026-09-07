import 'package:go_router/go_router.dart';

import 'presentation/stubs.dart';

final offersCustomerRoutes = [
  GoRoute(
    path: '/customer/requests/:requestId/offers',
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
  GoRoute(
    path: '/customer/offers/:offerId',
    builder: (context, state) => OfferDetailScreen(
      offerId: state.pathParameters['offerId']!,
    ),
    routes: [
      GoRoute(
        path: 'accept',
        builder: (context, state) => AcceptOfferScreen(
          offerId: state.pathParameters['offerId']!,
        ),
      ),
    ],
  ),
];
