import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/vendors/presentation/vendor_detail_screen.dart';
import 'package:kh_admin/features/vendors/repository/vendor_repository.dart';
import 'package:kh_admin/features/verification/model/vendor_verification_detail.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

class _FakeVendorDetailRepository extends VendorRepository {
  _FakeVendorDetailRepository() : super(ApiClient());

  VendorDetail? detailToReturn;
  bool shouldFail = false;
  bool suspendCalled = false;
  bool reactivateCalled = false;
  bool deactivateCalled = false;
  String? lastReasonCode;
  String? lastReasonText;

  @override
  Future<VendorDetail> fetchVendorDetail(String vendorId) async {
    if (shouldFail) throw Exception('Failed to load profile');
    return detailToReturn ??
        VendorDetail(
          id: vendorId,
          legalBusinessName: 'Al Noor Jewellery LLC',
          tradingName: 'Al Noor',
          tradeLicenceNumber: 'CN-1092834',
          licenceExpiryDate: DateTime.now().add(const Duration(days: 365)),
          businessAddress: 'Shop 14, Gold Centre Building, Deira, Dubai',
          contactPersonName: 'Ahmed Hassan',
          businessEmail: 'contact@alnoor.ae',
          mobileNumber: '+971 4 555 0101',
          verificationState: VendorVerificationState.verified,
          accountState: VendorAccountState.active,
          categories: const ['Gold Jewellery', 'Diamonds'],
          regions: const ['Dubai', 'Abu Dhabi'],
          documents: [
            VendorDocumentDetail(
              id: 'doc-1',
              documentType: 'TRADE_LICENCE',
              uploadedAt: DateTime(2026, 1, 15),
              fileName: 'trade_licence_2026.pdf',
              verified: true,
            ),
          ],
        );
  }

  @override
  Future<void> suspendVendor(
    String vendorId, {
    required String reasonCode,
    required String reasonText,
  }) async {
    suspendCalled = true;
    lastReasonCode = reasonCode;
    lastReasonText = reasonText;
    detailToReturn = detailToReturn?.copyWith(
      accountState: VendorAccountState.suspended,
    );
  }

  @override
  Future<void> reactivateVendor(
    String vendorId, {
    String reasonCode = 'ADMIN_REACTIVATED',
    String reasonText = 'KYC verified',
  }) async {
    reactivateCalled = true;
    lastReasonCode = reasonCode;
    lastReasonText = reasonText;
    detailToReturn = detailToReturn?.copyWith(
      accountState: VendorAccountState.active,
    );
  }

  @override
  Future<void> deactivateVendor(
    String vendorId, {
    required String reasonCode,
    required String reasonText,
  }) async {
    deactivateCalled = true;
    lastReasonCode = reasonCode;
    lastReasonText = reasonText;
    detailToReturn = detailToReturn?.copyWith(
      accountState: VendorAccountState.deactivated,
    );
  }
}

