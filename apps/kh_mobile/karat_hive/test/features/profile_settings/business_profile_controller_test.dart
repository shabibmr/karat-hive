import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/profile_settings/controller/business_profile_controller.dart';
import 'package:karat_hive/features/profile_settings/repository/profile_settings_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_session.dart';

class _MockRepo extends Mock implements ProfileSettingsRepository {}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  VendorMe me() => testVendorMe(lifecycle: VendorLifecycle.active);

  setUp(() {
    repo = _MockRepo();
    container = ProviderContainer(
      overrides: [
        profileSettingsRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(
          () => FakeSessionController(SignedIn(testVendorUser(vendor: me()))),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test('saveSafeEdits rejects blank required fields without calling the API', () async {
    final ok = await container
        .read(businessProfileSaveProvider.notifier)
        .saveSafeEdits(
          tradingName: ' ',
          contactPersonName: 'Sara',
          businessEmail: 'sara@example.com',
        );
    expect(ok, isFalse);
    verifyNever(
      () => repo.patchVendorProfile(
        tradingName: any(named: 'tradingName'),
        description: any(named: 'description'),
        contactPersonName: any(named: 'contactPersonName'),
        businessEmail: any(named: 'businessEmail'),
        logoMediaKey: any(named: 'logoMediaKey'),
      ),
    );
  });

  test('saveSafeEdits patches profile then availability hours', () async {
    when(
      () => repo.patchVendorProfile(
        tradingName: any(named: 'tradingName'),
        description: any(named: 'description'),
        contactPersonName: any(named: 'contactPersonName'),
        businessEmail: any(named: 'businessEmail'),
        logoMediaKey: any(named: 'logoMediaKey'),
      ),
    ).thenAnswer((_) async => Ok(me()));
    when(() => repo.setAvailability(businessHours: any(named: 'businessHours')))
        .thenAnswer((_) async => Ok(me()));

    final ok = await container
        .read(businessProfileSaveProvider.notifier)
        .saveSafeEdits(
          tradingName: 'Al Noor',
          description: 'Showroom',
          contactPersonName: 'Sara',
          businessEmail: 'sara@example.com',
          businessHours: const {
            'mon': BusinessDayHours(open: '09:30', close: '22:00'),
          },
        );

    expect(ok, isTrue);
    verify(
      () => repo.patchVendorProfile(
        tradingName: 'Al Noor',
        description: 'Showroom',
        contactPersonName: 'Sara',
        businessEmail: 'sara@example.com',
        logoMediaKey: null,
      ),
    ).called(1);
    verify(() => repo.setAvailability(businessHours: any(named: 'businessHours')))
        .called(1);
  });

  test('saveSafeEdits forwards logoMediaKey when a new logo was uploaded', () async {
    when(
      () => repo.patchVendorProfile(
        tradingName: any(named: 'tradingName'),
        description: any(named: 'description'),
        contactPersonName: any(named: 'contactPersonName'),
        businessEmail: any(named: 'businessEmail'),
        logoMediaKey: any(named: 'logoMediaKey'),
      ),
    ).thenAnswer((_) async => Ok(me()));

    final ok = await container
        .read(businessProfileSaveProvider.notifier)
        .saveSafeEdits(
          tradingName: 'Al Noor',
          contactPersonName: 'Sara',
          businessEmail: 'sara@example.com',
          logoMediaKey: 'media-key-new-logo',
        );

    expect(ok, isTrue);
    verify(
      () => repo.patchVendorProfile(
        tradingName: 'Al Noor',
        description: '',
        contactPersonName: 'Sara',
        businessEmail: 'sara@example.com',
        logoMediaKey: 'media-key-new-logo',
      ),
    ).called(1);
  });

  test('uploadLogo returns the media key on success', () async {
    final bytes = Uint8List.fromList(const [1, 2, 3]);
    when(() => repo.uploadLogo(bytes))
        .thenAnswer((_) async => const Ok('media-key-new-logo'));

    final key = await container
        .read(businessProfileSaveProvider.notifier)
        .uploadLogo(bytes);

    expect(key, 'media-key-new-logo');
    expect(container.read(businessProfileSaveProvider).logoUploading, isFalse);
    expect(container.read(businessProfileSaveProvider).failure, isNull);
  });

  test('uploadLogo returns null and surfaces a failure on error', () async {
    final bytes = Uint8List.fromList(const [1, 2, 3]);
    when(() => repo.uploadLogo(bytes)).thenAnswer(
      (_) async => const Err(ServerFailure(message: 'Upload failed.')),
    );

    final key = await container
        .read(businessProfileSaveProvider.notifier)
        .uploadLogo(bytes);

    expect(key, isNull);
    expect(container.read(businessProfileSaveProvider).logoUploading, isFalse);
    expect(container.read(businessProfileSaveProvider).failure, isNotNull);
  });
}
