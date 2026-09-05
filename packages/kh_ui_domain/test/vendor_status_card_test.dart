import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('renders trading name, lifecycle, and admin message', (tester) async {
    await tester.pumpWidget(
      _host(
        const VendorStatusCard(
          lifecycle: VendorLifecycle.pendingVerification,
          tradingName: 'Al Noor Jewellery LLC',
          lifecycleLabel: 'Under review',
          subtitle: 'Our team is reviewing your documents.',
          verificationMessage: 'Please re-upload the trade licence.',
        ),
      ),
    );

    expect(find.byKey(const Key('vendor-status-card')), findsOneWidget);
    expect(find.text('Al Noor Jewellery LLC'), findsOneWidget);
    expect(find.text('Under review'), findsOneWidget);
    expect(find.text('Our team is reviewing your documents.'), findsOneWidget);
    expect(find.text('Please re-upload the trade licence.'), findsOneWidget);
  });

  testWidgets('ACTIVE chip includes a verification mark', (tester) async {
    await tester.pumpWidget(
      _host(
        const VendorStatusCard(
          lifecycle: VendorLifecycle.active,
          tradingName: 'Al Noor',
          lifecycleLabel: 'Active',
        ),
      ),
    );

    expect(find.byIcon(Icons.verified), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });
}