void main() {
  late _FakeVendorDetailRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeVendorDetailRepository();
  });

  Widget createVendorDetailWidget({String vendorId = 'ven-1'}) {
    final router = GoRouter(
      initialLocation: '/vendors/$vendorId',
      routes: [
        GoRoute(
          path: '/vendors',
          builder: (context, state) =>
              const Scaffold(body: Text('Vendors Directory List')),
        ),
        GoRoute(
          path: '/vendors/:id',
          builder: (context, state) => VendorDetailScreen(
            vendorId: state.pathParameters['id']!,
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        vendorRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp.router(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  testWidgets('renders full profile, categories, regions, and KYC documents',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createVendorDetailWidget());
    await tester.pumpAndSettle();

    // Header assertions
    expect(find.text('Al Noor Jewellery LLC'), findsWidgets);
    expect(find.text('VERIFIED'), findsWidgets);
    expect(find.text('ACTIVE'), findsOneWidget);

    // Profile card assertions
    expect(find.byKey(const Key('vendor-profile-card')), findsOneWidget);
    expect(find.text('CN-1092834'), findsOneWidget);
    expect(find.text('Shop 14, Gold Centre Building, Deira, Dubai'), findsOneWidget);
    expect(find.text('Ahmed Hassan'), findsOneWidget);
    expect(find.text('contact@alnoor.ae'), findsOneWidget);
    expect(find.text('+971 4 555 0101'), findsOneWidget);

    // Taxonomy chips
    expect(find.byKey(const Key('category-chip-Gold Jewellery')), findsOneWidget);
    expect(find.byKey(const Key('category-chip-Diamonds')), findsOneWidget);
    expect(find.byKey(const Key('region-chip-Dubai')), findsOneWidget);
    expect(find.byKey(const Key('region-chip-Abu Dhabi')), findsOneWidget);

    // KYC documents
    expect(find.byKey(const Key('vendor-doc-doc-1')), findsOneWidget);
    expect(find.text('TRADE LICENCE'), findsOneWidget);
    expect(find.text('trade_licence_2026.pdf'), findsOneWidget);

    // Active lifecycle action
    expect(find.byKey(const Key('vendor-suspend-button')), findsOneWidget);
    expect(find.byKey(const Key('vendor-deactivate-button')), findsOneWidget);
  });

  testWidgets('prompts suspend dialog with reason code and text, then suspends',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createVendorDetailWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('vendor-suspend-button')));
    await tester.pumpAndSettle();

    expect(find.text('Suspend Vendor Account'), findsOneWidget);
    expect(find.byKey(const Key('suspend-reason-code-field')), findsOneWidget);
    expect(find.byKey(const Key('suspend-reason-text-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('suspend-reason-text-field')),
      'Failed annual AML audit verification.',
    );
    await tester.tap(find.byKey(const Key('confirm-suspend-button')));
    await tester.pumpAndSettle();

    expect(fakeRepo.suspendCalled, isTrue);
    expect(fakeRepo.lastReasonCode, 'COMPLIANCE_BREACH');
    expect(fakeRepo.lastReasonText, 'Failed annual AML audit verification.');
    expect(find.byKey(const Key('vendor-action-feedback-banner')), findsOneWidget);
  });

  testWidgets('reactivates suspended vendor when KYC trade licence is unexpired',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeRepo.detailToReturn = VendorDetail(
      id: 'ven-suspended',
      legalBusinessName: 'Sharjah Heritage Gold',
      tradingName: 'Heritage',
      tradeLicenceNumber: 'CN-3091827',
      licenceExpiryDate: DateTime.now().add(const Duration(days: 180)),
      businessAddress: 'Souq, Sharjah',
      contactPersonName: 'Rashid Khan',
      businessEmail: 'info@heritage.ae',
      accountState: VendorAccountState.suspended,
    );

    await tester.pumpWidget(createVendorDetailWidget(vendorId: 'ven-suspended'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vendor-reactivate-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('vendor-reactivate-button')));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Vendor Reactivation'), findsOneWidget);
    expect(find.textContaining('KYC Trade Licence is valid'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-reactivate-button')));
    await tester.pumpAndSettle();

    expect(fakeRepo.reactivateCalled, isTrue);
  });

  testWidgets('blocks reactivation with warning dialog when KYC licence is expired',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeRepo.detailToReturn = VendorDetail(
      id: 'ven-expired',
      legalBusinessName: 'Old Gold LLC',
      tradeLicenceNumber: 'CN-9999999',
      licenceExpiryDate: DateTime.now().subtract(const Duration(days: 10)),
      businessAddress: 'Deira, Dubai',
      contactPersonName: 'Salem',
      businessEmail: 'old@gold.ae',
      accountState: VendorAccountState.suspended,
    );

    await tester.pumpWidget(createVendorDetailWidget(vendorId: 'ven-expired'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('vendor-reactivate-button')));
    await tester.pumpAndSettle();

    expect(find.text('Cannot Reactivate Vendor'), findsOneWidget);
    expect(find.textContaining('expired'), findsWidgets);
    expect(fakeRepo.reactivateCalled, isFalse);
  });

  testWidgets('prompts terminal deactivation dialog with warning, then deactivates',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createVendorDetailWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('vendor-deactivate-button')));
    await tester.pumpAndSettle();

    expect(find.text('Deactivate Vendor Account'), findsOneWidget);
    expect(find.textContaining('TERMINAL TRANSITION WARNING'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('deactivate-reason-text-field')),
      'Business ceased operations permanently.',
    );
    await tester.tap(find.byKey(const Key('confirm-deactivate-button')));
    await tester.pumpAndSettle();

    expect(fakeRepo.deactivateCalled, isTrue);
    expect(fakeRepo.lastReasonText, 'Business ceased operations permanently.');
  });

  testWidgets('back button navigates to /vendors directory', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createVendorDetailWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('vendor-detail-back-button')));
    await tester.pumpAndSettle();

    expect(find.text('Vendors Directory List'), findsOneWidget);
  });
}
