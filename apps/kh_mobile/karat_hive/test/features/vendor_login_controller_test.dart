import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/auth/controller/vendor_login_controller.dart';
import 'package:karat_hive/features/auth/repository/auth_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepo repo;

  setUp(() => repo = _MockAuthRepo());

  ProviderContainer container() => ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );

  test('sendOtp transitions idle → busy → otpSent', () async {
    when(() => repo.requestOtp(any(), any())).thenAnswer(
      (_) async => Ok(OtpChallenge(challengeId: 'c1', expiresAt: DateTime.now())),
    );
    final c = container();
    addTearDown(c.dispose);

    await c.read(vendorLoginControllerProvider.notifier).sendOtp('+971500000001');

    final state = c.read(vendorLoginControllerProvider);
    expect(state, isA<LoginOtpSent>());
    expect((state as LoginOtpSent).challengeId, 'c1');
  });

  test('sendOtp surfaces a failure as LoginError', () async {
    when(() => repo.requestOtp(any(), any())).thenAnswer(
      (_) async => const Err(RateLimitedFailure(message: 'Too many codes.')),
    );
    final c = container();
    addTearDown(c.dispose);

    await c.read(vendorLoginControllerProvider.notifier).sendOtp('+971500000001');

    final state = c.read(vendorLoginControllerProvider);
    expect(state, isA<LoginError>());
    expect((state as LoginError).failure, isA<RateLimitedFailure>());
  });
}
