import 'package:go_router/go_router.dart';

import 'presentation/subscriptions_screen.dart';

/// Child of `/vendor/home` → `/vendor/home/subscriptions`.
final subscriptionNestedRoute = GoRoute(
  path: 'subscriptions',
  builder: (_, __) => const SubscriptionsScreen(),
);

/// Absolute path kept for existing deep links / navigation.
final subscriptionRoutes = [
  GoRoute(
    path: '/vendor/subscriptions',
    builder: (_, __) => const SubscriptionsScreen(),
  ),
];
