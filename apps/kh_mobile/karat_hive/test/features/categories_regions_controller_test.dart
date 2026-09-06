import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/onboarding/controller/categories_regions_controller.dart';
import 'package:karat_hive/features/onboarding/repository/onboarding_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_session.dart';

class _MockRepo extends Mock implements OnboardingRepository {}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  VendorMe me({
    List<String> categoryIds = const [],
    List<String> regionIds = const [],
    bool awayMode = false,
  }) =>
      testVendorMe(
        lifecycle: VendorLifecycle.verified,
        categoryIds: categoryIds,
        regionIds: regionIds,
        awayMode: awayMode,
        awaitingApprovalReason: AwaitingApprovalReason.categoriesRequired,
        verificationMessage: null,
      );

  setUp(() {
    repo = _MockRepo();
    container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(
          () => FakeSessionController(SignedIn(testVendorUser(vendor: me()))),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test('canSave is false until at least one category and one region are selected', () {
    final state = container.read(categoriesRegionsControllerProvider);
    expect(state.canSave, isFalse);

    container.read(categoriesRegionsControllerProvider.notifier).toggleCategory('c1');
    expect(container.read(categoriesRegionsControllerProvider).canSave, isFalse);

    container.read(categoriesRegionsControllerProvider.notifier).toggleRegion('r1');
    expect(container.read(categoriesRegionsControllerProvider).canSave, isTrue);
  });

  test('prefills categoryIds, regionIds, and awayMode from the signed-in vendor', () {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(
          () => FakeSessionController(
            SignedIn(
              testVendorUser(
                vendor: me(
                  categoryIds: const ['c-pre'],
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
    expect(state.categoryIds, {'c-pre'});
    expect(state.regionIds, {'r-pre'});
    expect(state.awayMode, isTrue);
  });

  test('save persists categories then regions and returns true', () async {
    when(() => repo.setCategories(any())).thenAnswer(
      (_) async => Ok(me(categoryIds: const ['c1'])),
    );
    when(() => repo.setRegions(any())).thenAnswer(
      (_) async => Ok(me(categoryIds: const ['c1'], regionIds: const ['r1'])),
    );

    final ctrl = container.read(categoriesRegionsControllerProvider.notifier);
    ctrl.toggleCategory('c1');
    ctrl.toggleRegion('r1');
    final ok = await ctrl.save();

    expect(ok, isTrue);
    verify(() => repo.setCategories(['c1'])).called(1);
    verify(() => repo.setRegions(['r1'])).called(1);
    expect(container.read(categoriesRegionsControllerProvider).busy, isFalse);
  });

  test('save surfaces a repository failure and does not continue to regions', () async {
    when(() => repo.setCategories(any())).thenAnswer(
      (_) async => const Err(ServerFailure(message: 'taxonomy write failed')),
    );

    final ctrl = container.read(categoriesRegionsControllerProvider.notifier);
    ctrl.toggleCategory('c1');
    ctrl.toggleRegion('r1');
    final ok = await ctrl.save();

    expect(ok, isFalse);
    expect(
      container.read(categoriesRegionsControllerProvider).failure,
      isA<ServerFailure>(),
    );
    verifyNever(() => repo.setRegions(any()));
  });
}
