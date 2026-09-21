import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/features/auth/presentation/login_screen.dart';
import 'package:kh_admin/features/auth/presentation/splash_screen.dart';
import 'package:kh_admin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_kind.dart';
import 'package:kh_admin/features/taxonomy/presentation/taxonomy_screen.dart';
import 'package:kh_admin/features/verification/presentation/verification_screen.dart';
import 'package:kh_admin/core/router/verification_query_params.dart';
import 'package:kh_admin/features/abuse/presentation/abuse_screen.dart';
import 'package:kh_admin/features/admin_users/presentation/admin_users_screen.dart';
import 'package:kh_admin/features/announcements/presentation/announcements_screen.dart' deferred as announcements_screen;
import 'package:kh_admin/features/audit/presentation/audit_screen.dart' deferred as audit_screen;
import 'package:kh_admin/features/connections/presentation/connection_detail_screen.dart';
import 'package:kh_admin/features/connections/presentation/connection_list_screen.dart';
import 'package:kh_admin/features/customers/presentation/customer_detail_screen.dart';
import 'package:kh_admin/features/customers/presentation/customer_list_screen.dart';
import 'package:kh_admin/features/moderation/presentation/moderation_screen.dart';
import 'package:kh_admin/features/reports/presentation/reports_screen.dart' deferred as reports_screen;
import 'package:kh_admin/features/settings/presentation/platform_settings_screen.dart';
import 'package:kh_admin/features/offers/presentation/offer_detail_screen.dart';
import 'package:kh_admin/features/offers/presentation/offer_list_screen.dart';
import 'package:kh_admin/features/requests/presentation/request_detail_screen.dart';
import 'package:kh_admin/features/requests/presentation/request_list_screen.dart';
import 'package:kh_admin/features/vendors/presentation/vendor_detail_screen.dart';
import 'package:kh_admin/features/vendors/presentation/vendor_list_screen.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/auth/admin_role.dart';
import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/auth/session_state.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/router/admin_routes.dart';
import 'package:kh_admin/core/shell/kh_admin_scaffold.dart';
import 'package:kh_admin/features/contract_version/presentation/contract_mismatch_screen.dart';

export 'admin_routes.dart';
export 'taxonomy_query_params.dart';
export 'verification_query_params.dart';

