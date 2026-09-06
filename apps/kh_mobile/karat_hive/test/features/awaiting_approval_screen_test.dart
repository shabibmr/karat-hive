import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/onboarding/controller/vendor_me_controller.dart';
import 'package:karat_hive/features/onboarding/presentation/awaiting_approval_screen.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../helpers/fake_session.dart';

Widget _host({required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      home: const AwaitingApprovalScreen(),
    ),
  );
}

void main() {
  testWidgets('shows status, admin message, and pending-documents copy', (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionController(SignedIn(testVendorUser())),
          ),
          vendorMeProvider.overrideWith((ref) async => testVendorMe()),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Verification in progress'), findsOneWidget);
    expect(find.byKey(const Key('vendor-status-card')), findsOneWidget);
    expect(find.text('Al Noor'), findsOneWidget);
    expect(find.text('Upload your business documents to continue.'), findsOneWidget);
    expect(find.text('Please re-upload the trade licence.'), findsOneWidget);
    expect(find.text('Upload documents'), findsOneWidget);
  });

  testWidgets('verified vendor sees the categories-and-regions CTA', (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionController(
              SignedIn(
                testVendorUser(
                  vendor: testVendorMe(
                    lifecycle: VendorLifecycle.verified,
                    awaitingApprovalReason: AwaitingApprovalReason.categoriesRequired,
                    verificationMessage: null,
                  ),
                ),
              ),
            ),
          ),
          vendorMeProvider.overrideWith(
            (ref) async => testVendorMe(
              lifecycle: VendorLifecycle.verified,
              awaitingApprovalReason: AwaitingApprovalReason.categoriesRequired,
              verificationMessage: null,
            ),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Choose the categories and regions you serve.'), findsOneWidget);
    expect(find.text('Categories & regions'), findsOneWidget);
  });

  testWidgets('renders SH-FND-13 when vendor me fails', (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionController(SignedIn(testVendorUser())),
          ),
          vendorMeProvider.overrideWith(
            (ref) async => throw const ServerFailure(message: 'down'),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Could not load your status.'), findsOneWidget);
  });
}
