import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/guards.dart';
import 'package:karat_hive/app/shells/customer_shell.dart';
import 'package:kh_l10n/kh_l10n.dart';

GoRouter _router() => GoRouter(
      initialLocation: AppGuards.customerHome,
      routes: [
        ShellRoute(
          builder: (_, __, child) => CustomerShell(child: child),
          routes: [
            GoRoute(
              path: AppGuards.customerHome,
              builder: (_, __) => const CustomerScreenPlaceholder('CUS-S02'),
            ),
            GoRoute(
              path: AppGuards.customerNotifications,
              builder: (_, __) => const CustomerScreenPlaceholder('CUS-S19'),
            ),
            GoRoute(
              path: AppGuards.customerProfile,
              builder: (_, __) => const CustomerScreenPlaceholder('CUS-S20'),
            ),
          ],
        ),
      ],
    );

Widget _app(GoRouter router) => MaterialApp.router(
      routerConfig: router,
      supportedLocales: KhStrings.supportedLocales,
      localizationsDelegates: KhStrings.delegates,
    );

void main() {
  testWidgets('Customer shell renders app bar + 3-tab bottom nav', (tester) async {
    await tester.pumpWidget(_app(_router()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-shell')), findsOneWidget);
    expect(find.text('CUS-S02'), findsOneWidget);

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.destinations.length, 3);
    expect(bar.selectedIndex, 0);
  });

  testWidgets('tapping a destination navigates and updates the selected index',
      (tester) async {
    await tester.pumpWidget(_app(_router()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('CUS-S20'), findsOneWidget);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 2);
  });
}