/// Riverpod change notifier bridge for GoRouter refreshListenable.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen<SessionState>(
      sessionControllerProvider,
      (_, __) => notifyListeners(),
    );
    ref.listen<bool>(
      contractMismatchProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final hasMismatch = ref.read(contractMismatchProvider);
    final isMismatchRoute = state.matchedLocation == AdminRoutes.contractMismatch;
    if (hasMismatch) {
      return isMismatchRoute ? null : AdminRoutes.contractMismatch;
    }

    final session = ref.read(sessionControllerProvider);
    final matched = state.matchedLocation;
    final isLoggingIn = matched == AdminRoutes.login;
    final isSplash = matched == AdminRoutes.splash;

    // First resolution not finished yet: park on the splash route rather than
    // letting the request through. Returning `null` here used to admit the
    // initial location (`/`), so the shell and dashboard mounted and fired
    // their admin API calls before anyone was signed in, then snapped back to
    // /login. The deep link rides along in `from`, so it still survives.
    if (!session.bootstrapped) {
      if (isSplash || isLoggingIn) return null;
      return '${AdminRoutes.splash}?from=${Uri.encodeComponent(state.uri.toString())}';
    }

    // Post-bootstrap transient loading (a login in flight): keep the current
    // URL — the login screen owns its own progress indicator.
    if (session.isLoading) {
      return null;
    }

    final intended = _intendedLocation(state.uri.queryParameters['from']);

    if (!session.isAuthenticated) {
      if (isLoggingIn) return null;
      if (isSplash) {
        return intended == null
            ? AdminRoutes.login
            : '${AdminRoutes.login}?from=${Uri.encodeComponent(intended)}';
      }
      if (matched == AdminRoutes.contractMismatch) return AdminRoutes.login;
      final from = Uri.encodeComponent(state.uri.toString());
      return '${AdminRoutes.login}?from=$from';
    }

    // Every protected destination is checked against the Admin role as well
    // as the authenticated session. Backend AdminGuard remains authoritative.
    final adminRole = session.admin?.role;
    if (adminRole == null) {
      return AdminRoutes.login;
    }
    if (!AdminAccess(adminRole).canRoute(matched)) {
      return AdminRoutes.dashboard;
    }

    // Authenticated admin on /login or /splash → restore `from`, else dashboard.
    if (isLoggingIn || isSplash) {
      return intended ?? AdminRoutes.dashboard;
    }

    return null;
  }

  /// Decodes a `from` query parameter into a safe in-app destination.
  ///
  /// Rejects anything that is not a local path, and the two holding routes
  /// themselves — restoring `/login` or `/splash` would loop the guard.
  static String? _intendedLocation(String? from) {
    if (from == null || from.isEmpty) return null;
    final decoded = Uri.decodeComponent(from);
    if (!decoded.startsWith('/') || decoded.startsWith('//')) return null;
    final path = Uri.tryParse(decoded)?.path;
    if (path == AdminRoutes.login || path == AdminRoutes.splash) return null;
    return decoded;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AdminRoutes.dashboard,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AdminRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AdminRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AdminRoutes.contractMismatch,
        builder: (context, state) => const ContractMismatchScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => KhAdminScaffold(child: child),
        routes: [
          GoRoute(
            path: AdminRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AdminRoutes.categories,
            builder: (context, state) => const TaxonomyScreen(
              kind: TaxonomyKind.category,
            ),
          ),
          GoRoute(
            path: AdminRoutes.regions,
            builder: (context, state) => const TaxonomyScreen(
              kind: TaxonomyKind.region,
            ),
          ),
          GoRoute(
            path: AdminRoutes.vendors,
            builder: (context, state) => const VendorListScreen(),
            routes: [
              GoRoute(
                path: AdminRoutes.vendorDetail,
                redirect: (context, state) {
                  final id = state.pathParameters['id']?.trim() ?? '';
                  return id.isEmpty ? AdminRoutes.vendors : null;
                },
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return VendorDetailScreen(vendorId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AdminRoutes.verification,
            builder: (context, state) {
              final query = VerificationQueryParams.fromState(state);
              return VerificationScreen(initialSelectedId: query.selectedId);
            },
          ),
          GoRoute(
            path: AdminRoutes.offers,
            builder: (context, state) => const OfferListScreen(),
            routes: [
              GoRoute(
                path: AdminRoutes.offerDetail,
                redirect: (context, state) {
                  final id = state.pathParameters['id']?.trim() ?? '';
                  return id.isEmpty ? AdminRoutes.offers : null;
                },
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return OfferDetailScreen(offerId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AdminRoutes.requests,
            builder: (context, state) => const RequestListScreen(),
            routes: [
              GoRoute(
                path: AdminRoutes.requestDetail,
                redirect: (context, state) {
                  final id = state.pathParameters['id']?.trim() ?? '';
                  return id.isEmpty ? AdminRoutes.requests : null;
                },
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return RequestDetailScreen(requestId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AdminRoutes.customers,
            builder: (context, state) => const CustomerListScreen(),
            routes: [
              GoRoute(
                path: AdminRoutes.customerDetail,
                redirect: (context, state) {
                  final id = state.pathParameters['id']?.trim() ?? '';
                  return id.isEmpty ? AdminRoutes.customers : null;
                },
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return CustomerDetailScreen(customerId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AdminRoutes.connections,
            builder: (context, state) => const ConnectionListScreen(),
            routes: [
              GoRoute(
                path: AdminRoutes.connectionDetail,
                redirect: (context, state) {
                  final id = state.pathParameters['id']?.trim() ?? '';
                  return id.isEmpty ? AdminRoutes.connections : null;
                },
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return ConnectionDetailScreen(connectionId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AdminRoutes.audit,
            builder: (context, state) => DeferredScreen(
              loader: audit_screen.loadLibrary,
              builder: () => audit_screen.AuditScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.abuse,
            builder: (context, state) => const AbuseScreen(),
          ),
          GoRoute(
            path: AdminRoutes.moderation,
            builder: (context, state) => const ModerationScreen(),
          ),
          GoRoute(
            path: AdminRoutes.adminUsers,
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: AdminRoutes.settings,
            builder: (context, state) => const PlatformSettingsScreen(),
          ),
          GoRoute(
            path: AdminRoutes.announcements,
            builder: (context, state) => DeferredScreen(
              loader: announcements_screen.loadLibrary,
              builder: () => announcements_screen.AnnouncementsScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.reports,
            builder: (context, state) => DeferredScreen(
              loader: reports_screen.loadLibrary,
              builder: () => reports_screen.ReportsScreen(),
            ),
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

/// Lazily loads a deferred library and displays a spinner while resolving (TR-S4-11).
class DeferredScreen extends StatefulWidget {
  const DeferredScreen({
    super.key,
    required this.loader,
    required this.builder,
  });

  final Future<void> Function() loader;
  final Widget Function() builder;

  @override
  State<DeferredScreen> createState() => _DeferredScreenState();
}

class _DeferredScreenState extends State<DeferredScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load module: ${snapshot.error}',
                style: context.kh.typography.body,
              ),
            );
          }
          return widget.builder();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

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

