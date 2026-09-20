import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/di.dart';
import 'package:karat_hive/features/auth/presentation/vendor_login_screen.dart';
import 'package:karat_hive/features/auth/presentation/vendor_register_screen.dart';
import 'package:karat_hive/features/onboarding/presentation/kyc_upload_screen.dart';
import 'package:karat_hive/features/onboarding/repository/onboarding_repository.dart';
import 'package:karat_hive/features/profile_settings/presentation/categories_regions_screen.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

/// KYC upload prefetches an upload-intent on mount (fire-and-forget); stub
/// [KhApi] so that never reaches the network in this layout-only test.
class _StubKhApi extends Mock implements KhApi {}

KhApi _stubApi() {
  final api = _StubKhApi();
  when(
    () => api.uploadIntent(
      purpose: any(named: 'purpose'),
      contentType: any(named: 'contentType'),
      byteSize: any(named: 'byteSize'),
    ),
  ).thenAnswer((_) async => const Err(NetworkFailure()));
  when(() => api.vendorMe()).thenAnswer((_) async => const Err(NetworkFailure()));
  when(() => api.documents()).thenAnswer((_) async => const Ok([]));
  return api;
}

/// The vendor app is mobile-first, but it still has to survive small phones,
/// landscape, and tablet widths. `flutter_test` turns a RenderFlex overflow
/// into a test failure, so pumping each screen at each size is the assertion.
const List<({String name, Size size})> _viewports = [
  (name: 'small phone', size: Size(320, 568)),
  (name: 'phone portrait', size: Size(360, 800)),
  (name: 'large phone', size: Size(414, 896)),
  (name: 'phone landscape', size: Size(800, 360)),
  (name: 'tablet portrait', size: Size(768, 1024)),
  (name: 'tablet landscape', size: Size(1366, 1024)),
];

/// Real-shaped taxonomy so list rows render at full length. Overriding the
/// providers also keeps the HTTP client — and its pending timeout timer — out
/// of the test.
const _categories = [
  TaxonomyNode(
    id: 'cat-necklaces',
    nameEn: 'Bridal & Fine Necklaces',
    nameAr: 'قلائد مجوهرات',
  ),
  TaxonomyNode(
    id: 'cat-old-gold',
    nameEn: 'Sell Old Gold Scrap',
    nameAr: 'بيع الذهب القديم',
  ),
];

const _regions = [
  TaxonomyNode(id: 'reg-dubai', nameEn: 'Dubai', nameAr: 'دبي'),
];

Widget _host(Widget child) => ProviderScope(
      overrides: [
        categoriesProvider.overrideWith((ref) async => _categories),
        regionsProvider.overrideWith((ref) async => _regions),
        khApiProvider.overrideWithValue(_stubApi()),
      ],
      child: MaterialApp(
        localizationsDelegates: KhStrings.delegates,
        supportedLocales: KhStrings.supportedLocales,
        home: child,
      ),
    );

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size, Widget screen) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_host(screen));
    await tester.pump();
  }

  for (final viewport in _viewports) {
    testWidgets('vendor login lays out cleanly on ${viewport.name}',
        (tester) async {
      await pumpAt(tester, viewport.size, const VendorLoginScreen());
      expect(find.byType(VendorLoginScreen), findsOneWidget);
    });

    testWidgets('vendor registration lays out cleanly on ${viewport.name}',
        (tester) async {
      await pumpAt(tester, viewport.size, const VendorRegisterScreen());
      expect(find.byType(VendorRegisterScreen), findsOneWidget);
    });

    testWidgets('KYC upload lays out cleanly on ${viewport.name}',
        (tester) async {
      await pumpAt(tester, viewport.size, const KycUploadScreen());
      expect(find.byType(KycUploadScreen), findsOneWidget);
    });

    testWidgets('categories & regions lays out cleanly on ${viewport.name}',
        (tester) async {
      await pumpAt(tester, viewport.size, const CategoriesRegionsScreen());
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesRegionsScreen), findsOneWidget);
    });
  }
}
