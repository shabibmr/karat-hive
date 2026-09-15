import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/auth/controller/customer_completion_controller.dart';
import 'package:karat_hive/features/auth/model/customer_completion_form.dart';
import 'package:karat_hive/features/auth/repository/customer_auth_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/customer_auth.dart';

class _MockRepo extends Mock implements CustomerAuthRepository {}

const _mobile = '+971500000009';

void main() {
  late _MockRepo repo;
  late RecordingSessionController session;

  setUp(() {
    repo = _MockRepo();
    session = RecordingSessionController();
  });

  ProviderContainer container() => ProviderContainer(overrides: [
        customerAuthRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(() => session),
      ]);

  CustomerCompletionController seeded(ProviderContainer c) {
    final ctrl = c.read(customerCompletionControllerProvider.notifier);
    ctrl.begin(firebaseIdToken: 'fb-token');
    ctrl.setName('Layla');
    ctrl.setMobile(_mobile);
    ctrl.setTermsAccepted(true);
    return ctrl;
  }

  OtpChallenge challenge() =>
      OtpChallenge(challengeId: 'chal-1', expiresAt: DateTime.utc(2030));

  test('begin() is idempotent — re-seeding does not wipe entered input', () {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = seeded(c);

    ctrl.begin(firebaseIdToken: 'fb-token');

    expect(c.read(customerCompletionControllerProvider).displayName, 'Layla');
  });

  test('continueWithoutOtp registers with typed mobile and skips OTP', () async {
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

    final c = container();
    addTearDown(c.dispose);
    await seeded(c).continueWithoutOtp();

    final form = c.read(customerCompletionControllerProvider);
    expect(form.step, CompletionStep.done);
    expect(session.authenticated.single, bundle);
    verifyNever(() => repo.requestOtp(any()));
    verify(() => repo.registerCustomer(
          firebaseToken: 'fb-token',
          challengeId: null,
          mobileNumber: _mobile,
          displayName: 'Layla',
          email: any(named: 'email'),
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
        )).called(1);
  });

  test('MOBILE_ALREADY_REGISTERED stays on details after continueWithoutOtp',
      () async {
    when(() => repo.registerCustomer(
          firebaseToken: any(named: 'firebaseToken'),
          challengeId: any(named: 'challengeId'),
          mobileNumber: any(named: 'mobileNumber'),
          displayName: any(named: 'displayName'),
          email: any(named: 'email'),
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
        )).thenAnswer(
      (_) async => const Err(
        ConflictFailure(
          code: 'MOBILE_ALREADY_REGISTERED',
          message: 'That number already has an account.',
        ),
      ),
    );
    final c = container();
    addTearDown(c.dispose);
    await seeded(c).continueWithoutOtp();

    final form = c.read(customerCompletionControllerProvider);
    expect(form.step, CompletionStep.details);
    expect(form.failure!.message, 'That number already has an account.');
    expect(session.authenticated, isEmpty);
  });

  test('continueWithoutOtp is a no-op until terms are accepted', () async {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(customerCompletionControllerProvider.notifier);
    ctrl.begin(firebaseIdToken: 'fb-token');
    ctrl.setName('Layla');
    ctrl.setMobile(_mobile);
    // terms NOT accepted
    await ctrl.continueWithoutOtp();
    expect(c.read(customerCompletionControllerProvider).step,
        CompletionStep.details);
    verifyNever(() => repo.registerCustomer(
          firebaseToken: any(named: 'firebaseToken'),
          challengeId: any(named: 'challengeId'),
          mobileNumber: any(named: 'mobileNumber'),
          displayName: any(named: 'displayName'),
          email: any(named: 'email'),
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
        ));
  });

  test('sendCode moves details → code and stores the challenge', () async {
    when(() => repo.requestOtp(any())).thenAnswer((_) async => Ok(challenge()));
    final c = container();
    addTearDown(c.dispose);
    await seeded(c).sendCode();

    final form = c.read(customerCompletionControllerProvider);
    expect(form.step, CompletionStep.code);
    expect(form.challengeId, 'chal-1');
  });

  test('happy path OTP: verify → register → session seeded, step done',
      () async {
    final bundle = testCustomerBundle();
    when(() => repo.requestOtp(any())).thenAnswer((_) async => Ok(challenge()));
    when(() => repo.verifyOtp(any(), any())).thenAnswer(
      (_) async => const Ok(
          OtpVerifyResult(mobileVerified: true, challengeId: 'chal-1')),
    );
    when(() => repo.registerCustomer(
          firebaseToken: any(named: 'firebaseToken'),
          challengeId: any(named: 'challengeId'),
          mobileNumber: any(named: 'mobileNumber'),
          displayName: any(named: 'displayName'),
          email: any(named: 'email'),
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
        )).thenAnswer((_) async => Ok(bundle));

    final c = container();
    addTearDown(c.dispose);
    final ctrl = seeded(c);
    await ctrl.sendCode();
    await ctrl.verifyAndRegister('123456');

    expect(c.read(customerCompletionControllerProvider).step,
        CompletionStep.done);
    expect(session.authenticated.single, bundle);
  });
}
