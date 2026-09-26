import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/profile_settings/controller/categories_regions_controller.dart';
import 'package:karat_hive/features/profile_settings/repository/profile_settings_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_session.dart';

class _MockRepo extends Mock implements ProfileSettingsRepository {}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  VendorMe me({
    List<String> regionIds = const [],
    bool awayMode = false,
  }) =>
      testVendorMe(
        lifecycle: VendorLifecycle.verified,
        regionIds: regionIds,
        awayMode: awayMode,
        awaitingApprovalReason: AwaitingApprovalReason.activationPending,
        verificationMessage: null,
      );

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

  test('canSave is false until at least one region is selected', () {
    final state = container.read(categoriesRegionsControllerProvider);
    expect(state.canSave, isFalse);

    container.read(categoriesRegionsControllerProvider.notifier).toggleRegion('r1');
    expect(container.read(categoriesRegionsControllerProvider).canSave, isTrue);
  });

  test('prefills regionIds and awayMode from the signed-in vendor', () {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        profileSettingsRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(
          () => FakeSessionController(
            SignedIn(
              testVendorUser(
                vendor: me(
                  regionIds: const ['r-pre'],
                  awayMode: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(categoriesRegionsControllerProvider);
    expect(state.regionIds, {'r-pre'});
    expect(state.awayMode, isTrue);
  });

  test('save persists regions and returns true', () async {
    when(() => repo.setRegions(any())).thenAnswer(
      (_) async => Ok(me(regionIds: const ['r1'])),
    );

    final ctrl = container.read(categoriesRegionsControllerProvider.notifier);
    ctrl.toggleRegion('r1');
    final ok = await ctrl.save();

    expect(ok, isTrue);
    verify(() => repo.setRegions(['r1'])).called(1);
    expect(container.read(categoriesRegionsControllerProvider).busy, isFalse);
  });

  test('save surfaces a repository failure on setRegions error', () async {
    when(() => repo.setRegions(any())).thenAnswer(
      (_) async => const Err(ServerFailure(message: 'taxonomy write failed')),
    );

    final ctrl = container.read(categoriesRegionsControllerProvider.notifier);
    ctrl.toggleRegion('r1');
    final ok = await ctrl.save();

    expect(ok, isFalse);
    expect(
      container.read(categoriesRegionsControllerProvider).failure,
      isA<ServerFailure>(),
    );
  });
}
