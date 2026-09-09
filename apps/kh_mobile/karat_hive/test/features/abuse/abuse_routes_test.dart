import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/features/abuse/routes.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// Regression test for the bug where `/customer/abuse` (CUS-S22) rendered
/// with the Vendor abuse category list (VEN-S21) instead of the Customer
/// one, because [ReportAbuseScreen]'s defaults (`reporterRole: UserRole.vendor`,
/// `categories: kVendorAbuseCategories`) were never overridden by the route.
void main() {
  GoRouter buildRouter(String initialLocation) => GoRouter(
        initialLocation: initialLocation,
        routes: abuseRoutes,
      );

  testWidgets(
    '/customer/abuse (CUS-S22) renders customer categories, not vendor categories',
    (tester) async {
      final router = buildRouter(
        '/customer/abuse?entityType=REQUEST&entityId=req-1&reference=REQ-001',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: khTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // A category unique to kCustomerAbuseCategories must be present.
      expect(find.text('Fraudulent Offer'), findsOneWidget);

      // Categories unique to kVendorAbuseCategories must be absent.
      expect(
        find.text('Non-genuine / Fake Request Specifications'),
        findsNothing,
      );
      expect(find.text('Attempted External Off-platform Fraud'), findsNothing);
      expect(find.text('Suspected Non-genuine Item'), findsNothing);
    },
  );
}
