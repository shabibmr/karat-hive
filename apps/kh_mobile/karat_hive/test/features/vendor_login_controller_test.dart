import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/core/firebase/firebase_auth_service.dart';
import 'package:karat_hive/features/auth/controller/vendor_login_controller.dart';
import 'package:karat_hive/features/auth/repository/auth_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/customer_auth.dart';

class _MockFirebase extends Mock implements FirebaseAuthService {}

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockFirebase firebase;
  late _MockAuthRepo repo;
  late RecordingSessionController session;

  setUp(() {
    firebase = _MockFirebase();
    repo = _MockAuthRepo();
    session = RecordingSessionController();
    when(() => firebase.signInWithGoogle()).thenAnswer((_) async => null);
    when(() => firebase.getIdToken(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => 'fb-id-token');
  });

  ProviderContainer container() => ProviderContainer(overrides: [
        firebaseAuthServiceProvider.overrideWithValue(firebase),
        authRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(() => session),
      ]);

  test('a bound Google token authenticates and seeds the session', () async {
    final bundle = testCustomerBundle();
    when(() => repo.googleSession(any())).thenAnswer((_) async => Ok(bundle));
    final c = container();
    addTearDown(c.dispose);

    await c.read(vendorLoginControllerProvider.notifier).signInWithGoogle();

    expect(
      c.read(vendorLoginControllerProvider),
      isA<LoginAuthenticated>(),
    );
    expect(session.authenticated.single, bundle);
  });

  test('an unbound Google token (401 UNAUTHENTICATED) needs registration',
      () async {
    when(() => repo.googleSession(any())).thenAnswer(
      (_) async => const Err(UnauthorisedFailure(code: 'UNAUTHENTICATED')),
    );
    final c = container();
    addTearDown(c.dispose);

    await c.read(vendorLoginControllerProvider.notifier).signInWithGoogle();

    expect(
      c.read(vendorLoginControllerProvider),
      isA<LoginNeedsRegistration>(),
    );
    expect(session.authenticated, isEmpty);
    final unbound = c.read(sessionProvider);
    expect(unbound, isA<UnboundGoogle>());
    expect((unbound as UnboundGoogle).firebaseIdToken, 'fb-id-token');
  });

  test('a bare 401 with no code also needs registration', () async {
    when(() => repo.googleSession(any()))
        .thenAnswer((_) async => const Err(UnauthorisedFailure()));
    final c = container();
    addTearDown(c.dispose);

    await c.read(vendorLoginControllerProvider.notifier).signInWithGoogle();

    expect(
      c.read(vendorLoginControllerProvider),
      isA<LoginNeedsRegistration>(),
    );
    expect(c.read(sessionProvider), isA<UnboundGoogle>());
  });

  test('other server failures surface as LoginError', () async {
    when(() => repo.googleSession(any())).thenAnswer(
      (_) async => const Err(RateLimitedFailure(message: 'Too many codes.')),
    );
    final c = container();
    addTearDown(c.dispose);

    await c.read(vendorLoginControllerProvider.notifier).signInWithGoogle();

    final state = c.read(vendorLoginControllerProvider);
    expect(state, isA<LoginError>());
    expect((state as LoginError).failure, isA<RateLimitedFailure>());
  });

  test('a thrown Firebase error surfaces as a network LoginError', () async {
    when(() => firebase.signInWithGoogle()).thenThrow(StateError('no network'));
    final c = container();
    addTearDown(c.dispose);

    await c.read(vendorLoginControllerProvider.notifier).signInWithGoogle();

    final state = c.read(vendorLoginControllerProvider);
    expect(state, isA<LoginError>());
    expect((state as LoginError).failure, isA<NetworkFailure>());
  });

  test('a cancelled Google picker returns to idle', () async {
    when(() => firebase.getIdToken(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => null);
    final c = container();
    addTearDown(c.dispose);

    await c.read(vendorLoginControllerProvider.notifier).signInWithGoogle();

    expect(c.read(vendorLoginControllerProvider), isA<LoginIdle>());
    verifyNever(() => repo.googleSession(any()));
  });
}
