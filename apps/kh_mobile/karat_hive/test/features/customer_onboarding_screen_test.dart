import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/auth/controller/customer_onboarding_controller.dart';
import 'package:karat_hive/features/auth/presentation/customer_onboarding_screen.dart';
import 'package:karat_hive/features/auth/repository/customer_auth_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/customer_auth.dart';
import '../helpers/fake_session.dart';

class _FakeOnboarding extends CustomerOnboardingController {
  _FakeOnboarding(this._state);
  final CustomerOnboardingState _state;
  @override
  CustomerOnboardingState build() => _state;
}

class _MockRepo extends Mock implements CustomerAuthRepository {}

Widget _host(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: khTheme(),
        localizationsDelegates: const [
          ...KhStrings.delegates,
          AppLocalizations.delegate,
        ],
        supportedLocales: KhStrings.supportedLocales,
        home: const CustomerOnboardingScreen(),
      ),
    );

void main() {
  testWidgets('welcome view shows the Google button without biometric toggle',
      (tester) async {
    await tester.pumpWidget(_host([
      customerOnboardingControllerProvider
          .overrideWith(() => _FakeOnboarding(const OnboardingIdle())),
      sessionProvider.overrideWith(
        () => FakeSessionController(const SignedOut()),
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsOneWidget);
    expect(find.byKey(const Key('customer-google-signin')), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byKey(const Key('biometric-unlock-toggle')), findsNothing);
    expect(find.byKey(const Key('guest-type-ornament')), findsNothing);
  });

  testWidgets('a lockout state renders SH-AUTH-07, not the completion step',
      (tester) async {
    await tester.pumpWidget(_host([
      customerOnboardingControllerProvider.overrideWith(
        () => _FakeOnboarding(const OnboardingLockedOut('Your account is suspended.')),
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-lockout-message')), findsOneWidget);
    expect(find.text('Your account is suspended.'), findsOneWidget);
    expect(find.text('Finish setting up your account'), findsNothing);
  });

  testWidgets(
      'completion step: terms + mobile, Continue registers without OTP (CFE-10)',
      (tester) async {
    final repo = _MockRepo();
    final bundle = testCustomerBundle();
    when(() => repo.registerCustomer(
          firebaseToken: any(named: 'firebaseToken'),
          challengeId: any(named: 'challengeId'),
          mobileNumber: any(named: 'mobileNumber'),
          displayName: any(named: 'displayName'),
          email: any(named: 'email'),
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
        )).thenAnswer((_) async => Ok(bundle));
    final session = RecordingSessionController();

    await tester.pumpWidget(_host([
      customerOnboardingControllerProvider.overrideWith(
        () => _FakeOnboarding(
          const OnboardingNeedsCompletion(firebaseIdToken: 'fb-token'),
        ),
      ),
      customerAuthRepositoryProvider.overrideWithValue(repo),
      sessionProvider.overrideWith(() => session),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Finish setting up your account'), findsOneWidget);
    expect(find.byKey(const Key('accept-terms-checkbox')), findsOneWidget);

    // Continue is disabled until name + mobile + terms are all present.
    await tester.enterText(find.byType(TextField).at(0), 'Layla');
    await tester.enterText(find.byType(TextField).at(1), '+971500000009');
    await tester.tap(find.byKey(const Key('accept-terms-checkbox')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('otp-input')), findsNothing);
    verify(() => repo.registerCustomer(
          firebaseToken: 'fb-token',
          challengeId: null,
          mobileNumber: '+971500000009',
          displayName: 'Layla',
          email: any(named: 'email'),
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
        )).called(1);
    expect(session.authenticated.single, bundle);
  });

  testWidgets(
      'completion step: shows validation error when mobile lacks E.164 country code',
      (tester) async {
    final repo = _MockRepo();
    final session = RecordingSessionController();

    await tester.pumpWidget(_host([
      customerOnboardingControllerProvider.overrideWith(
        () => _FakeOnboarding(
          const OnboardingNeedsCompletion(firebaseIdToken: 'fb-token'),
        ),
      ),
      customerAuthRepositoryProvider.overrideWithValue(repo),
      sessionProvider.overrideWith(() => session),
    ]));
    await tester.pumpAndSettle();

    // Enter local number without country code
    await tester.enterText(find.byKey(const Key('customer-completion-mobile')), '0501234567');
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid mobile number with country code (e.g. +971501234567).'),
      findsOneWidget,
    );

    // Continue button must be disabled (canContinue is false)
    final continueButton = tester.widget<KhButton>(find.widgetWithText(KhButton, 'Continue'));
    expect(continueButton.onPressed, isNull);
  });

  testWidgets(
      'completion step: mobile with spaces is accepted and normalized on register',
      (tester) async {
    final repo = _MockRepo();
    final bundle = testCustomerBundle();
    when(() => repo.registerCustomer(
          firebaseToken: any(named: 'firebaseToken'),
          challengeId: any(named: 'challengeId'),
          mobileNumber: any(named: 'mobileNumber'),
          displayName: any(named: 'displayName'),
          email: any(named: 'email'),
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
        )).thenAnswer((_) async => Ok(bundle));
    final session = RecordingSessionController();

    await tester.pumpWidget(_host([
      customerOnboardingControllerProvider.overrideWith(
        () => _FakeOnboarding(
          const OnboardingNeedsCompletion(firebaseIdToken: 'fb-token'),
        ),
      ),
      customerAuthRepositoryProvider.overrideWithValue(repo),
      sessionProvider.overrideWith(() => session),
    ]));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('customer-completion-name')), 'Layla');
    // Enter number with spaces
    await tester.enterText(
      find.byKey(const Key('customer-completion-mobile')),
      '+971 50 000 0009',
    );
    await tester.tap(find.byKey(const Key('accept-terms-checkbox')));
    await tester.pumpAndSettle();

    // No error should be shown
    expect(
      find.text('Enter a valid mobile number with country code (e.g. +971501234567).'),
      findsNothing,
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    verify(() => repo.registerCustomer(
          firebaseToken: 'fb-token',
          challengeId: null,
          mobileNumber: '+971500000009',
          displayName: 'Layla',
          email: any(named: 'email'),
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
        )).called(1);
    expect(session.authenticated.single, bundle);
  });

  testWidgets(
      'completion step: empty name shows validation error when terms accepted',
      (tester) async {
    final repo = _MockRepo();
    final session = RecordingSessionController();

    await tester.pumpWidget(_host([
      customerOnboardingControllerProvider.overrideWith(
        () => _FakeOnboarding(
          const OnboardingNeedsCompletion(firebaseIdToken: 'fb-token'),
        ),
      ),
      customerAuthRepositoryProvider.overrideWithValue(repo),
      sessionProvider.overrideWith(() => session),
    ]));
    await tester.pumpAndSettle();

    // Enter mobile and check terms, but leave name empty
    await tester.enterText(find.byKey(const Key('customer-completion-name')), '');
    await tester.enterText(
      find.byKey(const Key('customer-completion-mobile')),
      '+971500000009',
    );
    await tester.tap(find.byKey(const Key('accept-terms-checkbox')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your name.'), findsOneWidget);
  });
}
