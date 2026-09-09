import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import 'presentation/stubs.dart';
import 'presentation/vendor_notification_centre_screen.dart';

/// Customer alerts tab root (CUS-S19) — path `/customer/alerts`.
final notificationsRoutes = [
  GoRoute(
    path: AppGuards.customerAlerts,
    builder: (_, __) => const NotificationCentreScreen(),
  ),
];

/// Vendor notification centre (VEN-S17) — path `/vendor/notifications`.
/// Mounted on the Vendor home shell branch (bell / push entry, not a bottom tab).
final vendorNotificationsRoutes = [
  GoRoute(
    path: AppGuards.vendorNotifications,
    builder: (_, __) => const VendorNotificationCentreScreen(),
  ),
];
