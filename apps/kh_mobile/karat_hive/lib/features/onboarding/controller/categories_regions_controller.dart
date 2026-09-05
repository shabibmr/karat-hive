import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';

import '../../../app/session/session_controller.dart';
import '../repository/onboarding_repository.dart';
import 'vendor_me_controller.dart';

class CategoriesRegionsState {
  const CategoriesRegionsState({
    this.categoryIds = const {},
    this.regionIds = const {},
    this.busy = false,
    this.failure,
  });

  final Set<String> categoryIds;
  final Set<String> regionIds;
  final bool busy;
  final Failure? failure;

  bool get canSave => categoryIds.isNotEmpty && regionIds.isNotEmpty && !busy;

  CategoriesRegionsState copyWith({
    Set<String>? categoryIds,
    Set<String>? regionIds,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      CategoriesRegionsState(
        categoryIds: categoryIds ?? this.categoryIds,
        regionIds: regionIds ?? this.regionIds,
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

class CategoriesRegionsController
    extends AutoDisposeNotifier<CategoriesRegionsState> {
  @override
  CategoriesRegionsState build() => const CategoriesRegionsState();

  OnboardingRepository get _repo => ref.read(onboardingRepositoryProvider);

  void toggleCategory(String id) => state = state.copyWith(
        categoryIds: _toggle(state.categoryIds, id),
        clearFailure: true,
      );

  void toggleRegion(String id) => state = state.copyWith(
        regionIds: _toggle(state.regionIds, id),
        clearFailure: true,
      );

  Future<bool> save() async {
    state = state.copyWith(busy: true, clearFailure: true);
    final cat = await _repo.setCategories(state.categoryIds.toList());
    final catFail = cat.failureOrNull;
    if (catFail != null) {
      state = state.copyWith(busy: false, failure: catFail);
      return false;
    }
    final reg = await _repo.setRegions(state.regionIds.toList());
    final regFail = reg.failureOrNull;
    if (regFail != null) {
      state = state.copyWith(busy: false, failure: regFail);
      return false;
    }
    ref.invalidate(vendorMeProvider);
    await ref.read(sessionProvider.notifier).refreshUser();
    state = state.copyWith(busy: false);
    return true;
  }

  static Set<String> _toggle(Set<String> set, String id) {
    final next = {...set};
    next.contains(id) ? next.remove(id) : next.add(id);
    return next;
  }
}

final categoriesRegionsControllerProvider = AutoDisposeNotifierProvider<
    CategoriesRegionsController, CategoriesRegionsState>(
  CategoriesRegionsController.new,
);
