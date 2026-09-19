import 'dart:typed_data';

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

  setUpAll(() {
    registerFallbackValue(VendorDocumentType.tradeLicence);
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repo = _MockRepo();
  });

  test('mandatoryDocsDone is false until both slots succeed', () {
    final c = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    expect(
      c.read(kycUploadControllerProvider).mandatoryDocsDone,
      isFalse,
    );
  });

  test('failed upload isolates error on that slot', () async {
    when(
      () => repo.uploadKycDocumentBytes(
        any(),
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => const Err(ServerFailure(message: 'fail')));

    final c = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);

    await c.read(kycUploadControllerProvider.notifier).pickAndUploadBytes(
          VendorDocumentType.tradeLicence,
          Uint8List.fromList([1, 2, 3]),
          'application/pdf',
        );

    final slot = c
        .read(kycUploadControllerProvider)
        .documents[VendorDocumentType.tradeLicence];
    expect(slot?.failure, isA<ServerFailure>());
    expect(slot?.done, isFalse);
  });
}
