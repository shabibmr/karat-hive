import 'platform_setting_item.dart';

/// State representation for the ADM-S19 Platform Settings screen.
class PlatformSettingsState {
  const PlatformSettingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.settings = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final bool isSaving;
  final List<PlatformSettingItem> settings;
  final SettingCategory? selectedCategory;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  /// Returns the filtered settings list based on [selectedCategory] and [searchQuery].
  List<PlatformSettingItem> get filteredSettings {
    return settings.where((item) {
      if (selectedCategory != null && item.category != selectedCategory) {
        return false;
      }
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchesKey = item.key.toLowerCase().contains(q);
        final matchesDesc =
            item.description?.toLowerCase().contains(q) ?? false;
        final matchesValue =
            item.value?.toString().toLowerCase().contains(q) ?? false;
        if (!matchesKey && !matchesDesc && !matchesValue) {
          return false;
        }
      }
      return true;
    }).toList(growable: false);
  }

  /// Counts the total settings under a specific [category].
  int countByCategory(SettingCategory category) {
    return settings.where((s) => s.category == category).length;
  }

  /// Counts settings flagged as pending architectural decisions.
  int get pendingDecisionsCount {
    return settings.where((s) => s.isOfferValidityPendingDecision).length;
  }

  PlatformSettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<PlatformSettingItem>? settings,
    SettingCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return PlatformSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      settings: settings ?? this.settings,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
