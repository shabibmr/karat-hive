import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';
import 'package:kh_admin/features/settings/model/platform_settings_state.dart';
import 'package:kh_admin/features/settings/repository/platform_settings_repository.dart';

final platformSettingsControllerProvider =
    StateNotifierProvider<PlatformSettingsController, PlatformSettingsState>(
        (ref) {
  final repository = ref.watch(platformSettingsRepositoryProvider);
  return PlatformSettingsController(repository);
});

/// Controller managing state and actions for the Platform Settings screen.
class PlatformSettingsController extends StateNotifier<PlatformSettingsState> {
  PlatformSettingsController(this._repository)
      : super(const PlatformSettingsState()) {
    loadSettings();
  }

  final PlatformSettingsRepository _repository;

  /// Loads all settings from the repository.
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.fetchSettings();
      state = state.copyWith(
        isLoading: false,
        settings: items,
      );
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractErrorMessage(e),
      );
    }
  }

  /// Reloads all settings from the server.
  Future<void> refresh() => loadSettings();

  /// Filters settings by category, or shows all if [category] is null.
  void selectCategory(SettingCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  /// Sets the search filter query string.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Updates a setting by [key] with [value] and optional [confirm] authorization.
  ///
  /// Returns `true` on success, `false` on validation or network failure.
  Future<bool> updateSetting(
    String key,
    dynamic value, {
    bool? confirm,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);
    try {
      final updated =
          await _repository.updateSetting(key, value, confirm: confirm);

      final updatedList = state.settings.map((item) {
        if (item.key == key) {
          return updated.copyWith(
            description: item.description,
            allowedRange: item.allowedRange,
            requiresSuperAdmin: item.requiresSuperAdmin,
            category: item.category,
          );
        }
        return item;
      }).toList(growable: false);

      state = state.copyWith(
        isSaving: false,
        settings: updatedList,
        successMessage: 'Setting "$key" updated successfully.',
      );
      return true;
    } on Object catch (e) {
      final msg = _extractErrorMessage(e);
      state = state.copyWith(
        isSaving: false,
        errorMessage: msg,
      );
      return false;
    }
  }

  /// Clears active error and success messages.
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  String _extractErrorMessage(Object error) {
    if (error is ApiException) {
      if (error.code == 'SETTING_OUT_OF_RANGE') {
        return 'Setting value is outside the permitted allowedRange.';
      }
      return error.message;
    }
    return error.toString();
  }
}
