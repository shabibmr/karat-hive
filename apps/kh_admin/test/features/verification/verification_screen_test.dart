import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/verification/model/document_url_response.dart';
import 'package:kh_admin/features/verification/model/verification_decision_dto.dart';
import 'package:kh_admin/features/verification/model/verification_queue_item.dart';
import 'package:kh_admin/features/verification/model/vendor_verification_detail.dart';
import 'package:kh_admin/features/verification/presentation/verification_screen.dart';
import 'package:kh_admin/features/verification/repository/verification_repository.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

class _FakeVerificationRepository extends VerificationRepository {
  _FakeVerificationRepository() : super(ApiClient());

  List<VerificationQueueItem> queue = [
    const VerificationQueueItem(
      id: 'vendor-1',
      legalBusinessName: 'Al Noor Jewellery LLC',
      tradeLicenceNumber: 'CN-1092834',
      oldestWaitingHours: 52,
      tradingName: 'Al Noor',
    ),
  ];

  VendorVerificationDetail detail = VendorVerificationDetail(
    id: 'vendor-1',
    legalBusinessName: 'Al Noor Jewellery LLC',
    tradeLicenceNumber: 'CN-1092834',
    licenceExpiryDate: DateTime.utc(2027, 6, 30),
    businessAddress: 'Deira Gold Souk, Dubai',
    contactPersonName: 'Ahmed Hassan',
    businessEmail: 'ahmed@alnoor.ae',
    mobileNumber: '+97145550101',
    regions: const ['Dubai (Deira)'],
    documents: [
      VendorDocumentDetail(
        id: 'doc-1',
        documentType: 'TRADE_LICENCE',
        uploadedAt: DateTime.utc(2026, 1, 1),
        fileName: 'Trade_Licence_Dubai.pdf',
        mimeType: 'application/pdf',
      ),
    ],
  );

  bool empty = false;

  @override
  Future<List<VerificationQueueItem>> fetchQueue() async {
    if (empty) return const [];
    return queue;
  }

  @override
  Future<VendorVerificationDetail> fetchVendorDetail(String vendorId) async {
    return detail.copyWith(id: vendorId);
  }

  @override
  Future<DocumentUrlResponse> fetchDocumentUrl({
    required String vendorId,
    required String documentId,
  }) async {
    return DocumentUrlResponse(
      url: 'https://example.com/doc.pdf',
      expiresAt: DateTime.utc(2026, 9, 7, 12),
    );
  }

  @override
  Future<void> verifyVendor(String vendorId, VerifyDecisionDto dto) async {
    queue = const [];
  }
}

void main() {
  late _FakeVerificationRepository fakeRepository;

  setUp(() {
    fakeRepository = _FakeVerificationRepository();
  });

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        verificationRepositoryProvider.overrideWithValue(fakeRepository),
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
        home: const Scaffold(body: VerificationScreen()),
      ),
    );
  }

  testWidgets('VerificationScreen renders queue and reviewer panel', (tester) async {
    tester.view.physicalSize = const Size(1500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('COMPLIANCE REVIEWER'), findsOneWidget);
    expect(find.textContaining('KYC Verification Queue'), findsOneWidget);
    expect(find.text('Al Noor Jewellery LLC'), findsWidgets);
    expect(find.text('CN-1092834'), findsWidgets);
    expect(find.byKey(const Key('verification-detail-pane-vendor-1')), findsOneWidget);
    expect(find.byKey(const Key('verification-approve-button')), findsOneWidget);
  });

  testWidgets('VerificationScreen shows empty state when queue is clear', (tester) async {
    fakeRepository.empty = true;

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('verification-empty-view')), findsOneWidget);
    expect(find.text('Queue is Clear'), findsOneWidget);
  });

  testWidgets('VerificationScreen opens approve dialog from action bar', (tester) async {
    tester.view.physicalSize = const Size(1500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('verification-approve-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('approve-rationale-field')), findsOneWidget);
    expect(find.byKey(const Key('confirm-approve-button')), findsOneWidget);
  });
}
