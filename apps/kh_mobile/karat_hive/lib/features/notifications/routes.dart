import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import 'presentation/stubs.dart';

final notificationsRoutes = [
  GoRoute(
    path: AppGuards.customerAlerts,
    builder: (_, __) => const NotificationCentreScreen(),
  ),
];
