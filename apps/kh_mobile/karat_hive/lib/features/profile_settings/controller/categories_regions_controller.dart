import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';

import '../../../app/session/session_controller.dart';
import '../../onboarding/controller/vendor_me_controller.dart';
import '../repository/profile_settings_repository.dart';
import 'business_profile_controller.dart';

class CategoriesRegionsState {
  const CategoriesRegionsState({
    this.categoryIds = const {},
    this.regionIds = const {},
    this.awayMode = false,
    this.busy = false,
    this.failure,
  });

  final Set<String> categoryIds;
  final Set<String> regionIds;
  final bool awayMode;
  final bool busy;
  final Failure? failure;

  bool get canSave => categoryIds.isNotEmpty && regionIds.isNotEmpty && !busy;

  CategoriesRegionsState copyWith({
    Set<String>? categoryIds,
    Set<String>? regionIds,
    bool? awayMode,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      CategoriesRegionsState(
        categoryIds: categoryIds ?? this.categoryIds,
        regionIds: regionIds ?? this.regionIds,
        awayMode: awayMode ?? this.awayMode,
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

class CategoriesRegionsController
    extends AutoDisposeNotifier<CategoriesRegionsState> {
  @override
  CategoriesRegionsState build() {
    ref.listen(vendorMeProvider, (_, next) {
      next.whenData((me) {
        if (state.categoryIds.isEmpty && state.regionIds.isEmpty) {
          state = state.copyWith(
            categoryIds: me.categoryIds.toSet(),
            regionIds: me.regionIds.toSet(),
            awayMode: me.awayMode,
          );
        }
      });
    });
    final session = ref.read(sessionProvider);
    if (session is SignedIn && session.user.vendor != null) {
      final me = session.user.vendor!;
      return CategoriesRegionsState(
        categoryIds: me.categoryIds.toSet(),
        regionIds: me.regionIds.toSet(),
        awayMode: me.awayMode,
      );
    }
    return const CategoriesRegionsState();
  }

  ProfileSettingsRepository get _repo =>
      ref.read(profileSettingsRepositoryProvider);

  void toggleCategory(String id) => state = state.copyWith(
        categoryIds: _toggle(state.categoryIds, id),
        clearFailure: true,
      );

  void toggleRegion(String id) => state = state.copyWith(
        regionIds: _toggle(state.regionIds, id),
        clearFailure: true,
      );

  Future<void> setAwayMode(bool value) async {
    state = state.copyWith(awayMode: value, busy: true, clearFailure: true);
    final r = await _repo.setAvailability(awayMode: value);
    state = state.copyWith(busy: false, failure: r.failureOrNull);
  }

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
    ref.invalidate(vendorProfileProvider);
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
