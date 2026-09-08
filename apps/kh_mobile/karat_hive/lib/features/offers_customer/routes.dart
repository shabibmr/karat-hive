import 'package:go_router/go_router.dart';

import 'presentation/stubs.dart';

/// Offer detail / accept — list+compare nest under request_manage (CUS-S10).
final offersCustomerRoutes = [
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
