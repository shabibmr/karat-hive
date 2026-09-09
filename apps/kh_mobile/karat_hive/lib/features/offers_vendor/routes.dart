import 'package:go_router/go_router.dart';

import 'presentation/my_offers_screen.dart';
import 'presentation/offer_history_screen.dart';
import 'presentation/revise_offer_screen.dart';
import 'presentation/submit_offer_screen.dart';

/// Offers tab root + revise detail (VEN-S11 / VEN-S10) + history (VEN-S14).
final offersVendorTabRoutes = [
  GoRoute(
    path: '/vendor/offers',
    builder: (_, __) => const MyOffersScreen(),
    routes: [
      GoRoute(
        path: 'history',
        builder: (_, __) => const OfferHistoryScreen(),
      ),
      GoRoute(
        path: ':offerId',
        builder: (context, state) {
          final id = state.pathParameters['offerId']!;
          return ReviseOfferScreen(offerId: id);
        },
      ),
    ],
  ),
];

/// Nested under request detail: `/vendor/requests/:id/offer` (VEN-S09).
GoRoute submitOfferRoute() => GoRoute(
      path: 'offer',
      builder: (context, state) {
        final requestId = state.pathParameters['id']!;
        return SubmitOfferScreen(requestId: requestId);
      },
    );
