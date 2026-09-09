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
import 'package:kh_admin/features/verification/model/document_url_response.dart';
import 'package:kh_admin/features/verification/model/vendor_verification_detail.dart';
import 'package:kh_admin/features/verification/presentation/verification_detail_pane.dart';
import 'package:kh_admin/features/verification/repository/verification_repository.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Fake verification repository for testing document fetch and URL opening.
class _FakeVerificationRepo extends VerificationRepository {
  _FakeVerificationRepo() : super(ApiClient());

  int fetchDocumentUrlCalls = 0;
  String? lastRequestedDocId;
  String? lastRequestedVendorId;

  final VendorVerificationDetail testDetail = VendorVerificationDetail(
    id: 'vendor-kyc-1',
    legalBusinessName: 'Al Baraka Gold LLC',
    tradeLicenceNumber: 'TL-883921',
    licenceExpiryDate: DateTime.utc(2028, 1, 1),
    businessAddress: 'Gold Souk, Deira, Dubai',
    contactPersonName: 'Rashid Al Maktoum',
    businessEmail: 'rashid@albaraka.ae',
    mobileNumber: '+971501234567',
    regions: const ['Dubai (Deira)'],
    documents: [
      VendorDocumentDetail(
        id: 'doc-tl-1',
        documentType: 'TRADE_LICENCE',
        uploadedAt: DateTime.utc(2026, 2, 10),
        fileName: 'trade_licence_signed.pdf',
        mimeType: 'application/pdf',
        verified: false,
      ),
      VendorDocumentDetail(
        id: 'doc-eid-2',
        documentType: 'EMIRATES_ID',
        uploadedAt: DateTime.utc(2026, 2, 11),
        fileName: 'emirates_id_front.jpg',
        mimeType: 'image/jpeg',
        verified: true,
      ),
    ],
  );

  @override
  Future<VendorVerificationDetail> fetchVendorDetail(String vendorId) async {
    return testDetail.copyWith(id: vendorId);
  }

  @override
  Future<DocumentUrlResponse> fetchDocumentUrl({
    required String vendorId,
    required String documentId,
  }) async {
    fetchDocumentUrlCalls++;
    lastRequestedVendorId = vendorId;
    lastRequestedDocId = documentId;
    return DocumentUrlResponse(
      url: 'https://cdn.karathive.ae/kyc/$vendorId/$documentId.pdf',
      expiresAt: DateTime.utc(2026, 9, 9, 12),
    );
  }
}

/// Fake vendor repository for testing vendor profile KYC card rendering.
class _FakeVendorRepo extends VendorRepository {
  _FakeVendorRepo() : super(ApiClient());

  @override
  Future<VendorDetail> fetchVendorDetail(String vendorId) async {
    return VendorDetail(
      id: vendorId,
      legalBusinessName: 'Al Baraka Gold LLC',
      tradingName: 'Al Baraka',
      tradeLicenceNumber: 'TL-883921',
      licenceExpiryDate: DateTime.now().add(const Duration(days: 365)),
      businessAddress: 'Gold Souk, Deira, Dubai',
      contactPersonName: 'Rashid Al Maktoum',
      businessEmail: 'rashid@albaraka.ae',
      mobileNumber: '+971 50 123 4567',
      verificationState: VendorVerificationState.pendingVerification,
      accountState: VendorAccountState.active,
      categories: const ['Gold Jewellery'],
      regions: const ['Dubai'],
      documents: [
        VendorDocumentDetail(
          id: 'doc-tl-1',
          documentType: 'TRADE_LICENCE',
          uploadedAt: DateTime(2026, 2, 10),
          fileName: 'trade_licence_signed.pdf',
          verified: false,
        ),
        VendorDocumentDetail(
          id: 'doc-eid-2',
          documentType: 'EMIRATES_ID',
          uploadedAt: DateTime(2026, 2, 11),
          fileName: 'emirates_id_front.jpg',
          verified: true,
        ),
      ],
    );
  }
}

