import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/app/shells/vendor_shell.dart';
import 'package:karat_hive/features/notifications/presentation/vendor_notification_centre_screen.dart';
import 'package:karat_hive/features/notifications/repository/notifications_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../helpers/fake_session.dart';

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository(this.items);

  final List<AppNotification> items;
  final List<String> markReadIds = [];

  @override
  Future<Result<PagedResult<AppNotification>>> list({
    bool? unread,
    String? cursor,
    int limit = 20,
  }) async {
    return Ok(
      PagedResult<AppNotification>(
        items: items,
        nextCursor: null,
      ),
    );
  }

  @override
  Future<Result<AppNotification>> markRead(String id) async {
    markReadIds.add(id);
    final existing = items.where((n) => n.id == id).firstOrNull;
    if (existing == null) {
      return const Err(NotFoundFailure(message: 'notification not found'));
    }
    final updated = AppNotification(
      id: existing.id,
      type: existing.type,
      title: existing.title,
      body: existing.body,
      deepLink: existing.deepLink,
      isCritical: existing.isCritical,
      createdAt: existing.createdAt,
      readAt: existing.readAt ?? DateTime.utc(2026, 9, 8),
    );
    final index = items.indexWhere((n) => n.id == id);
    if (index >= 0) items[index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<void>> markAllRead() async {
    fail('mark-all-read is exercised in mark_read_test');
  }
}

void main() {
  const requestId = '11111111-1111-1111-1111-111111111111';

  testWidgets(
    'VEN-S17 tap resolves /requests/{id} through the Vendor shell',
    (tester) async {
      final session = SignedIn(
        testVendorUser(vendor: testVendorMe(lifecycle: VendorLifecycle.active)),
      );
      final repo = _FakeNotificationsRepository([
        AppNotification(
          id: 'n1',
          type: 'request.matched',
          title: 'New Request',
          body: 'A Request matched your Categories.',
          deepLink: '/requests/$requestId',
          isCritical: false,
          createdAt: DateTime.utc(2026, 9, 1),
        ),
      ]);

      final router = GoRouter(
        initialLocation: AppGuards.vendorNotifications,
        redirect: (context, state) =>
            AppGuards.redirect(session, state.matchedLocation),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                VendorShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppGuards.home,
                    builder: (_, __) => const Text('home-body'),
                  ),
                  GoRoute(
                    path: AppGuards.vendorNotifications,
                    builder: (_, __) => const VendorNotificationCentreScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/vendor/requests',
                    builder: (_, __) => const Text('requests-list'),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => Text(
                          'request-${state.pathParameters['id']}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/vendor/offers',
                    builder: (_, __) => const Text('offers-body'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/vendor/connections',
                    builder: (_, __) => const Text('connections-body'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppGuards.vendorProfile,
                    builder: (_, __) => const Text('profile-body'),
                    routes: [
                      GoRoute(
                        path: 'documents',
                        builder: (_, __) => const Text('documents-body'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(
              () => FakeSessionController(session),
            ),
            notificationsRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp.router(
            theme: khTheme(),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.byKey(VendorNotificationCentreScreen.screenKey),
        findsOneWidget,
      );
      expect(find.text('New Request'), findsOneWidget);

      await tester.tap(find.text('New Request'));
      await tester.pumpAndSettle();

      expect(find.text('request-$requestId'), findsOneWidget);
      expect(router.state.uri.path, '/vendor/requests/$requestId');
    },
  );
}
