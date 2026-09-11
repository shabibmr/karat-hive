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
  testWidgets('welcome view shows the Google button + biometric toggle (CFE-09)',
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
    expect(find.byKey(const Key('biometric-unlock-toggle')), findsOneWidget);
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

  testWidgets('completion step: terms + mobile, then the code sub-step (CFE-10)',
      (tester) async {
    final repo = _MockRepo();
    when(() => repo.requestOtp(any())).thenAnswer(
      (_) async =>
          Ok(OtpChallenge(challengeId: 'c1', expiresAt: DateTime.utc(2030))),
    );
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

    // Send code is disabled until name + mobile + terms are all present.
    await tester.enterText(find.byType(TextField).at(0), 'Layla');
    await tester.enterText(find.byType(TextField).at(1), '+971500000009');
    await tester.tap(find.byKey(const Key('accept-terms-checkbox')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('otp-input')), findsOneWidget);
    expect(find.textContaining('+971500000009'), findsOneWidget);
  });
}
