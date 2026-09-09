import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/features/auth/presentation/login_screen.dart';
import 'package:kh_admin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_kind.dart';
import 'package:kh_admin/features/taxonomy/presentation/taxonomy_screen.dart';
import 'package:kh_admin/features/verification/presentation/verification_screen.dart';
import 'package:kh_admin/core/router/verification_query_params.dart';
import 'package:kh_admin/features/abuse/presentation/abuse_screen.dart';
import 'package:kh_admin/features/admin_users/presentation/admin_users_screen.dart';
import 'package:kh_admin/features/announcements/presentation/announcements_screen.dart';
import 'package:kh_admin/features/audit/presentation/audit_screen.dart';
import 'package:kh_admin/features/connections/presentation/connection_detail_screen.dart';
import 'package:kh_admin/features/connections/presentation/connection_list_screen.dart';
import 'package:kh_admin/features/customers/presentation/customer_detail_screen.dart';
import 'package:kh_admin/features/customers/presentation/customer_list_screen.dart';
import 'package:kh_admin/features/moderation/presentation/moderation_screen.dart';
import 'package:kh_admin/features/reports/presentation/reports_screen.dart';
import 'package:kh_admin/features/settings/presentation/platform_settings_screen.dart';
import 'package:kh_admin/features/offers/presentation/offer_detail_screen.dart';
import 'package:kh_admin/features/offers/presentation/offer_list_screen.dart';
import 'package:kh_admin/features/requests/presentation/request_detail_screen.dart';
import 'package:kh_admin/features/requests/presentation/request_list_screen.dart';
import 'package:kh_admin/features/vendors/presentation/vendor_detail_screen.dart';
import 'package:kh_admin/features/vendors/presentation/vendor_list_screen.dart';
import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/auth/session_state.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/shell/kh_admin_scaffold.dart';

export 'taxonomy_query_params.dart';
export 'verification_query_params.dart';

/// Riverpod change notifier bridge for GoRouter refreshListenable.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen<SessionState>(
      sessionControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final session = ref.read(sessionControllerProvider);
    final isLoggingIn = state.matchedLocation == '/login';

    // While resolving initial token/session state, stay on splash/login
    if (session.isLoading) {
      return null;
    }

    if (!session.isAuthenticated) {
      return isLoggingIn ? null : '/login';
    }

    // Authenticated admin trying to visit /login -> redirect to default dashboard
    if (isLoggingIn) {
      return '/';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => KhAdminScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/taxonomy/categories',
            builder: (context, state) => const TaxonomyScreen(
              kind: TaxonomyKind.category,
            ),
          ),
          GoRoute(
            path: '/taxonomy/regions',
            builder: (context, state) => const TaxonomyScreen(
              kind: TaxonomyKind.region,
            ),
          ),
          GoRoute(
            path: '/vendors',
            builder: (context, state) => const VendorListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return VendorDetailScreen(vendorId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/verification',
            builder: (context, state) {
              final query = VerificationQueryParams.fromState(state);
              return VerificationScreen(initialSelectedId: query.selectedId);
            },
          ),
          GoRoute(
            path: '/offers',
            builder: (context, state) => const OfferListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return OfferDetailScreen(offerId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/requests',
            builder: (context, state) => const RequestListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return RequestDetailScreen(requestId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomerListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return CustomerDetailScreen(customerId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/connections',
            builder: (context, state) => const ConnectionListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return ConnectionDetailScreen(connectionId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/audit',
            builder: (context, state) => const AuditScreen(),
          ),
          GoRoute(
            path: '/abuse',
            builder: (context, state) => const AbuseScreen(),
          ),
          GoRoute(
            path: '/moderation',
            builder: (context, state) => const ModerationScreen(),
          ),
          GoRoute(
            path: '/admin-users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const PlatformSettingsScreen(),
          ),
          GoRoute(
            path: '/announcements',
            builder: (context, state) => const AnnouncementsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          // Placeholder routes for navigation completeness
          ...kAdminNavItems
              .where((item) => !item.isLive)
              .map(
                (item) => GoRoute(
                  path: item.route,
                  builder: (context, state) => _GenericPlaceholderScreen(
                    title: item.title,
                    screenId: item.id,
                  ),
                ),
              ),
        ],
      ),
    ],
  );
});

class _GenericPlaceholderScreen extends StatelessWidget {
  const _GenericPlaceholderScreen({
    required this.title,
    required this.screenId,
  });

  final String title;
  final String screenId;

  @override
  Widget build(BuildContext context) {
    final typography = context.kh.typography;
    final colors = context.kh.colors;
    final spacing = context.kh.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title ($screenId)', style: typography.displayL),
          SizedBox(height: spacing.sm),
          Text(
            'This administrative vertical is scheduled for an upcoming milestone.',
            style: typography.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
