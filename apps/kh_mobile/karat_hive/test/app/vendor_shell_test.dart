import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/shells/vendor_shell.dart';

void main() {
  testWidgets(
    'VendorShell mounts a NavigationBar with 5 destinations and keeps stacks',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/vendor/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                VendorShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/vendor/home',
                    builder: (_, __) => const Text('home-body'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/vendor/requests',
                    builder: (_, __) => const Text('requests-body'),
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
                    path: '/vendor/profile',
                    builder: (_, __) => const Text('profile-body'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(VendorShell), findsOneWidget);
      expect(find.byKey(const Key('vendor-shell')), findsOneWidget);
      expect(find.text('home-body'), findsOneWidget);

      final bars = tester.widgetList<NavigationBar>(find.byType(NavigationBar));
      for (final bar in bars) {
        expect(
          bar.destinations.length,
          greaterThanOrEqualTo(2),
          reason: 'NavigationBar requires destinations.length >= 2',
        );
        expect(bar.destinations.length, 5);
      }

      // Switch to Requests — Home branch stays mounted (indexed stack).
      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();
      expect(find.text('requests-body'), findsOneWidget);

      // Offers tab is live as of CP-3.
      await tester.tap(find.text('Offers'));
      await tester.pumpAndSettle();
      expect(find.text('offers-body'), findsOneWidget);

      // Connections remains gated until CP-4.
      await tester.tap(find.text('Connections'));
      await tester.pump();
      expect(
        find.text('Customer connections open in Check-Point 4.'),
        findsOneWidget,
      );
    },
  );
}
