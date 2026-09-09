import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import 'presentation/business_profile_screen.dart';
import 'presentation/categories_regions_screen.dart';
import 'presentation/settings_screen.dart';
import 'presentation/stubs.dart';

/// Customer profile tab (CUS-S20) + nested settings (CUS-S21).
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

/// Awaiting-shell mount for VEN-S16 (VERIFIED → ACTIVE gate). Same screen as
/// [AppGuards.vendorProfileCategories]; path stays in `AppGuards.awaitingRoutes`.
final categoriesRegionsAwaitingRoute = GoRoute(
  path: AppGuards.categories,
  builder: (_, __) => const CategoriesRegionsScreen(),
);

/// Vendor profile tab root (VEN-S15) + nested settings (VEN-S18) + VEN-S16.
/// `/documents` resolves §7.2 deep links until VEN-S15 document UI (CP6-B02).
final vendorProfileSettingsRoutes = [
  GoRoute(
    path: AppGuards.vendorProfile,
    builder: (_, __) => const BusinessProfileScreen(),
    routes: [
      GoRoute(
        path: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: 'categories-regions',
        builder: (_, __) => const CategoriesRegionsScreen(),
      ),
      GoRoute(
        path: 'documents',
        builder: (_, __) => const VendorProfileDocumentsStub(),
      ),
    ],
  ),
];
