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
      ),
    ).called(1);
    verify(() => repo.setAvailability(businessHours: any(named: 'businessHours')))
        .called(1);
  });
}
