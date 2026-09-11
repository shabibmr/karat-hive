import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/core/firebase/firebase_auth_service.dart';
import 'package:karat_hive/features/auth/controller/customer_onboarding_controller.dart';
import 'package:karat_hive/features/auth/repository/customer_auth_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/customer_auth.dart';

class _MockFirebase extends Mock implements FirebaseAuthService {}

class _MockRepo extends Mock implements CustomerAuthRepository {}

void main() {
  late _MockFirebase firebase;
  late _MockRepo repo;
  late RecordingSessionController session;

  setUp(() {
    firebase = _MockFirebase();
    repo = _MockRepo();
    session = RecordingSessionController();
    when(() => firebase.signInWithGoogle()).thenAnswer((_) async => null);
    when(() => firebase.getIdToken(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => 'fb-id-token');
  });

  ProviderContainer container() => ProviderContainer(overrides: [
        firebaseAuthServiceProvider.overrideWithValue(firebase),
        customerAuthRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(() => session),
      ]);

  test('a bound Google token authenticates and seeds the session', () async {
    final bundle = testCustomerBundle();
    when(() => repo.googleSession(any())).thenAnswer((_) async => Ok(bundle));
    final c = container();
    addTearDown(c.dispose);

    await c
        .read(customerOnboardingControllerProvider.notifier)
        .signInWithGoogle();

    expect(c.read(customerOnboardingControllerProvider),
        isA<OnboardingAuthenticated>());
    expect(session.authenticated.single, bundle);
  });

  test('an unbound Google token (401 UNAUTHENTICATED) routes to completion',
      () async {
    when(() => repo.googleSession(any())).thenAnswer(
      (_) async => const Err(UnauthorisedFailure(code: 'UNAUTHENTICATED')),
    );
    final c = container();
    addTearDown(c.dispose);

    await c
        .read(customerOnboardingControllerProvider.notifier)
        .signInWithGoogle();

    final state = c.read(customerOnboardingControllerProvider);
    expect(state, isA<OnboardingNeedsCompletion>());
    expect((state as OnboardingNeedsCompletion).firebaseIdToken, 'fb-id-token');
    expect(session.authenticated, isEmpty);
    final unbound = c.read(sessionProvider);
    expect(unbound, isA<UnboundGoogle>());
    expect((unbound as UnboundGoogle).firebaseIdToken, 'fb-id-token');
  });

  test('resetToIdle clears failure after cancel (GL-38)', () async {
    when(() => firebase.signInWithGoogle()).thenThrow(StateError('no network'));
    final c = container();
    addTearDown(c.dispose);

    await c
        .read(customerOnboardingControllerProvider.notifier)
        .signInWithGoogle();
    expect(
      c.read(customerOnboardingControllerProvider),
      isA<OnboardingFailure>(),
    );

    c.read(customerOnboardingControllerProvider.notifier).resetToIdle();
    expect(
      c.read(customerOnboardingControllerProvider),
      isA<OnboardingIdle>(),
    );
  });

  test('a bare 401 with no code is also treated as unbound', () async {
    when(() => repo.googleSession(any()))
        .thenAnswer((_) async => const Err(UnauthorisedFailure()));
    final c = container();
    addTearDown(c.dispose);

    await c
        .read(customerOnboardingControllerProvider.notifier)
        .signInWithGoogle();

    expect(c.read(customerOnboardingControllerProvider),
        isA<OnboardingNeedsCompletion>());
  });

  for (final code in kAuthLockoutCodes) {
    test('$code → OnboardingLockedOut + AuthBlocked, not Guest (GL-68)',
        () async {
      when(() => repo.googleSession(any())).thenAnswer(
        (_) async =>
            Err(ForbiddenFailure(code: code, message: 'Blocked ($code).')),
      );
      final c = container();
      addTearDown(c.dispose);

      await c
          .read(customerOnboardingControllerProvider.notifier)
          .signInWithGoogle();

      final state = c.read(customerOnboardingControllerProvider);
      expect(state, isA<OnboardingLockedOut>());
      expect((state as OnboardingLockedOut).message, 'Blocked ($code).');

      final sessionState = c.read(sessionProvider);
      expect(sessionState, isA<AuthBlocked>());
      expect((sessionState as AuthBlocked).failure.code, code);
      expect(sessionState, isNot(isA<SignedOut>()));
    });
  }

  test('other server failures surface as OnboardingFailure', () async {
    when(() => repo.googleSession(any())).thenAnswer(
      (_) async => const Err(ServerFailure(message: 'Upstream is down.')),
    );
    final c = container();
    addTearDown(c.dispose);

    await c
        .read(customerOnboardingControllerProvider.notifier)
        .signInWithGoogle();

    final state = c.read(customerOnboardingControllerProvider);
    expect(state, isA<OnboardingFailure>());
    expect((state as OnboardingFailure).failure.message, 'Upstream is down.');
  });

  test('a cancelled Google picker returns to idle', () async {
    when(() => firebase.getIdToken(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => null);
    final c = container();
    addTearDown(c.dispose);

    await c
        .read(customerOnboardingControllerProvider.notifier)
        .signInWithGoogle();

    expect(c.read(customerOnboardingControllerProvider), isA<OnboardingIdle>());
    verifyNever(() => repo.googleSession(any()));
  });

  test('a thrown Firebase error surfaces as a transport failure', () async {
    when(() => firebase.signInWithGoogle()).thenThrow(StateError('no network'));
    final c = container();
    addTearDown(c.dispose);

    await c
        .read(customerOnboardingControllerProvider.notifier)
        .signInWithGoogle();

    final state = c.read(customerOnboardingControllerProvider);
    expect(state, isA<OnboardingFailure>());
    expect((state as OnboardingFailure).failure, isA<NetworkFailure>());
  });
}
