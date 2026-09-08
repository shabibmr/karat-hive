import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import 'presentation/stubs.dart';

final profileSettingsRoutes = [
  GoRoute(
    path: AppGuards.customerProfile,
    builder: (_, __) => const CustomerProfileScreen(),
    routes: [
      GoRoute(
        path: 'settings',
        builder: (_, __) => const CustomerSettingsScreen(),
      ),
    ],
  ),
];
