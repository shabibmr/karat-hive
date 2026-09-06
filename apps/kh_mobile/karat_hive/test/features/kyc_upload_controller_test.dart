import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/onboarding/controller/kyc_upload_controller.dart';
import 'package:karat_hive/features/onboarding/repository/onboarding_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements OnboardingRepository {}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    registerFallbackValue(File('x'));
  });

  test('allMandatoryDone is false until both slots succeed', () {
    final c = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    expect(c.read(kycUploadControllerProvider.notifier).allMandatoryDone, isFalse);
  });

  test('failed upload isolates error on that slot', () async {
    when(
      () => repo.uploadKycDocument(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => const Err(ServerFailure(message: 'fail')));

    final c = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);

    await c.read(kycUploadControllerProvider.notifier).pickAndUpload(
          VendorDocumentType.tradeLicence,
          File('licence.pdf'),
          'application/pdf',
        );

    final slot = c.read(kycUploadControllerProvider)[VendorDocumentType.tradeLicence];
    expect(slot?.failure, isA<ServerFailure>());
    expect(slot?.done, isFalse);
  });
}
