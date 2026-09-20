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

  test('hydrateFromExisting prefills profile and marks uploaded docs (VO-13)',
      () async {
    when(() => repo.vendorMe()).thenAnswer(
      (_) async => const Ok(
        VendorMe(
          vendorProfileId: 'vp1',
          lifecycle: VendorLifecycle.rejected,
          awaitingApproval: true,
          tradingName: 'Gold House',
          legalBusinessName: 'Gold House LLC',
          tradeLicenceNumber: 'CN-1092834',
          licenceExpiryDate: '2027-06-30',
          categoryCount: 0,
          regionCount: 0,
        ),
      ),
    );
    when(() => repo.documents()).thenAnswer(
      (_) async => Ok([
        VendorDocument(
          id: 'doc-tl',
          documentType: VendorDocumentType.tradeLicence,
          verified: false,
          uploadedAt: DateTime.utc(2026, 9, 1),
        ),
      ]),
    );

    final c = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);

    await c.read(kycUploadControllerProvider.notifier).hydrateFromExisting();
    final state = c.read(kycUploadControllerProvider);

    expect(state.legalBusinessName, 'Gold House LLC');
    expect(state.tradeLicenceNumber, 'CN-1092834');
    expect(state.licenceExpiryDate, '2027-06-30');
    expect(
      state.documents[VendorDocumentType.tradeLicence]?.done,
      isTrue,
    );
    expect(
      state.documents[VendorDocumentType.emiratesId]?.done,
      isFalse,
    );
    expect(state.hydrated, isTrue);
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

  test('submitKyc patches licence expiry with profile fields (VO-03)', () async {
    when(
      () => repo.patchKycProfile(
        legalBusinessName: any(named: 'legalBusinessName'),
        tradeLicenceNumber: any(named: 'tradeLicenceNumber'),
        licenceExpiryDate: any(named: 'licenceExpiryDate'),
      ),
    ).thenAnswer(
      (_) async => const Ok(
        VendorMe(
          vendorProfileId: 'vp1',
          lifecycle: VendorLifecycle.pendingVerification,
          awaitingApproval: true,
          tradingName: 'Gold House',
          legalBusinessName: 'Gold House LLC',
          tradeLicenceNumber: 'CN-1092834',
          categoryCount: 0,
          regionCount: 0,
        ),
      ),
    );

    final c = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);

    final controller = c.read(kycUploadControllerProvider.notifier);
    controller.patchFields(
      legalBusinessName: 'Gold House LLC',
      tradeLicenceNumber: 'CN-1092834',
      licenceExpiryDate: '2027-06-30',
    );

    final ok = await controller.submitKyc();

    expect(ok, isTrue);
    verify(
      () => repo.patchKycProfile(
        legalBusinessName: 'Gold House LLC',
        tradeLicenceNumber: 'CN-1092834',
        licenceExpiryDate: '2027-06-30',
      ),
    ).called(1);
  });

  test('trade licence attach forwards expiry when already filled', () async {
    when(
      () => repo.uploadKycDocumentBytes(
        any(),
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => const Ok('media-key-1'));
    when(
      () => repo.attachDocument(
        type: any(named: 'type'),
        mediaKey: any(named: 'mediaKey'),
        expiryDate: any(named: 'expiryDate'),
      ),
    ).thenAnswer((_) async => const Ok([]));

    final c = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);

    final controller = c.read(kycUploadControllerProvider.notifier);
    controller.patchFields(licenceExpiryDate: '2027-06-30');
    await controller.pickAndUploadBytes(
      VendorDocumentType.tradeLicence,
      Uint8List.fromList([1, 2, 3]),
      'application/pdf',
    );

    verify(
      () => repo.attachDocument(
        type: VendorDocumentType.tradeLicence,
        mediaKey: 'media-key-1',
        expiryDate: '2027-06-30',
      ),
    ).called(1);
  });
}
