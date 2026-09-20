import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/onboarding/repository/onboarding_repository.dart';
import 'package:karat_hive/features/profile_settings/presentation/vendor_documents_screen.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_session.dart';

class _MockRepo extends Mock implements OnboardingRepository {}

Widget _host({
  required List<Override> overrides,
  required Widget child,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
      GoRoute(path: '/awaiting', builder: (context, state) => const SizedBox()),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      routerConfig: router,
    ),
  );
}

VendorDocument _doc(VendorDocumentType type, {bool verified = false}) =>
    VendorDocument(
      id: 'doc-${type.wire}',
      documentType: type,
      verified: verified,
      uploadedAt: DateTime.utc(2026, 1, 10),
    );

void main() {
  testWidgets('loads and displays existing documents with status', (tester) async {
    final repo = _MockRepo();
    when(() => repo.documents()).thenAnswer(
      (_) async => Ok([
        _doc(VendorDocumentType.tradeLicence, verified: true),
        _doc(VendorDocumentType.emiratesId),
      ]),
    );

    await tester.pumpWidget(
      _host(
        overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
        child: const VendorDocumentsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(VendorDocumentsScreen.screenKey), findsOneWidget);
    expect(find.textContaining('Trade licence'), findsOneWidget);
    expect(find.textContaining('Verified'), findsOneWidget);
    expect(find.textContaining('Pending review'), findsOneWidget);
  });

  testWidgets('resubmit is disabled until mandatory documents are present',
      (tester) async {
    final repo = _MockRepo();
    when(() => repo.documents()).thenAnswer(
      (_) async => Ok([_doc(VendorDocumentType.tradeLicence)]),
    );

    await tester.pumpWidget(
      _host(
        overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
        child: const VendorDocumentsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<KhButton>(find.byType(KhButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('resubmit confirms, calls API, and refreshes session', (tester) async {
    final repo = _MockRepo();
    final vendor = testVendorMe(lifecycle: VendorLifecycle.active);
    when(() => repo.documents()).thenAnswer(
      (_) async => Ok([
        _doc(VendorDocumentType.tradeLicence, verified: true),
        _doc(VendorDocumentType.emiratesId, verified: true),
      ]),
    );
    when(() => repo.resubmit()).thenAnswer((_) async => Ok(vendor));

    await tester.pumpWidget(
      _host(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(
            () => FakeSessionController(SignedIn(testVendorUser(vendor: vendor))),
          ),
        ],
        child: const VendorDocumentsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(KhButton));
    await tester.pumpAndSettle();

    expect(find.text('Re-verification Required'), findsOneWidget);

    await tester.tap(find.text('Submit for Re-verification').last);
    await tester.pumpAndSettle();

    verify(() => repo.resubmit()).called(1);
  });

  testWidgets('shows load failure via inline error', (tester) async {
    final repo = _MockRepo();
    when(() => repo.documents()).thenAnswer(
      (_) async => const Err(ServerFailure(message: 'down')),
    );

    await tester.pumpWidget(
      _host(
        overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
        child: const VendorDocumentsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(KhInlineError), findsOneWidget);
  });
}
