import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/profile_settings/controller/business_profile_controller.dart';
import 'package:karat_hive/features/profile_settings/presentation/business_profile_screen.dart';
import 'package:karat_hive/features/profile_settings/repository/profile_settings_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_session.dart';

class _MockRepo extends Mock implements ProfileSettingsRepository {}

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

VendorMe _headerVendor() => VendorMe(
      vendorProfileId: 'vp1',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      tradingName: 'Al Noor',
      legalBusinessName: 'Al Noor LLC',
      tradeLicenceNumber: 'TL-12345',
      registeredAddress: 'Gold Souk, Deira, Unit 12',
      categoryCount: 1,
      regionCount: 1,
      verifiedAt: DateTime.utc(2026, 1, 15),
      rating: const RatingSummary(
        average: 4.6,
        count: 12,
        distribution: {'5': 8, '4': 3, '3': 1, '2': 0, '1': 0},
        limitedHistory: false,
      ),
      offersSubmittedCount: 40,
      connectionCount: 9,
      description: 'Premier Deira jeweller.',
      contactPersonName: 'Sara',
      businessEmail: 'sara@alnoor.example',
      businessHours: const {
        'mon': BusinessDayHours(open: '09:30', close: '22:00'),
        'sun': BusinessDayHours(open: '16:00', close: '21:30', closed: true),
      },
      maskedPreview: const MaskedParty(
        role: UserRole.vendor,
        pseudonym: 'Verified Jeweller · Deira',
        region: 'Deira',
        rating: RatingSummary(
          average: 4.6,
          count: 12,
          limitedHistory: false,
        ),
        dealCount: 9,
      ),
    );

