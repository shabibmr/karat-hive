import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import 'presentation/guest_landing_screen.dart';

final guestRoutes = [
  GoRoute(
    path: AppGuards.customerGuest,
    builder: (_, __) => const GuestLandingScreen(),
  ),
];
