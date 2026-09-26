import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/auth/repository/customer_auth_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/customer_auth.dart';

class _MockKhApi extends Mock implements KhApi {}

void main() {
  late _MockKhApi api;
  late CustomerAuthRepository repo;

  setUp(() {
    api = _MockKhApi();
    repo = CustomerAuthRepository(api);
  });

  test('requestOtp always uses the REGISTER_CUSTOMER purpose', () async {
    when(() => api.otpRequest(
              mobileNumber: any(named: 'mobileNumber'),
              purpose: any(named: 'purpose'),
            ))
        .thenAnswer((_) async =>
            Ok(OtpChallenge(challengeId: 'c', expiresAt: DateTime.utc(2030))));

    await repo.requestOtp('+971500000009');

    verify(() => api.otpRequest(
          mobileNumber: '+971500000009',
          purpose: 'REGISTER_CUSTOMER',
        )).called(1);
  });

  test('registerCustomer forwards the firebase token, challenge and terms/privacy '
      'versions', () async {
    final bundle = testCustomerBundle();
    when(() => api.registerCustomer(
          challengeId: any(named: 'challengeId'),
          firebaseToken: any(named: 'firebaseToken'),
          mobileNumber: any(named: 'mobileNumber'),
          displayName: any(named: 'displayName'),
          email: any(named: 'email'),
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          termsVersion: any(named: 'termsVersion'),
          privacyVersion: any(named: 'privacyVersion'),
        )).thenAnswer((_) async => Ok(bundle));

    final result = await repo.registerCustomer(
      firebaseToken: 'fb',
      challengeId: 'chal',
      displayName: 'Layla',
    );

    expect(result.valueOrNull, bundle);
    verify(() => api.registerCustomer(
          challengeId: 'chal',
          firebaseToken: 'fb',
          mobileNumber: null,
          displayName: 'Layla',
          email: null,
          preferredLanguage: 'en',
          defaultRegionId: null,
          termsVersion: '1.0',
          privacyVersion: '1.0',
        )).called(1);
  });

  test('googleSession forwards expectedRole: CUSTOMER by default and propagates results', () async {
    when(() => api.googleSession(
          idToken: any(named: 'idToken'),
          expectedRole: any(named: 'expectedRole'),
        )).thenAnswer(
      (_) async => const Err(UnauthorisedFailure(code: 'UNAUTHENTICATED')),
    );

    final result = await repo.googleSession('tok');

    expect(result.failureOrNull, isA<UnauthorisedFailure>());
    expect(result.failureOrNull!.code, 'UNAUTHENTICATED');
    verify(() => api.googleSession(idToken: 'tok', expectedRole: 'CUSTOMER')).called(1);
  });

  test('googleSession propagates ForbiddenFailure (ACCOUNT_ROLE_MISMATCH)', () async {
    when(() => api.googleSession(
          idToken: any(named: 'idToken'),
          expectedRole: any(named: 'expectedRole'),
        )).thenAnswer(
      (_) async => const Err(ForbiddenFailure(
        code: 'ACCOUNT_ROLE_MISMATCH',
        message: 'Your account type does not match the requested role.',
      )),
    );

    final result = await repo.googleSession('tok');

    expect(result.failureOrNull, isA<ForbiddenFailure>());
    expect(result.failureOrNull!.code, 'ACCOUNT_ROLE_MISMATCH');
  });

  test('googleSession propagates ConflictFailure (ACCOUNT_ROLE_CONFLICT / OAUTH_ALREADY_BOUND)', () async {
    when(() => api.googleSession(
          idToken: any(named: 'idToken'),
          expectedRole: any(named: 'expectedRole'),
        )).thenAnswer(
      (_) async => const Err(ConflictFailure(
        code: 'ACCOUNT_ROLE_CONFLICT',
        message: 'An account already exists for this identity with a different role.',
      )),
    );

    final result = await repo.googleSession('tok');

    expect(result.failureOrNull, isA<ConflictFailure>());
    expect(result.failureOrNull!.code, 'ACCOUNT_ROLE_CONFLICT');
  });
}