void main() {
  testWidgets('VEN-S15 header shows verification, rating, totals, preview',
      (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          vendorProfileProvider.overrideWith((ref) async => _headerVendor()),
        ],
        child: const BusinessProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Business profile'), findsOneWidget);
    expect(find.byKey(const Key('business-profile-header')), findsOneWidget);
    expect(find.byKey(const Key('vendor-status-card')), findsOneWidget);
    expect(find.text('Al Noor'), findsWidgets);
    expect(find.byKey(const Key('business-profile-verified-at')), findsOneWidget);
    // BR-021/C-01: verified-at must render in Gulf Standard Time (UTC+4),
    // independent of the test-runner's OS timezone.
    expect(find.text('Verified on 15 Jan 2026, 04:00 GST'), findsOneWidget);
    expect(find.byKey(const Key('business-profile-totals')), findsOneWidget);
    expect(find.text('Offers submitted'), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    expect(find.text('9'), findsWidgets);
    expect(find.byType(RatingSummaryView), findsOneWidget);
    expect(find.byKey(const Key('rating-summary')), findsOneWidget);
    expect(find.byKey(const Key('masked-public-preview')), findsOneWidget);
    expect(find.text('Verified Jeweller · Deira'), findsOneWidget);
  });

  testWidgets('VEN-S15 safe-edit and legal fields seed and expose Save',
      (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          vendorProfileProvider.overrideWith((ref) async => _headerVendor()),
        ],
        child: const BusinessProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('business-profile-trading-name')), findsOneWidget);
    expect(find.byKey(const Key('business-profile-description')), findsOneWidget);
    expect(find.byKey(const Key('business-profile-contact-person')), findsOneWidget);
    expect(find.byKey(const Key('business-profile-business-email')), findsOneWidget);
    expect(find.byKey(const Key('business-profile-hours')), findsOneWidget);
    expect(find.byKey(const Key('business-profile-legal-name')), findsOneWidget);
    expect(find.byKey(const Key('business-profile-trade-licence')), findsOneWidget);
    expect(find.byKey(const Key('business-profile-registered-address')), findsOneWidget);
    expect(find.byKey(const Key('business-profile-save')), findsOneWidget);
    expect(find.text('Premier Deira jeweller.'), findsOneWidget);
    expect(find.text('Sara'), findsOneWidget);
    expect(find.text('sara@alnoor.example'), findsOneWidget);
    // BR-004 legal identity fields seeded
    expect(find.text('Legal business name'), findsOneWidget);
    expect(find.text('Trade licence number'), findsOneWidget);
    expect(find.text('Registered address'), findsOneWidget);
    expect(find.text('Al Noor LLC'), findsOneWidget);
    expect(find.text('TL-12345'), findsOneWidget);
    expect(find.text('Gold Souk, Deira, Unit 12'), findsOneWidget);
    // Media upload affordances are B02.3.
    expect(find.text('Logo'), findsNothing);
    expect(find.text('Shop photographs'), findsNothing);
  });

  testWidgets('Save posts safe fields only and skips BR-004 keys', (tester) async {
    final repo = _MockRepo();
    when(
      () => repo.patchVendorProfile(
        tradingName: any(named: 'tradingName'),
        description: any(named: 'description'),
        contactPersonName: any(named: 'contactPersonName'),
        businessEmail: any(named: 'businessEmail'),
      ),
    ).thenAnswer((_) async => Ok(_headerVendor()));
    when(() => repo.setAvailability(businessHours: any(named: 'businessHours')))
        .thenAnswer((_) async => Ok(_headerVendor()));

    await tester.pumpWidget(
      _host(
        overrides: [
          vendorProfileProvider.overrideWith((ref) async => _headerVendor()),
          profileSettingsRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(
            () => FakeSessionController(
              SignedIn(testVendorUser(vendor: _headerVendor())),
            ),
          ),
        ],
        child: const BusinessProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('business-profile-trading-name')),
      'Al Noor Gold',
    );
    await tester.ensureVisible(find.byKey(const Key('business-profile-save')));
    await tester.tap(find.byKey(const Key('business-profile-save')));
    await tester.pumpAndSettle();

    final captured = verify(
      () => repo.patchVendorProfile(
        tradingName: captureAny(named: 'tradingName'),
        description: captureAny(named: 'description'),
        contactPersonName: captureAny(named: 'contactPersonName'),
        businessEmail: captureAny(named: 'businessEmail'),
      ),
    ).captured;
    expect(captured[0], 'Al Noor Gold');
    expect(captured[1], 'Premier Deira jeweller.');
    expect(captured[2], 'Sara');
    expect(captured[3], 'sara@alnoor.example');
    verify(() => repo.setAvailability(businessHours: any(named: 'businessHours')))
        .called(1);
    expect(find.text('Profile saved.'), findsOneWidget);
  });

  testWidgets('shows KhErrorView when profile load fails', (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          vendorProfileProvider.overrideWith(
            (ref) async => throw const ServerFailure(message: 'down'),
          ),
        ],
        child: const BusinessProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(KhErrorView), findsOneWidget);
    expect(find.text('Could not load your profile.'), findsOneWidget);
  });

  testWidgets('Checkpoint-1 payload still renders header with empty totals',
      (tester) async {
    await tester.pumpWidget(
      _host(
        overrides: [
          vendorProfileProvider.overrideWith(
            (ref) async => testVendorMe(lifecycle: VendorLifecycle.active),
          ),
        ],
        child: const BusinessProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vendor-status-card')), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.byType(RatingSummaryView), findsOneWidget);
    expect(find.byKey(const Key('masked-public-preview')), findsOneWidget);
    expect(find.text('Verified Jeweller'), findsOneWidget);
  });

  testWidgets(
      'editing legal identity fields and clicking Save shows Re-verification Required dialog',
      (tester) async {
    final repo = _MockRepo();

    await tester.pumpWidget(
      _host(
        overrides: [
          vendorProfileProvider.overrideWith((ref) async => _headerVendor()),
          profileSettingsRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(
            () => FakeSessionController(
              SignedIn(testVendorUser(vendor: _headerVendor())),
            ),
          ),
        ],
        child: const BusinessProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('business-profile-legal-name')),
      'Al Noor International LLC',
    );
    await tester.ensureVisible(find.byKey(const Key('business-profile-save')));
    await tester.tap(find.byKey(const Key('business-profile-save')));
    await tester.pumpAndSettle();

    expect(find.text('Re-verification Required'), findsOneWidget);
    expect(
      find.text(
        'Changing legal identity fields requires administrator re-verification. Your account will enter pending verification until reviewed.',
      ),
      findsOneWidget,
    );
    expect(find.text('Submit for Re-verification'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('tapping Cancel on dialog aborts saving and does not call repo',
      (tester) async {
    final repo = _MockRepo();

    await tester.pumpWidget(
      _host(
        overrides: [
          vendorProfileProvider.overrideWith((ref) async => _headerVendor()),
          profileSettingsRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(
            () => FakeSessionController(
              SignedIn(testVendorUser(vendor: _headerVendor())),
            ),
          ),
        ],
        child: const BusinessProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('business-profile-trade-licence')),
      'TL-99999',
    );
    await tester.ensureVisible(find.byKey(const Key('business-profile-save')));
    await tester.tap(find.byKey(const Key('business-profile-save')));
    await tester.pumpAndSettle();

    expect(find.text('Re-verification Required'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Re-verification Required'), findsNothing);
    verifyNever(
      () => repo.patchVendorProfile(
        tradingName: any(named: 'tradingName'),
        description: any(named: 'description'),
        contactPersonName: any(named: 'contactPersonName'),
        businessEmail: any(named: 'businessEmail'),
      ),
    );
    verifyNever(
      () => repo.setAvailability(businessHours: any(named: 'businessHours')),
    );
    expect(find.text('Profile saved.'), findsNothing);
  });

  testWidgets('tapping Submit for Re-verification confirms and calls save',
      (tester) async {
    final repo = _MockRepo();
    when(
      () => repo.patchVendorProfile(
        tradingName: any(named: 'tradingName'),
        description: any(named: 'description'),
        contactPersonName: any(named: 'contactPersonName'),
        businessEmail: any(named: 'businessEmail'),
      ),
    ).thenAnswer((_) async => Ok(_headerVendor()));
    when(() => repo.setAvailability(businessHours: any(named: 'businessHours')))
        .thenAnswer((_) async => Ok(_headerVendor()));

    await tester.pumpWidget(
      _host(
        overrides: [
          vendorProfileProvider.overrideWith((ref) async => _headerVendor()),
          profileSettingsRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(
            () => FakeSessionController(
              SignedIn(testVendorUser(vendor: _headerVendor())),
            ),
          ),
        ],
        child: const BusinessProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('business-profile-registered-address')),
      'New Address, Gold Souk, Unit 99',
    );
    await tester.ensureVisible(find.byKey(const Key('business-profile-save')));
    await tester.tap(find.byKey(const Key('business-profile-save')));
    await tester.pumpAndSettle();

    expect(find.text('Re-verification Required'), findsOneWidget);

    await tester.tap(find.text('Submit for Re-verification'));
    await tester.pumpAndSettle();

    expect(find.text('Re-verification Required'), findsNothing);
    verify(
      () => repo.patchVendorProfile(
        tradingName: any(named: 'tradingName'),
        description: any(named: 'description'),
        contactPersonName: any(named: 'contactPersonName'),
        businessEmail: any(named: 'businessEmail'),
      ),
    ).called(1);
    expect(find.text('Profile saved.'), findsOneWidget);
  });

  testWidgets(
      'editing only safe fields saves directly without triggering confirmation dialog',
      (tester) async {
    final repo = _MockRepo();
    when(
      () => repo.patchVendorProfile(
        tradingName: any(named: 'tradingName'),
        description: any(named: 'description'),
        contactPersonName: any(named: 'contactPersonName'),
        businessEmail: any(named: 'businessEmail'),
      ),
    ).thenAnswer((_) async => Ok(_headerVendor()));
    when(() => repo.setAvailability(businessHours: any(named: 'businessHours')))
        .thenAnswer((_) async => Ok(_headerVendor()));

    await tester.pumpWidget(
      _host(
        overrides: [
          vendorProfileProvider.overrideWith((ref) async => _headerVendor()),
          profileSettingsRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith(
            () => FakeSessionController(
              SignedIn(testVendorUser(vendor: _headerVendor())),
            ),
          ),
        ],
        child: const BusinessProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('business-profile-contact-person')),
      'Layla',
    );
    await tester.ensureVisible(find.byKey(const Key('business-profile-save')));
    await tester.tap(find.byKey(const Key('business-profile-save')));
    await tester.pumpAndSettle();

    expect(find.text('Re-verification Required'), findsNothing);
    verify(
      () => repo.patchVendorProfile(
        tradingName: any(named: 'tradingName'),
        description: any(named: 'description'),
        contactPersonName: 'Layla',
        businessEmail: any(named: 'businessEmail'),
      ),
    ).called(1);
    expect(find.text('Profile saved.'), findsOneWidget);
  });
}
