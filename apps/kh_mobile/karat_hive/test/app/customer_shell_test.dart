import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/shells/customer_shell.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

GoRouter _router() => GoRouter(
  initialLocation: AppGuards.customerHome,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          CustomerShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppGuards.customerHome,
              builder: (_, __) => const Text('CUS-S02'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppGuards.customerRequests,
              builder: (_, __) => const Text('CUS-S10'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppGuards.customerConnections,
              builder: (_, __) => const Text('CUS-S16'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppGuards.customerAlerts,
              builder: (_, __) => const Text('CUS-S19'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppGuards.customerProfile,
              builder: (_, __) => const Text('CUS-S20'),
            ),
          ],
        ),
      ],
    ),
  ],
);

Widget _app(GoRouter router) => MaterialApp.router(
  theme: khTheme(),
  routerConfig: router,
  supportedLocales: KhStrings.supportedLocales,
  localizationsDelegates: KhStrings.delegates,
);

void main() {
  testWidgets('Customer shell renders the four reference tabs', (tester) async {
    await tester.pumpWidget(_app(_router()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-shell')), findsOneWidget);
    expect(find.text('CUS-S02'), findsOneWidget);

    final bar = tester.widget<KhBottomNav>(find.byType(KhBottomNav));
    expect(bar.destinations.length, 4);
    expect(bar.currentIndex, 0);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Alerts'), findsNothing);
  });

  testWidgets(
    'tapping a destination navigates and updates the selected index',
    (tester) async {
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.text('CUS-S20'), findsOneWidget);
      final bar = tester.widget<KhBottomNav>(find.byType(KhBottomNav));
      expect(bar.currentIndex, 3);
    },
  );

  testWidgets('Alerts deep links remain accessible without a visible tab', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();
    router.go(AppGuards.customerAlerts);
    await tester.pumpAndSettle();
    expect(find.text('CUS-S19'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('CUS-S20'), findsOneWidget);
  });
}