void main() {
  group('TR-S3-05 / ADM-INS-72 · Image decode bounds audit', () {
    late _FakeVerificationRepo fakeVerificationRepo;
    late _FakeVendorRepo fakeVendorRepo;

    setUp(() {
      fakeVerificationRepo = _FakeVerificationRepo();
      fakeVendorRepo = _FakeVendorRepo();
    });

    Widget buildVerificationDetailWidget({String vendorId = 'vendor-kyc-1'}) {
      return ProviderScope(
        overrides: [
          verificationRepositoryProvider.overrideWithValue(fakeVerificationRepo),
        ],
        child: MaterialApp(
          theme: buildKhAdminTheme(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VerificationDetailPane(vendorId: vendorId),
          ),
        ),
      );
    }

    Widget buildVendorDetailWidget({String vendorId = 'vendor-kyc-1'}) {
      final router = GoRouter(
        initialLocation: '/vendors/$vendorId',
        routes: [
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
          vendorRepositoryProvider.overrideWithValue(fakeVendorRepo),
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

    testWidgets(
      'VerificationDetailPane opens document URLs externally with zero uncontrolled inline Image decode',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildVerificationDetailWidget());
        await tester.pumpAndSettle();

        // 1. Audit initial render of KYC documents: uses icons and metadata, no Image widgets
        expect(find.text('Trade Licence'), findsOneWidget);
        expect(find.text('Emirates ID'), findsOneWidget);
        expect(find.text('trade_licence_signed.pdf'), findsOneWidget);
        expect(find.text('emirates_id_front.jpg'), findsOneWidget);

        // Verify NO inline Image or RawImage decode occurs
        expect(
          find.byType(Image),
          findsNothing,
          reason: 'No inline Image widgets should decode full-resolution KYC documents',
        );
        expect(
          find.byType(RawImage),
          findsNothing,
          reason: 'No raw decoded image slots should exist in VerificationDetailPane',
        );

        // 2. Tap View button for the document
        final viewButtonFinder = find.byKey(const Key('view-doc-doc-tl-1'));
        expect(viewButtonFinder, findsOneWidget);
        await tester.tap(viewButtonFinder);
        await tester.pumpAndSettle();

        // Verify fetchDocumentUrl was called
        expect(fakeVerificationRepo.fetchDocumentUrlCalls, 1);
        expect(fakeVerificationRepo.lastRequestedDocId, 'doc-tl-1');
        expect(fakeVerificationRepo.lastRequestedVendorId, 'vendor-kyc-1');

        // 3. Verify the external document viewer link banner is shown
        expect(find.byKey(const Key('verification-document-viewer')), findsOneWidget);
        expect(
          find.textContaining('https://cdn.karathive.ae/kyc/vendor-kyc-1/doc-tl-1.pdf'),
          findsOneWidget,
        );

        // Verify STILL NO inline Image widget decode exists after URL retrieval
        expect(
          find.byType(Image),
          findsNothing,
          reason: 'Document URL is opened via openUrlInNewTab; zero uncontrolled decode',
        );
        expect(
          find.byType(RawImage),
          findsNothing,
          reason: 'Zero raw image decodes after fetching document URL',
        );
      },
    );

    testWidgets(
      'VendorDetailScreen renders KYC documents list with metadata and zero inline Image decode',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildVendorDetailWidget());
        await tester.pumpAndSettle();

        // Verify KYC documents card renders
        expect(find.byKey(const Key('vendor-kyc-documents-card')), findsOneWidget);
        expect(find.byKey(const Key('vendor-doc-doc-tl-1')), findsOneWidget);
        expect(find.byKey(const Key('vendor-doc-doc-eid-2')), findsOneWidget);

        // Verify document metadata
        expect(find.text('TRADE LICENCE'), findsOneWidget);
        expect(find.text('EMIRATES ID'), findsOneWidget);
        expect(find.text('trade_licence_signed.pdf'), findsOneWidget);
        expect(find.text('emirates_id_front.jpg'), findsOneWidget);

        // Verify NO Image or RawImage widget exists
        expect(
          find.byType(Image),
          findsNothing,
          reason: 'Vendor KYC document items render with description icons, not raw Image decodes',
        );
        expect(
          find.byType(RawImage),
          findsNothing,
          reason: 'No RawImage widgets present in VendorDetailScreen KYC card',
        );
      },
    );
  });
}
