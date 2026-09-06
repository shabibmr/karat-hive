import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/taxonomy/model/taxonomy_kind.dart';
import '../../features/taxonomy/presentation/taxonomy_screen.dart';
import '../auth/session_controller.dart';
import '../auth/session_state.dart';
import '../design/theme/kh_theme.dart';
import '../shell/kh_admin_scaffold.dart';

export 'taxonomy_query_params.dart';

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
          // Placeholder routes for navigation completeness
          ...kAdminNavItems
              .where((item) =>
                  item.route != '/' &&
                  item.route != '/taxonomy/categories' &&
                  item.route != '/taxonomy/regions')
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
