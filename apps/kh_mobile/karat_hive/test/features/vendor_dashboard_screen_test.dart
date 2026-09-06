import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/dashboard/presentation/vendor_dashboard_screen.dart';
import 'package:karat_hive/features/dashboard/repository/dashboard_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../helpers/fake_session.dart';

Widget _host({
  required List<Override> overrides,
  required Widget child,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  testWidgets('renders zeroed counts, gold-rate placeholder, and empty subscriptions',
      (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionController(
              SignedIn(
                testVendorUser(
                  vendor: testVendorMe(lifecycle: VendorLifecycle.active),
                ),
              ),
            ),
          ),
          vendorDashboardProvider.overrideWith(
            (ref) async => const VendorDashboard(
              newRequests: 0,
              pendingOffers: 0,
              activeConnections: 0,
              ratingAverage: null,
              reviewCount: 0,
            ),
          ),
        ],
        child: const VendorDashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.byKey(const Key('vendor-status-card')), findsOneWidget);
    expect(find.text('Al Noor'), findsOneWidget);
    expect(find.text('New requests'), findsOneWidget);
    expect(find.text('No reviews yet'), findsOneWidget);
    expect(find.text('Reference rates unavailable'), findsOneWidget);
    expect(find.text('No type subscriptions yet'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('empty-view')),
      200,
    );
    expect(find.byKey(const Key('empty-view')), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('renders SH-FND-13 error view when the dashboard fails to load',
      (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionController(
              SignedIn(
                testVendorUser(
                  vendor: testVendorMe(lifecycle: VendorLifecycle.active),
                ),
              ),
            ),
          ),
          vendorDashboardProvider.overrideWith(
            (ref) async => throw const ServerFailure(message: 'down'),
          ),
        ],
        child: const VendorDashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load your dashboard.'), findsOneWidget);
  });
}
